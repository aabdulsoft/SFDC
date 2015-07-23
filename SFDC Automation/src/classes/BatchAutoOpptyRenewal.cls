/*
Ryder requires that opportunities are generated automatically for vehicles 9 months prior to the vehicle expiration date.  
Opportunities will be created for accounts & and assigned to owners based on the following rules:
1)  If the account related to the vehicle (via the customer-branch object) is a local account (account_classification__c = ‘Local’), 
the opportunity owner will be the account owner.
2)  If the account related to the vehicle (via the customer-branch object) is a national account (account_classification__c = ‘National’) 
or parent account (account_classification__c = ‘Coordinated’) and the accounts "centralized decision making' flag is checked, 
a single opportunity will be created with the national account owner as the opportunity owner.
3)  If the account related to the vehicle (via the customer-branch object) is a national or parent account and the accounts 
"centralized decision making" flag is not checked, two opportunities should be created, one for the national account owner and 
one for the customer/branch owner.

The Opportunity type field for these Opportunities will be set to “Renewal”.
The Opportunity account field will need to the set to the current account, 
The Opportunity stage field should be set to “Developing”
The Opportunity Close Date should be set to the earliest expiration date of the vehicles in the current grouping.
The Opportunity Name should be set to ‘Automated Renewal: ‘ + account.name + ‘ ( ‘ + close date + ‘) ’ + sam class of the current grouping.
*/

global class BatchAutoOpptyRenewal implements Database.Batchable<sObject>,  Database.Stateful{

    global final String DEFAULTSTAGENAME = 'Solution Hypothesis';

    public static DateTime NINE_MONTHS_AHEAD = Date.today().addmonths(9);
    public static DateTime TEN_MONTHS_AHEAD = Date.today().addmonths(10);
    
    public String queryString = 'Select v.unit__c, v.SAM_CLASS__c, v.PRODUCT_LINE__c, v.Product_name__c, v.PACKAGE_NUM__c, v.Name, v.Id, v.EXPIRATION_DATE__c, v.CUSTOMER_BRANCH__r.Ryder_HQ_Account__c, v.CUSTOMER_BRANCH__r.Id, v.CUSTOMER_BRANCH__c, v.Customer_Branch__r.Customer_Branch_Owner__c, v.rated_revenue__c, v.CurrencyIsoCode, v.Account__c, v.Account__r.id, v.Account__r.owner.id, v.Account__r.name, v.account__r.Account_Classification__c, v.account__r.Central_Decisionmaking__c, v.account__r.parentid, v.account__r.parent.id, v.account__r.parent.name, v.account__r.parent.owner.id, v.account__r.parent.Account_Classification__c, v.account__r.parent.Central_Decisionmaking__c, v.automatedRenewalCreated__c From Vehicle__c v where v.EXPIRATION_DATE__c >= '+ NINE_MONTHS_AHEAD.format('yyyy-MM-dd') + ' and  v.EXPIRATION_DATE__c < ' + TEN_MONTHS_AHEAD.format('yyyy-MM-dd') + ' and v.automatedRenewalCreated__c = false order by v.account__r.parent.id, v.account__r.id, v.Customer_Branch__r.Customer_Branch_Owner__c';

    private id ChildOpportunityRecordTypeID;
	private id StandardOpportunityRecordTypeID;
    
    private Account currentAccount;
    private List<Vehicle__c> lCurrentAccountVehicles;
    private Map<Integer, Opportunity> mnewOpportunities;
    private Map<Integer, List<Opportunity_split__c>> mlnewOpportunitySplits;
    private Map<Integer, List<OpportunityLineItem>> mlnewOpportunityLineItems;
    private Map<String,PriceBookEntry> mPriceBookEntriesUSD;
    private Map<String,PriceBookEntry> mPriceBookEntriesCAD;
    private Integer pk;
    
    
    /*
    * The start method is called at the beginning of a batch Apex job. Use the start method to collect the records or objects
    *    to be passed to the interface method execute.
    */
    global Database.Querylocator start(Database.BatchableContext bc){
        currentAccount = null;
        pk = 0;

        lCurrentAccountVehicles = new List<Vehicle__c>();
        mnewOpportunities = new Map<Integer, Opportunity>();
        mlnewOpportunitySplits = new Map<Integer, List<Opportunity_split__c>>();
        mlnewOpportunityLineItems = new Map<Integer, List<OpportunityLineItem>>();
        
        ChildOpportunityRecordTypeID = [select id from recordtype where name = 'Child Opportunity'][0].id;
        StandardOpportunityRecordTypeID = [select id from recordtype where name = 'Standard Opportunity'][0].id;
        
        populatePriceBookEntries();

        system.debug('queryString: ' + queryString);
        return Database.getQueryLocator( queryString );
    }
    
    /*
    * The execute method is called for each batch of records passed to the method.
    */
    global void execute(Database.BatchableContext bc,  List<sObject> scope){
        Vehicle__c v = null;
        integer i = 0;
        for ( sObject s : scope ){
            if ( s.getSObjectType() == Vehicle__c.sObjectType ){
				i++;
                v = (Vehicle__c) s;
                
                system.debug('+++++vehicle ' + i + ' ' + v);                

                if (currentAccount == null)
                    currentAccount = getTopLevelAccount(v);
                
                if (currentAccount == null)
                	system.debug('+++++current account == null - problem!');
               	else
               		system.debug('+++++current account:' + currentAccount);
                
                system.debug('+++++vehicle ' + i + ' toplevelaccount: ' + currentAccount);       

                if ( (getTopLevelAccount(v)).id != currentAccount.Id ){
                    //account changed, process current lCurrentAccountvehicles list into opportunity(s)
                    
                    system.debug('+++++Start processVehicleList');
                    processVehicleList();
                    system.debug('+++++End processVehicleList');
                    
                    lCurrentAccountVehicles.clear();
                    currentAccount = getTopLevelAccount(v);
                }
				
				system.debug('adding vehicle ' + i + ' to currentAccountvehicle list');
                lCurrentAccountvehicles.add ( v );
            }
        }
        system.debug('+++++Start processCurrentOpportunities');
        processCurrentOpportunities();
        system.debug('+++++End processCurrentOpportunities');
    }
    
    /*
      The finish method is called after all batches are processed.
      4)  Create a group named “Automated opportunity renewal admins”, in the finish method, 
        send an email to the users listed in this group, reporting on the start/stop time of the batch job, 
        number of opportunities created, & any additional metrics identified.
    */
    global void finish(Database.BatchableContext bc){ 
        processVehicleList();
        processCurrentOpportunities();
    }
    
    
    private void populatePriceBookEntries(){
        //get the id of the standard pricebook
        List<Pricebook2> lpb2 = [SELECT id from Pricebook2 where isStandard = true];
        if ( lpb2.size()!=1 ){
            //error condition -- should never get here since there should only ever be 1 pricebook2 entry with isStandard = true
        }
        Pricebook2 spb = lpb2.get(0);

        //get the pricebook entries for the standard pricebook
        mPriceBookEntriesUSD = new Map<String,PriceBookEntry>(); 
        for( PriceBookEntry pbe : [select Id, UnitPrice, Name from PriceBookEntry where pricebook2id = :spb.id and currencyisocode = 'USD'] ){
            mPriceBookEntriesUSD.put(pbe.name, pbe);
        }

        mPriceBookEntriesCAD = new Map<String,PriceBookEntry>(); 
        for( PriceBookEntry pbe : [select Id, UnitPrice, Name from PriceBookEntry where pricebook2id = :spb.id and currencyisocode = 'CAD'] ){
            mPriceBookEntriesCAD.put(pbe.name, pbe);
        }

        return;
    }
    
    private string createKey(Vehicle__c v){
		if (v.sam_class__c.indexOf('-') == -1){
			system.debug('sam class format invalid');
			return null;
		}
		
		String s = v.sam_class__c.split('-',2)[0];
		s=s.trim();
		
		return (v.product_line__c + '-' + s + '-Used');
    }
    
    private Double getPriceBookEntryAmount( Vehicle__c v ){
        Double retVal = null;
        String key = createKey(v);
        if (key == null) return null;
        
        if ( v.CurrencyISOCode == 'USD' ){
        	if (mPriceBookEntriesUSD.containsKey(key))
            	retVal = mPriceBookEntriesUSD.get( key ).unitprice;    
        }else{
        	if (mPriceBookEntriesCAD.containsKey(key))
            	retVal = mPriceBookEntriesCAD.get( key ).unitprice;
        }
        return retVal;
	}
    
    private String getPriceBookEntryID( Vehicle__c v ){
        String retVal = null;
        String key = createKey(v);
        if (key == null) return null;
        
        if ( v.CurrencyISOCode == 'USD' ){
        	if (mPriceBookEntriesUSD.containsKey(key))
            	retVal = mPriceBookEntriesUSD.get( key ).id;           
        }else{
        	if (mPriceBookEntriesCAD.containsKey(key))
            	retVal = mPriceBookEntriesCAD.get( key ).id;
        }
        return retVal;
    }
    
    private void processNationalCentralizedAccount(){
		System.debug('+++++start processNationalCentralizedAccount');
        //determine total rated revenue to generate split amount
        Double totalRatedRevenue = 0;
        
        for ( Vehicle__c v : lcurrentAccountVehicles ){
        	if (v.Rated_Revenue__c!=null)
            	totalRatedRevenue += v.Rated_Revenue__c;
        }

        List<OpportunityLineItem> lOppLineItems = new List<OpportunityLineItem>();
        List<Opportunity_Split__c> loppSplits = new List<opportunity_Split__c>();
        Opportunity_Split__c os = new Opportunity_Split__c();
        os.sales_team_member__c = currentAccount.owner.id;
        os.split_percentage__c = RyderGlobalVariables.NATIONAL_CENTRALIZED_ACCOUNT_OWNER_SPLIT_PERCENTAGE;
        loppSplits.add( os );

        Double branchRatedRevenue = 0;
        id currentCustomerBranchOwnerId = null;
        OpportunityLineItem li = null;

        for ( Vehicle__c v : lcurrentAccountVehicles ){
        	
            if ( currentCustomerBranchOwnerId == null )		//only applicable the 1st time through the loop
                currentCustomerBranchOwnerId = v.CUSTOMER_BRANCH__r.Customer_Branch_Owner__c;

			//if the currentCustomerBranchOwnerId is different from the current vehicle CustomerBranchOwnerId, create a new split for the current owner
            if ( currentCustomerBranchOwnerId != v.CUSTOMER_BRANCH__r.Customer_Branch_Owner__c ){
                os = new Opportunity_Split__c();
                os.sales_team_member__c = currentCustomerBranchOwnerId;
                os.split_percentage__c = branchRatedRevenue/totalRatedRevenue * (1 - RyderGlobalVariables.NATIONAL_CENTRALIZED_ACCOUNT_OWNER_SPLIT_PERCENTAGE/100);
                loppSplits.add( os );
                branchRatedRevenue = 0;
                currentCustomerBranchOwnerId = v.Customer_Branch__r.Customer_Branch_Owner__c;
            }

			//create a new line item for the vehicle
            li = new OpportunityLineItem();
            li.PricebookEntryId = getPriceBookEntryID(v);					//ADD ERROR HANDLING
            li.Quantity = 1;
            li.Old_Revenue__c = v.Rated_Revenue__c;
            //li.Unit_Number__c = v.name;
            li.customer_branch__c = v.CUSTOMER_BRANCH__c;
            li.transaction_type__c = 'Term Extension';
            li.unitprice=getPriceBookEntryAmount(v);				//ADD ERROR HANDLING
            lOppLineItems.add( li );
    		
    		//accumulate the branchRatedRevenue
    		if (v.Rated_Revenue__c!=null)
            	branchRatedRevenue+=v.Rated_Revenue__c;
        }

		//create the final opportunity split:
		os = new Opportunity_Split__c();
		os.sales_team_member__c = currentCustomerBranchOwnerId;
		os.split_percentage__c = branchRatedRevenue/totalRatedRevenue * .5;
		loppSplits.add( os );

		//add the opportunity splits and line item lists to our maps 
        mlnewOpportunitySplits.put( pk, loppSplits );
        mlnewOpportunityLineItems.put( pk, lOppLineItems );

		System.debug('+++++end processNationalCentralizedAccount');
        return;
    }
    
    private void processNationalDecentralizedAccount(Opportunity parentOp){
        System.debug('+++++start processNationalDecentralizedAccount');
        List<OpportunityLineItem> lOppLineItems = new List<OpportunityLineItem>();
        
        //create the split for the parent account
        List<Opportunity_Split__c> loppSplits = new List<opportunity_Split__c>();
        Opportunity_Split__c os = new Opportunity_Split__c();
        os.sales_team_member__c = currentAccount.owner.id;
        os.split_percentage__c = 100;
        loppSplits.add( os );
        mlnewOpportunitySplits.put( pk, loppSplits );

        //save the national account owner since we'll need to apply it to the splits of all the sub opportunities.
        id nationalOwnerId = currentAccount.owner.id;

        id currentCustomerBranchOwnerId = null;
        Account currentLocalAccount = null;
        OpportunityLineItem li = null;
        Date earliestExpDate = null;
        
        System.debug('+++++num vehicles: '+ lcurrentAccountVehicles.size());
        System.debug('+++++vehicles: '+ lcurrentAccountVehicles);

        loppSplits = new List<opportunity_Split__c>();

        for ( Vehicle__c v : lcurrentAccountVehicles ){
            //get initial values 1st time through
            if ( currentCustomerBranchOwnerId == null ){
                currentCustomerBranchOwnerId = v.Customer_Branch__r.Customer_Branch_Owner__c;
                currentLocalAccount = v.account__r;
                earliestExpDate = v.expiration_date__c;
            }

            //if the branch owner has changed, create the opportunity, process the current lineopps & create the splits 
            if ( currentCustomerBranchOwnerId != v.Customer_Branch__r.Customer_Branch_Owner__c ){
                //increment the counter
                pk++;

                //create a child opportunity -- NEED TO FIX ExpDate
                Opportunity opp = createOpportunity( currentCustomerBranchOwnerId, currentLocalAccount.ID, DEFAULTSTAGENAME, earliestExpDate, currentLocalAccount.name + ' ' + date.today() + ' Automatic Renewal Opportunity');
                opp.recordtypeid = ChildOpportunityRecordTypeID;
                opp.parent_opportunity__c = parentOp.id;
                opp.Estimated_Proposal_Date__c = getEarliestExpDate( lcurrentAccountVehicles );
                mnewOpportunities.put( pk, opp );

                //create the 2 splits:
                os = new Opportunity_Split__c();    
                os.sales_team_member__c = currentCustomerBranchOwnerId;
                os.split_percentage__c = 50;
                loppSplits.add( os );
                os = new Opportunity_Split__c();    
                os.sales_team_member__c = nationalOwnerId;
                os.split_percentage__c = 50;
                loppSplits.add( os );
                mlnewOpportunitySplits.put( pk, loppSplits );
                mlnewOpportunityLineItems.put( pk, lOppLineItems );
                lOppLineItems = new List<OpportunityLineItem>();
                loppSplits = new List<opportunity_Split__c>();

                currentCustomerBranchOwnerId = v.Customer_Branch__r.Customer_Branch_Owner__c;
                currentLocalAccount = getTopLevelAccount(v);
                earliestExpDate = v.expiration_date__c;
            }

            if ( v.expiration_date__c < earliestExpDate )
                earliestExpDate = v.expiration_Date__c;

            li = new OpportunityLineItem();
            li.PricebookEntryId = getPriceBookEntryID(v);						//ADD ERROR HANDLING
            li.Quantity = 1;
            li.Old_Revenue__c = v.Rated_Revenue__c;
            //li.Unit_Number__c = v.name;
            li.unitprice= getPriceBookEntryAmount(v);					//ADD ERROR HANDLING
            li.customer_branch__c = v.CUSTOMER_BRANCH__c;
            li.transaction_type__c = 'Term Extension';
            lOppLineItems.add( li );
        }

        //create the opportunity/splits&process line items for the final vehicle/s processed in the loop
        pk++;
        Opportunity opp = createOpportunity( currentCustomerBranchOwnerId, currentLocalAccount.ID, DEFAULTSTAGENAME, earliestExpDate, currentLocalAccount.name + ' ' + date.today() + ' Automatic Renewal Opportunity');
        opp.Estimated_Proposal_Date__c = getEarliestExpDate( lcurrentAccountVehicles );
        opp.parent_opportunity__c = parentOp.id;
        opp.recordtypeid = ChildOpportunityRecordTypeID;

        mnewOpportunities.put( pk, opp );

        //create the 2 splits:
        os = new Opportunity_Split__c();    
        os.sales_team_member__c = currentCustomerBranchOwnerId;
        os.split_percentage__c = 50;
        loppSplits.add( os );
        os = new Opportunity_Split__c();    
        os.sales_team_member__c = nationalOwnerId;
        os.split_percentage__c = 50;
        loppSplits.add( os );
        mlnewOpportunitySplits.put( pk, loppSplits );
        mlnewOpportunityLineItems.put( pk, lOppLineItems );

		System.debug('+++++end processNationalDecentralizedAccount');
        return; 
    }
    
    private void processLocalAccount(){
		System.debug('+++++start processLocalAccount');
        List<Opportunity_Split__c> loppSplits = new List<opportunity_Split__c>();
        Opportunity_Split__c os = new Opportunity_Split__c();
        os.sales_team_member__c = currentAccount.owner.id;
        os.split_percentage__c = 100;
        loppSplits.add( os );
        mlnewOpportunitySplits.put( pk, loppSplits );

        List<OpportunityLineItem> lOppLineItems = new List<OpportunityLineItem>();
        for ( Vehicle__c v : lcurrentAccountVehicles ){
            OpportunityLineItem li = new OpportunityLineItem();
            li.PricebookEntryId = getPriceBookEntryID( v );				//ADD ERROR HANDLING
            li.Quantity = 1;
            li.Old_Revenue__c = v.Rated_Revenue__c;
            //li.Unit_Number__c = v.name;
            li.customer_branch__c = v.CUSTOMER_BRANCH__c;
            
            li.transaction_type__c = 'Term Extension';
            li.unitprice = getPriceBookEntryAmount(v);		//ADD ERROR HANDLING
            lOppLineItems.add( li );
        }

        mlnewOpportunityLineItems.put( pk, lOppLineItems );

		System.debug('+++++end processLocalAccount');
        return;
    }
    
    private void processVehicleList(){
        //create opportunities (incl. line items & splits) for vehicles in the current account
        if ( lcurrentAccountVehicles.size() != 0 ){

            //create the parent opportunity
            Opportunity opp = createOpportunity( currentAccount.ownerid, currentAccount.id, DEFAULTSTAGENAME, getEarliestExpDate(lcurrentAccountVehicles), currentAccount.name + ' ' + date.today() + ' Automatic Renewal Opportunity');
            opp.Estimated_Proposal_Date__c = getEarliestExpDate( lcurrentAccountVehicles );
            
            system.debug('pk: ' + pk );
            system.debug('opportunity created: ' + opp);
            mnewOpportunities.put( pk, opp );

            if ( currentAccount.Account_Classification__c == 'National' && currentAccount.Central_Decisionmaking__c ){
                processNationalCentralizedAccount();
            }else if ( currentAccount.Account_Classification__c == 'National' && !currentAccount.Central_Decisionmaking__c ){
                opp.recordtypeid = ChildOpportunityRecordTypeID;
                processNationalDecentralizedAccount(opp);
            }else{  //treat everything else as a local account
                processLocalAccount();
            }

			//mark current vehicles as processed
            for (Vehicle__c v : lcurrentAccountVehicles){
            	v.automatedRenewalCreated__c = true;	
            }
            upsert lcurrentAccountVehicles;
            
            //clear out the current vehicle list
            lcurrentAccountVehicles.clear();
            pk++;
        }
        return;
    }
    
    private void processCurrentOpportunities(){
        //add the new opportunities/splits/lineitems
        //TO DO - ADD ERROR HANDLING FOR INSERTS
        if (mnewOpportunities.size() >0) {
    try{
        system.debug('+++++mnewOpportunities: ' + mnewOpportunities.values());
        System.debug('mnewOpportunities.keySet()' + mnewOpportunities.keySet());
        system.debug('+++++mlnewOpportunitySplits: '+ mlnewOpportunitySplits.values());
        System.debug('mlnewOpportunitySplits.keySet()' + mlnewOpportunitySplits.keySet());
        system.debug('+++++mlnewOpportunityLineItems: '+ mlnewOpportunityLineItems.values());
        System.debug('mlnewOpportunityLineItems.keySet()' + mlnewOpportunityLineItems.keySet());
                
        insert mnewOpportunities.values();
        
        //assign opportunityids to opportunitysplits & opportunityLineItems
        Set <Integer> oppKeys = mnewOpportunities.keySet();

        Opportunity tmpOpp = null;
        List<Opportunity_Split__c> los = new List<Opportunity_Split__c>();
        List<OpportunityLineItem> loli = new List<OpportunityLineItem>();
        
        for (Integer i : oppKeys){
            tmpOpp = mnewOpportunities.get(i);
            
            for ( Opportunity_Split__c oppsplit : mlnewOpportunitySplits.get(i) ){
                oppsplit.opportunity__c = tmpOpp.id;
                los.add(oppsplit);  
            }

            if (mlnewOpportunityLineItems.containsKey(i))
                for ( OpportunityLineItem oli : mlnewOpportunityLineItems.get(i) ){
                    oli.opportunityid = tmpOpp.id;
                    loli.add( oli );
                }
        }

        System.debug('list of opportunity splits: '+los);
        System.debug('list of opportunitylineitems: '+loli);
        insert los;
        insert loli;

        //clear out the lists for the next trip through the execute method
        }catch(exception e){
            system.debug('error: ' + e);
        }finally{
            mnewOpportunities.clear();
            mlnewOpportunitySplits.clear();
            mlnewOpportunityLineItems.clear();
        }
        }
        return;
    }
    
    private Account getTopLevelAccount(Vehicle__c v){
        system.debug('getTopLevelAccount vehicle: ' + v);
        system.debug('getTopLevelAccount vehicle account: ' + v.account__r);
        if (v.account__r.parentid==null)
        	system.debug('getTopLevelAccount v.account__r.parentid==null');
        else
        	system.debug('getTopLevelAccount v.account__r.parentid: ' + v.account__r.parentid);

        if ( v.account__r.parentid == null)
            return v.account__r;
        else
            return v.account__r.parent;
    }
    
    private Opportunity createOpportunity(ID ownerid, ID accountid, String stagename, date closedate, string name){
        Opportunity opp = new Opportunity();
        opp.ownerid = ownerid;
        opp.accountid = accountid;
        opp.stagename = stagename;
        opp.closedate = closedate;
        opp.name = name;
        opp.AutomaticBatchOpportunity__c = true;
        opp.RecordTypeId = StandardOpportunityRecordTypeID;
        return opp;
    }
    
    private date getEarliestExpDate(list<Vehicle__c> lv){

        date d = null;
        
        for(Vehicle__c v : lv){
            if ( d == null || v.expiration_date__c < d )
                d = v.expiration_date__c;
        }
    
        return d;
    }
    
    
}