global with sharing class UVS_ProcessBillOfSales implements Database.Batchable<SObject>
{
    /*
        Declare a String for Query all the Bill Of Sales object records where Process is false.
        We need to process only those records where Process is false and 
        after process set these records as true so these never comes again
    */
    global String query = 'Select u.UNIT_ID__c, u.UNIT_NUMBER__c, u.OPPORTUNITYID__c, u.Id, '
                        + ' u.SOLD_LOCATION_CODE__c, u.PROCESS_COMMENT__c, u.OPPORTUNITY__c'
                        + ' From UVS_Bill_of_Sale__c u where'
                        + ' PROCESSED__c = false and OPPORTUNITYID__c != null and UNIT_ID__c != null';
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        // retrun the Query locator     
        return Database.getQueryLocator(query);
    }   
    global void execute(Database.BatchableContext BC, List<UVS_Bill_of_Sale__c> lUVS_Bill_of_Sale)
    {
        Boolean IsUpdatable = false;
        Set<String> sOppIds = new Set<String>();
        Set<String> sUnitIds = new Set<String>();
        Set<String> sRyderBranchIds = new Set<String>();
        Map<Id, Account> mAcc = new Map<Id, Account>();
        Map<String, Opportunity> mOpp = new Map<String, Opportunity>();
        Map<String, Vehicle__c> mVehicle = new Map<String, Vehicle__c>();
        Map<String, Ryder_Branch__c> mRyderBranch = new Map<String, Ryder_Branch__c>();
        Map<String, Customer_Branch__c> mCustomerBranch = new Map<String, Customer_Branch__c>();
        List<Opportunity> lOpp = new List<Opportunity>();
        List<Account> lAcc = new List<Account>();
        List<Vehicle__c> lVehicle = new List<Vehicle__c>();
        List<Customer_Branch__c> Customer_BranchUpdate = new List<Customer_Branch__c>();
        
        System.debug('---------lUVS_Bill_of_Sale-33->'+lUVS_Bill_of_Sale);
        // Get the UVS Record Type from Custom Settings for Customer Branch used in Creating Customer Branch
        String CustomerBranchRecordType = '';
        Global_Settings__c CustomerBranchRecordTypes = Global_Settings__c.getValues('11');
        // if the custom settings is not null then get the value from settings and out in a local variable
        if(CustomerBranchRecordTypes != null && CustomerBranchRecordTypes.Value__c != null && CustomerBranchRecordTypes.IsActive__c)
            CustomerBranchRecordType = CustomerBranchRecordTypes.Value__c;        
        System.debug('--------CustomerBranchRecordType-40->'+CustomerBranchRecordType);                
        /*
            Iterate all the Bill Of Sales records and create sets of Oportunity Number, Unit number and Locations
        */
        for(UVS_Bill_of_Sale__c Bill : lUVS_Bill_of_Sale)
        {
            System.debug('----Bill-46->'+Bill.Id);
            if(Bill.OPPORTUNITYID__c != null)
                sOppIds.add(Bill.OPPORTUNITYID__c);
            if(Bill.UNIT_ID__c != null)
                sUnitIds.add(Bill.UNIT_ID__c);
            if(Bill.SOLD_LOCATION_CODE__c != null)
            {
                if(String.valueOf(Bill.SOLD_LOCATION_CODE__c).length() == 4)
                    Bill.SOLD_LOCATION_CODE__c = '0'+Bill.SOLD_LOCATION_CODE__c;
                sRyderBranchIds.add(String.valueOf(Bill.SOLD_LOCATION_CODE__c));
            }
        }
        System.debug('---sRyderBranchIds-58->'+sRyderBranchIds);
        System.debug('---sUnitIds-59->'+sUnitIds);
        System.debug('---sOppIds-60->'+sOppIds);
        if(sOppIds.size() > 0)
        {
            Set<Id> sAccIds = new Set<Id>();
            /*
                Query all the Opportunities which are found in Bill Of Sales
            */
            List<Opportunity> lOppty = [select ext_pipeline_id__c, Id, StageName, AccountId 
                                        from Opportunity where ext_pipeline_id__c in : sOppIds 
                                        and AccountId != null];
            if(lOppty != null && lOppty.size() > 0)
            {
                mOpp = new Map<String, Opportunity>();
                for(Opportunity Opp : lOppty)
                {
                    mOpp.put(Opp.ext_pipeline_id__c, Opp);
                    sAccIds.add(Opp.AccountId);
                }
            }
            /*
                Query Account
            */
            if(sAccIds.size() > 0)
                mAcc = new Map<Id, Account>([Select a.LesseeNo__c, a.OwnerId, a.UVS_Type__c, Id, a.SAM_Cust_ID__c, 
                                            (Select RecordTypeId, Ext_Customerbranch_Id__c, Id, Ryder_Branch__c, Name, Ryder_Branch__r.Name, 
                                            Customer_Branch_Status__c, Ryder_Branch__r.Id, Ryder_Branch__r.Branch_Code__c 
                                            From Customer_Branches__r) 
                                            From Account a where Id IN : sAccIds]);
            /*
                create a collection of Customer Branch
            */
            for(String sAcc : sAccIds)
            {
                List<Customer_Branch__c> lCustomerBranch = mAcc.get(sAcc).Customer_Branches__r;
                for(Customer_Branch__c ObjCustomerBranch : lCustomerBranch)
                {
                    mCustomerBranch.put(ObjCustomerBranch.Ext_Customerbranch_Id__c, ObjCustomerBranch);
                }
            }
        }
        /*
            create a collection of Ryder Branch for creating a new Customer Branch if Customer Branch not found on Account
        */
        if(sRyderBranchIds.size() > 0)
        {
            List<Ryder_Branch__c> lRyderBranch = [Select r.Name, r.Id, r.Branch_Code__c, r.Area_Code__c 
                                                    From Ryder_Branch__c r where Branch_Code__c in : sRyderBranchIds];
            if(lRyderBranch != null && lRyderBranch.size() > 0)
            {
                for(Ryder_Branch__c Obj : lRyderBranch)
                    mRyderBranch.put(Obj.Branch_Code__c, Obj);
            }
        }
        if(sUnitIds.size() > 0)
        {
            mVehicle = new Map<String, Vehicle__c>();
            list<Vehicle__c> lVeh = [select Unit__c, Availability__c, Id, Is_Available_For_Sale__c, Account__c, Sold_Flag__c from Vehicle__c 
                                                where Unit__c IN : sUnitIds];
            if(lVeh != null && lVeh.size() > 0)
            {
                for(Vehicle__c Veh : lVeh)
                    mVehicle.put(Veh.Unit__c, Veh);
            }
        }
        System.debug('---mAcc-124->'+mAcc);
        System.debug('---mOpp-125->'+mOpp);
        System.debug('---mCustomerBranch-126->'+mCustomerBranch);
        System.debug('---mRyderBranch-127->'+mRyderBranch);
        System.debug('---mVehicle-128->'+mVehicle);
        
        Map<String, Customer_Branch__c> mCustomerBranchNew = new Map<String, Customer_Branch__c>();
        List<Customer_Branch__c> lCustomerBranchNew = new List<Customer_Branch__c>();
        List<Customer_Branch__c> lCustomerBranchUpd = new List<Customer_Branch__c>();
        List<UVS_Bill_of_Sale__c> lUVS_Bill_of_SaleRemains = new List<UVS_Bill_of_Sale__c>();
        // Get the UVS record Type id for Customer Branch
        for(UVS_Bill_of_Sale__c Bill : lUVS_Bill_of_Sale)
        {
            // Get the Opportunity and Vehicle records from Map 
            String sError = '';
            Opportunity Opp = mOpp.get(Bill.OPPORTUNITYID__c);
            Vehicle__c Vehicle = mVehicle.get(Bill.UNIT_ID__c);         
            Account Acc = null;
            System.debug('---Opp-142->'+Opp);
            System.debug('---mOpp-143->'+mOpp);
            System.debug('---Vehicle-144->'+Vehicle);
            System.debug('---mVehicle-145->'+mVehicle);
            // if we found the Opportunity and Vehicle then set the values in diff fields
            if(Opp != null && Vehicle != null)
            {
                Bill.OPPORTUNITY__c = Opp.Id;
                Acc = mAcc.get(Opp.AccountId);
                if(Acc.UVS_Type__c != 'Customer')
                {
                    Acc.UVS_Type__c = 'Customer';
                    lAcc.add(Acc);
                }
                if(Opp.StageName != 'Booked')
                {
                    Opp.StageName = 'Booked';
                    lOpp.add(Opp);
                }
                Vehicle.Is_Available_For_Sale__c = false;
                Vehicle.Sold_Flag__c = true;
                Vehicle.Availability__c = '';
                Vehicle.Bill_of_Sale__c = Bill.Id;
                Vehicle.Account__c = Opp.AccountId;
                // Now if in the Bill of Sales the Location Code is not null 
                // than check if this code match in current Customer Branch record or not
                if(Bill.SOLD_LOCATION_CODE__c != null)
                {
                    String sLocation = String.valueOf(Bill.SOLD_LOCATION_CODE__c);
                    Ryder_Branch__c ObjRyderB = mRyderBranch.get(sLocation);
                    //String sCode = Acc.SAM_Cust_ID__c + '-' + ObjRyderB.Branch_Code__c + '-' + ObjRyderB.Name;
                    String sCode = '';
                    if(ObjRyderB != null && ObjRyderB.Branch_Code__c != null)
                    {
                        sCode = (Id)Acc.Id + '_' + ObjRyderB.Branch_Code__c;
                        // If Customer Branch matchs than set the Vehicle to that Branch
                        if(mCustomerBranch.get(sCode) != null)
                        {
                            Customer_Branch__c CustB = mCustomerBranch.get(sCode);
                            Vehicle.Customer_Branch__c = CustB.Id;
                            lVehicle.add(Vehicle);
                            if(CustB.Customer_Branch_Status__c != 'Active')
                            {
                                CustB.Customer_Branch_Status__c = 'Active';
                                lCustomerBranchUpd.add(CustB);
                            }
                            if(CustB.RecordTypeId != CustomerBranchRecordType)
                            {
                            	CustB.RecordTypeId = CustomerBranchRecordType;
                            	Customer_BranchUpdate.add(CustB);
                            }
                        }
                        else // If Customer Branch matchs doesn't found than create a new Customer Branch and add in a collection
                        {
                        	String sName = '';
                        	if(Acc.LesseeNo__c != null)
                        		sName = Acc.LesseeNo__c + ' - ';
                        	if(ObjRyderB.Branch_Code__c != null)
                        		sName += ObjRyderB.Branch_Code__c + ' - ';
                        	sName += ObjRyderB.Name;                        	
                            // Create new Customer Branches
                            Customer_Branch__c Customer_Branch = new Customer_Branch__c();
                            Customer_Branch.Name = sName;
                            Customer_Branch.Ryder_Branch__c = ObjRyderB.Id;
                            Customer_Branch.Ryder_HQ_Account__c = Acc.Id;
                            Customer_Branch.ext_customerbranch_id__c = sCode;
                            Customer_Branch.Risk_Status__c = 'No Status';
                            Customer_Branch.Customer_Branch_Owner__c = Acc.OwnerId;
                            Customer_Branch.RecordTypeId = CustomerBranchRecordType;
                            mCustomerBranchNew.put(sCode, Customer_Branch);
                            lUVS_Bill_of_SaleRemains.add(Bill);
                        }
                        // Set the Bill of Sales Process field to True to avaid this record to process next time
                        // Set the Bill of Sales Process Comment to blank
                        Bill.PROCESSED__c = true;
                        Bill.PROCESS_COMMENT__c = '';
                        Bill.UNIT_NUMBER__c = Vehicle.id;
                    }
                    else
                    {
                        Bill.PROCESS_COMMENT__c = 'Ryder Branch not found!';
                    }
                }
                else
                {
                    Bill.PROCESS_COMMENT__c = 'LOCATION CODE is not found!';
                }
            }
            else
            {
                Bill.PROCESS_COMMENT__c = 'Opportunity ID or Vehicle Ids are not found!';
            }
        }
        
        // If there are records found in the collection for Customer Branch than insert these and align the Vehicle to correct Customer Branch
        if(mCustomerBranchNew.size() > 0)
        {
            insert mCustomerBranchNew.values();
            for(Customer_Branch__c ObjCustomerBranch : mCustomerBranchNew.values())
            {
            	mCustomerBranch.put(ObjCustomerBranch.ext_customerbranch_id__c, ObjCustomerBranch);
            }
            for(UVS_Bill_of_Sale__c Bill : lUVS_Bill_of_SaleRemains)
            {
                Opportunity Opp = mOpp.get(Bill.OPPORTUNITYID__c);
                Vehicle__c Vehicle = mVehicle.get(Bill.UNIT_ID__c);
                Account Acc = null;                
                String sLocation = String.valueOf(Bill.SOLD_LOCATION_CODE__c);
                Ryder_Branch__c ObjRyderB = mRyderBranch.get(sLocation);
                
                if(Opp != null && Vehicle != null && ObjRyderB != null)
                {
                	Vehicle.Is_Available_For_Sale__c = false;
	                Vehicle.Sold_Flag__c = true;
	                Vehicle.Availability__c = '';
	                Vehicle.Account__c = Opp.AccountId;
	                Vehicle.Bill_of_Sale__c = Bill.Id;                
                    Acc = mAcc.get(Opp.AccountId);
                    if(Bill.SOLD_LOCATION_CODE__c != null && Acc != null)
                    {
                        String sCode = (Id)Acc.Id + '_' + ObjRyderB.Branch_Code__c;
                        if(mCustomerBranch.get(sCode) != null)
                        {
                            Vehicle.Customer_Branch__c = mCustomerBranch.get(sCode).Id;
                            lVehicle.add(Vehicle);
                        }
                    }
                }
            }
        }
        
        SavePoint SavePointObj = Database.setSavePoint();
        system.debug('-------lAcc-273->'+lAcc);
        system.debug('-------lOpp-274->'+lOpp);
        system.debug('-------lVehicle-275->'+lVehicle);
        system.debug('-------lCustomerBranchUpd-276->'+lCustomerBranchUpd);
        system.debug('-------lUVS_Bill_of_Sale-277->'+lUVS_Bill_of_Sale);
        system.debug('-------Customer_BranchUpdate-278->'+Customer_BranchUpdate);
        try
        {
            // Update Account, Opportunity, Vehicle and Bill of sales records.
            if(lAcc.size() > 0)
                update lAcc;
            if(lOpp.size() > 0)
                update lOpp;
            if(lVehicle.size() > 0)
                update lVehicle;
            if(lCustomerBranchUpd.size() > 0)
                update lCustomerBranchUpd;
            if(Customer_BranchUpdate.size() > 0)
            	update Customer_BranchUpdate;
            update lUVS_Bill_of_Sale;
        }
        catch(Exception Ex)
        {
            Database.rollback(SavePointObj);
            // get the email address
            String sEmailAddress = '';
            Global_Settings__c EmailAddress = Global_Settings__c.getValues('12');
            // if the custom settings is not null then get the value from settings and out in a local variable
            if(EmailAddress != null && EmailAddress.IsActive__c)
                sEmailAddress = EmailAddress.Value__c;        
            system.debug('-------sEmailAddress-303->'+sEmailAddress);
            if(sEmailAddress != '')
            {
                // Send Email to dev resource if there is any issue.
                Messaging.SingleEmailMessage MailObj = new Messaging.SingleEmailMessage();
                MailObj.setToAddresses(new String[] {sEmailAddress});
                MailObj.setSubject('Exception got in UVS_ProcessBillOfSales Batch');
                MailObj.setPlainTextBody(Ex.getmessage());
                system.debug('-------MailObj-310->'+MailObj);
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{MailObj});
            }
        }
    }
    global void finish(Database.BatchableContext BC)
    {
        // there is nothing needs to be done after the process completes
    }
}