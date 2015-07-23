public with sharing class CaseUtil {
     
     //This Static flag is used to avoid Recursive Trigers. 
    //Created on 05/22/2012 Baskar Venugopal.
     public static boolean isAlreadyTriggered = false;
    public static List<RyderEmail> EmailMessages = new List<RyderEmail>();
     /*
    *   Associate account if customer branch is populated.
    *   Associate Customer branch and account if vehicle is populated.
    *   Associate Account and Customer branch if FIS is populated.
    */
    public static void associateAccountCustomerBranchInfo(List<Case> caseList) {
        List<Id> vehicleIdList = new List<Id>();
        List<Id> customerBranchIdList = new List<Id>();
        List<Id> fisAccountIdList = new List<Id>();
        system.debug(LoggingLevel.INFO, '+++++++++++++++++++++ caseList:' + caseList);
        if (caseList != null) {
            for(Case temp: caseList) {
                //Select c.Vehicle_Number__c, c.Id, c.Customer_Branch__c, c.AccountId From Case c
                if (temp.Vehicle_Number__c != null) {
                    vehicleIdList.add(temp.Vehicle_Number__c);
                }
                if (temp.Customer_Branch__c!= null) {
                    customerBranchIdList.add(temp.Customer_Branch__c);
                }
                if (temp.FIS_Account__c != null) {
                    fisAccountIdList.add(temp.FIS_Account__c);
                }
            }
            
            System.debug(LoggingLevel.INFO, '+++++++++++++++++++++ vehicleIdList:' + vehicleIdList);
            System.debug(LoggingLevel.INFO, '+++++++++++++++++++++ customerBranchIdList:' + customerBranchIdList);
            System.debug(LoggingLevel.INFO, '+++++++++++++++++++++ fisAccountIdList:' + fisAccountIdList);
            
            Map<Id, Id> customerBranchToAccountMap = getCustomerBranchToAccountMap(customerBranchIdList);
            System.debug(LoggingLevel.INFO, '+++++++++++++++++++++ customerBranchToAccountMap:' + customerBranchToAccountMap);
            
            Map<Id, String> vehicleToCustomerBranchAndAccountMap = getVehicleToCustomerBranchAndAccountMap(vehicleIdList);
            System.debug(LoggingLevel.INFO, '+++++++++++++++++++++ vehicleToCustomerBranchAndAccountMap:' + vehicleToCustomerBranchAndAccountMap);
            
            Map<ID, FIS_Account__c> fisAccountMap = new Map<Id, FIS_Account__c> ([Select f.Id, f.Customer_Branch__c, f.Ryder_HQ_ID__c From FIS_Account__c f where f.id in: fisAccountIdList]);
            
            // now update appropriate fields
            for(Case temp: caseList) {
                if (temp.FIS_Account__c != null) {
                    FIS_Account__c fisAccount  = fisAccountMap.get(temp.FIS_Account__c);
                    if (fisAccount != null && fisAccount.Ryder_HQ_ID__c != null && temp.AccountId == null) {
                        temp.AccountId = fisAccount.Ryder_HQ_ID__c;
                    }
                    if (fisAccount != null && fisAccount.Customer_Branch__c != null && temp.Customer_Branch__c == null) {
                        temp.Customer_Branch__c = fisAccount.Customer_Branch__c;
                    }
                }
                if (temp.Customer_Branch__c != null) {
                    system.debug(LoggingLevel.INFO, '+++++++++++++++++++++ temp.Customer_Branch__c:' + temp.Customer_Branch__c);
                    Id accountId = customerBranchToAccountMap.get(temp.Customer_Branch__c);
                    if (accountId != null && temp.AccountId == null) {
                        temp.AccountId = accountId;
                    }
                }
                
                if (temp.Vehicle_Number__c != null) {
                    String customerBranchAccountId = vehicleToCustomerBranchAndAccountMap.get(temp.Vehicle_Number__c);
                    String[] idList = customerBranchAccountId.split(':', 2);
                    system.debug(LoggingLevel.INFO, '+++++++++++++++++++++ idList:' + idList);
                    if (idList != null && idList.size() == 2) {
                        if (idList[0] != null && temp.Customer_Branch__c == null) {
                           temp.Customer_Branch__c = idList[0];
                        }
                        if (idList[1] != null && temp.AccountId == null) {
                           temp.AccountId = idList[1];
                        }
                    }
                }
                
            }
        }
        system.debug(LoggingLevel.INFO, '+++++++++++++++++++++ after update caseList:' + caseList);
    }

    // get map of customerBranch to Account
    public static Map<Id, ID> getCustomerBranchToAccountMap(List<Id> customerBranchIdList) {
        List<Customer_Branch__c> customerBranchList = [select c.Ryder_HQ_Account__c, c.Id from Customer_Branch__c c where c.id in: customerBranchIdList];
        Map<Id, ID> customerBranchToAccountMap = new Map<Id, Id>();
        if (customerBranchList != null) {
            for (Customer_Branch__c temp: customerBranchList) {
                customerBranchToAccountMap.put(temp.id, temp.Ryder_HQ_Account__c);
            }
        }
        return customerBranchToAccountMap;
    }
    
    // get map of vehicle id to customerBranch and Account
    public static Map<Id, String> getVehicleToCustomerBranchAndAccountMap(List<Id> vehicleIdList) {
        List<Vehicle__c> vehicleList = [Select v.Id, v.CUSTOMER_BRANCH__r.Ryder_HQ_Account__c, v.CUSTOMER_BRANCH__r.Id, v.CUSTOMER_BRANCH__c From Vehicle__c v where v.id in: vehicleIdList];
        Map<Id, String> vehicleToCustomerBranchAndAccountMap = new Map<Id, String>();
        if (vehicleList != null) {
            for (Vehicle__c temp: vehicleList) {
                Customer_Branch__c customerBranch = temp.CUSTOMER_BRANCH__r;
                if (customerBranch != null) {
                    vehicleToCustomerBranchAndAccountMap.put(temp.id, customerBranch.id + ':' + customerBranch.Ryder_HQ_Account__c);
                }
            }
        }
        return vehicleToCustomerBranchAndAccountMap;
    }

    //This method will construct Email Message and concatenates the Email properties using the delimiter '###'.
    //The Email properties wil be added as specified below.
    //FromID ### Email Ids ### Email Subject ### Message ### Attachment ### Type (HTML,text etc) ### Caller.
    public static String ConstructMail(List<Case> newCases)
    {
        RyderEmail ryderMail = new RyderEmail();
        system.debug('In Class');
        string htmlBody = '';
        string htmlTitle='';
        string acctName='';
        string creatorEmails = '';
        string emailMsg = '';
        String idList='';
        Map<String,String> mailList= new Map<String,String>();
        htmlTitle = '<html><head><title>Duplicate Cases</title></head><body><table><tr><td><table id="1" ><tr><td colspan="4">';
        system.debug('Baskar New Cases Count' + newCases.size());
        
        system.debug('Baskar : Before for New cases loop');
            //Creating the HTML Body 
        htmlBody = htmlBody + '<table border="1"><tr>';
        htmlBody = htmlBody + '</td><td colspan="3">';
            //htmlBody = htmlBody + '</td><td>';
        htmlBody = htmlBody + '<b>Major Category </b> ' ;
        htmlBody = htmlBody + '</td><td colspan="3">';
        htmlBody = htmlBody + '<b>Sub Category </b> ';
        htmlBody = htmlBody + '</td><td colspan="3">';
        htmlBody = htmlBody + '<b>Created On </b> ' ;
        htmlBody = htmlBody + '<td colspan="3">';
        htmlBody = htmlBody + '<b>Case Number </b> ';
        htmlBody = htmlBody + '<td colspan="3">';
        htmlBody = htmlBody + '<b>Root Cause </b> ';
        htmlBody = htmlBody + '<td colspan="3">';
        htmlBody = htmlBody + '<b>Description </b> ';
        htmlBody = htmlBody + '<td colspan="3">';
        htmlBody = htmlBody + '<b>Status </b> ';
        htmlBody = htmlBody + '</td>';
        htmlBody = htmlBody + '</tr>';
        for(Case caseObj: newCases)
        {
            acctName = caseObj.Account.Name;
            system.debug(' Baskar: Created by Email ' + caseObj.CreatedBy.Email);
            htmlBody = htmlBody + '<tr>';       
            mailList.put(caseObj.CreatedBy.Email, caseObj.CreatedBy.Email);
            htmlBody = htmlBody + '<td colspan="3">';
            htmlBody = htmlBody +  caseObj.Major_Category__c;
            htmlBody = htmlBody + '</td><td colspan="3">';
            htmlBody = htmlBody +  caseObj.Subcategory__c;
            htmlBody = htmlBody + '</td><td colspan="3">';
            htmlBody = htmlBody +  caseObj.CreatedDate;
            htmlBody = htmlBody + '</td><td colspan="3">';
            htmlBody = htmlBody +  caseObj.CaseNumber;
            htmlBody = htmlBody + '</td><td colspan="3">';
            htmlBody = htmlBody +  caseObj.Root_Cause__c;
            htmlBody = htmlBody + '</td><td colspan="3">';
            htmlBody = htmlBody +  caseObj.Description;
            htmlBody = htmlBody + '</td><td colspan="3">';
            htmlBody = htmlBody +  caseObj.Status;
            htmlBody = htmlBody + '</td>';
            htmlBody = htmlBody + '</tr>';
                
        }
        
        system.debug('creator email :'+ mailList);
        String[] idsFromConfig = RyderConfig__c.getOrgDefaults().Duplicate_Case_Email_Recipient__c.split(',');
        for(integer i=0;i<idsFromConfig.size(); i++)
        {
            if(!mailList.ContainsKey(idsFromConfig[i]))
            {
                mailList.put(idsFromConfig[i],idsFromConfig[i]);
            }
        }
        system.debug('mail ids from Config' + idsFromConfig);
        integer mCount =1;
        idList = EmailUtil.PrepareMailIds(mailList.values());
        system.debug('email ids : ' + idList);
        htmlBody = htmlBody + '</table>';
        htmlBody = htmlBody + '</tr></table></td></tr></table></table></body></html>';
        htmlTitle = htmlTitle + '<b>The following Cases already created for the same issue. For the Account: ' + acctName  +'</br>';
        htmlTitle = htmlTitle + '</br></br></tr><tr>';
        htmlBody = htmlTitle + htmlBody;
        emailMsg = '' + '###' ; // From id
        emailMsg = emailMsg + idList + '###' ; //Concatenate Email - TO ids.
        emailMsg = emailMsg + 'Duplicate Cases' + '###' ; // Concatenate Email - Subject.
         //Concatenate Email Message.
        emailMsg = emailMsg + 'Attached  is the List of Duplicate Cases created for the same issue.' + '###' ;
        emailMsg = emailMsg + htmlBody + '###' ;//Concatenate Email Attachment.
        emailMsg = emailMsg + 'HTML' + '###' ; // Concatenate Email Type.
        emailMsg = emailMsg + 'CASE'  ; // Concatenate Email - Caller.
        system.debug('email Message: ' + emailMsg);
        return emailMsg;                
    }
    
    // test method
    static testMethod void test_associateAccountCustomerBranchInfo(){
        Account acct = TestUtil.createAccount('Ryder FMS Parent Account', 'Customer');
        insert acct;
        Contact cont = TestUtil.createContact(acct.Id);
        insert cont;
        Customer_Branch__c cb = new Customer_Branch__c();
        cb.Name = 'test branch';
        cb.Ryder_HQ_Account__c = acct.Id;
        insert cb;
        Vehicle__c veh = new Vehicle__c();
        veh.Account__c = acct.Id;
        veh.CUSTOMER_BRANCH__c = cb.id;
        veh.Ask_Price__c = 20000.0;
        insert veh;
        Case case1 = new Case();
        case1.Vehicle_Number__c = veh.id;
        case1.CUSTOMER_BRANCH__c = cb.id;
        case1.ContactId =cont.id;
        insert case1;
        Case caseResult = [Select c.Vehicle__c, c.FIS_Account__c, c.Customer_Branch__c, c.ContactId, c.AccountId From Case c where c.id =: case1.Id];
        //system.assertNotEquals(null, caseResult.accountId);
    }
     static testMethod void testConstructMail() {
        List<Case> allCases = new List<Case>();
        Account acct = TestUtil.createAccount('Ryder FMS Parent Account', 'Customer');
        insert acct;
        Contact con = TestUtil.createContact(acct.Id);       
        insert con;
        
        Case caseOne = new Case();
        caseOne.ContactId = con.Id;
        //caseOne.ContactEmailId = 'test1@abc.com';
        Case caseTwo = new Case();
       // caseTwo.ContactEmail = 'test2@abc.com';
        caseTwo.ContactId = con.Id;        
        
        allCases.add(caseOne);
        allCases.add(caseTwo);
        
       // insert allCases;
        try {
            CaseUtil.ConstructMail(allCases);
        } catch(Exception e){
            
        }
    }
    /*
    static testMethod void testEmailDuplicateCase() {
        Case caseOne = new Case();
        Case caseTwo = new Case();
        Case caseThree = new Case();
        List<Case> allCases = new List<Case>();
        allCases.add(caseOne);
        allCases.add(caseTwo);
        
        List<Case> newCases = new List<Case>();
        
        newCases.add(caseThree);
        
        insert allCases;
        insert newCases;
        
        EmailDuplicateCase(allCases, newCases);
    }
    */
}