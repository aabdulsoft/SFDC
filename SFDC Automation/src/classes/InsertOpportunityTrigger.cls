public with sharing class InsertOpportunityTrigger {

    /*  
    *   Create an Opportunity Split object to maintain Opportunity split data (this object has been created already).
    *   Create an after insert trigger on the Opportunity object which will automatically create default Opportunity 
        Split objects according to the following logic:
        •       If the account related to the Opportunity is a local account (account_classification__c = ‘Local’), 
                create a single Opportunity_split__c object, assign the opportunity owner to the Sales_Team_Member__c field & 
                set the split_percentage__c value to 100% and the opportunity__c field to the opportunity.
        •       If the account related to the Opportunity is a national account (account_classification__c = ‘National’) 
                or parent account (account_classification__c = ‘Coordinated’), create two opportunity_split__c objects, 
                set the split_percentage__c value to 50% in each, the Opportunity__c field to the opportunity.  
                Assign the Sales_Team_Member__c of one object to the opportunity owner and the Sales_Team_Member__C field of the 
                other object to the owner of the national or parent account (the owner of the accounts parent account field).
    */
    public static void insertOpportunitySplit(Map<Id,Opportunity> insertedOpportunityMap) {
        
        List<Id> accountId = new List<Id>();
        // create accountId list
        Set<Id> opptyIds = new Set<Id>();//insertedOpportunityMap.keySet();
        // Code added to remove UVS and Rental Opportunities from further Processing
        // Start
        String sRecordTypeIdToExclude = '';
        Global_Settings__c RecordTypeOpportunity = Global_Settings__c.getValues('10');
        // if the custom settings is not null then get the value from settings and out in a local variable
        if(RecordTypeOpportunity != null && RecordTypeOpportunity.IsActive__c && RecordTypeOpportunity.Value__c != null)
        {
            List<String> lRecordTypeIds = RecordTypeOpportunity.Value__c.split(',');
            for(String sRecordType : lRecordTypeIds)
            {
                sRecordTypeIdToExclude += sRecordType.split('#')[1] + ',';
            }
        }
        // End
        for (Opportunity oppty : insertedOpportunityMap.values())
        {
           if(oppty.RecordTypeId != null && !sRecordTypeIdToExclude.contains(oppty.RecordTypeId))
                opptyIds.add(oppty.Id);
        }
        for (Id opptyId: opptyIds)
        {
            Opportunity oppty = insertedOpportunityMap.get(opptyId);
            accountId.add(oppty.accountId);
        }
        
        map<Id,Account> accounts = new map<Id, Account>([Select a.Id, a.parentId, a.parent.ownerid, a.Account_Classification__c, a.ownerId, a.Central_Decisionmaking__c From Account a where a.id in: accountId]);
        system.debug(LoggingLevel.INFO, '++++++ Accounts associated with Opportunity: ' + accounts);
        // Create map of accountid and account classifications
        Map<Id,String> accountIdToClassificationMap = new Map<Id, String>();
        //create map of accountId and ownerId
        Map<Id,Id> accountIdToOwnerIdMap = new Map<Id, Id>();
        Map<Id, Id> accountIdToParentIdMap = new Map<Id,Id>();
        List<Id> parentAccountIds = new List<Id>();
        for (Account acct: accounts.values()) {
            accountIdToClassificationMap.put(acct.Id, acct.Account_Classification__c);
            accountIdToOwnerIdMap.put(acct.Id, acct.ownerId);
            accountIdToParentIdMap.put(acct.Id, acct.parentId);
            parentAccountIds.add(acct.parentId);
        }
        system.debug(LoggingLevel.INFO, '++++++ accountIdToClassificationMap associated with Opportunity: ' + accountIdToClassificationMap);
        //Get all parent accountId information
        Map<Id,Account> parentAccounts = new Map<Id, Account>([Select a.Id, a.ownerId From Account a where a.id in: parentAccountIds]);
        
        system.debug(LoggingLevel.INFO, '++++++ parent acct ' + parentAccounts);
        
        //Get Insurance Sales profile
        Profile insSalesProfile = [SELECT Id FROM Profile WHERE Name = 'Insurance Sales'];
        
        //Select o.Split_Percentage__c, o.Sales_Team_Member__c, o.Opportunity__c, o.Name From Opportunity_Split__c o
        List<Opportunity_Split__c> opptysplits = new List<Opportunity_Split__c>();
        
        String acctClassification = '';
        for (Id opptyId: opptyIds) {
            Opportunity oppty = insertedOpportunityMap.get(opptyId);
            
            system.debug(LoggingLevel.INFO, '++++++ Oppty created: ' + opptyId);
            
            
            
            if (!oppty.AutomaticBatchOpportunity__c){
                Opportunity_Split__c split1 = new Opportunity_Split__c();
                Opportunity_Split__c split2 = new Opportunity_Split__c();
                split1.Opportunity__c = oppty.Id;
                split2.Opportunity__c = oppty.Id;
                acctClassification = accountIdToClassificationMap.get(oppty.accountId);
                
                system.debug(LoggingLevel.INFO, '====== acct Classification: ' + acctClassification);

                User userProfileId = [SELECT ProfileId FROM User WHERE Id = :oppty.OwnerId];
                               
                if (userProfileId.ProfileId == insSalesProfile.Id) {
                    //Note: This feature was added as part of QC 924;
                    split1.Sales_Team_Member__c = oppty.OwnerId;
                    split1.Split_Percentage__c = 100;
                    opptysplits.add(split1);
                }
                else if (acctClassification == 'Local') {
                    if (oppty.Automatic_Renewed__c == true){
                         //We are inserting the split for National Centralized Renewal                  
                         //
                    }
                    else
                    {
                    split1.Sales_Team_Member__c = oppty.OwnerId;
                    split1.Split_Percentage__c = 100;
                    opptysplits.add(split1);
                    }
                } 
                else if (acctClassification == 'National' && oppty.Automatic_Renewed__c == true && accounts.get(oppty.accountId).Central_Decisionmaking__c){
                   //We are inserting the split for National Centralized Renewal                  
                   //
                } 
                              
                else if (acctClassification == 'National') {
                    if (accounts.get(oppty.accountId).Central_Decisionmaking__c){
                        split1.Sales_Team_Member__c = accounts.get(oppty.accountId).ownerId;
                        split1.Split_Percentage__c = 100;
                        opptysplits.add(split1);
                    }else{// national account w/o central decisionmaking
                        //check to see if the opportunity owner & account owner are the same, if they are, there is only 1 split
                        if (oppty.OwnerId == accounts.get(oppty.accountid).ownerid){
                            split1.Sales_Team_Member__c = oppty.OwnerId;
                            split1.Split_Percentage__c = 100;
                            opptysplits.add(split1);
                        }else{
                            //the opportunity owner & account owner are different, so create 2 splits.
                            split1.Sales_Team_Member__c = oppty.OwnerId;
                            split1.Split_Percentage__c = 50;
                            opptysplits.add(split1);
                            split2.Sales_Team_Member__c = accountIdToOwnerIdMap.get(oppty.accountId);
                            split2.Split_Percentage__c = 50;
                            opptysplits.add(split2);
                        }
                    }                                 
                } 
                else if (acctClassification == 'Non-Coordinated') {
                    
                    system.debug(LoggingLevel.INFO, '++++++ non-coordinated: oppty owner: ' + oppty.OwnerId);
                    system.debug(LoggingLevel.INFO, '++++++ non-coordinated: oppty owner: ' + split1.Opportunity__c);
                    
                    split1.Sales_Team_Member__c = oppty.OwnerId;
                    split1.Split_Percentage__c = 100;
                    opptysplits.add(split1);
                }
                else if (acctClassification == 'Coordinated') {
                    if (oppty.OwnerId == accounts.get(oppty.accountid).ownerid){
                            split1.Sales_Team_Member__c = oppty.OwnerId;
                            split1.Split_Percentage__c = 100;
                            opptysplits.add(split1);
                        }else{
                            //the opportunity owner & account owner are different, so create 2 splits.
                            split1.Sales_Team_Member__c = oppty.OwnerId;
                            split1.Split_Percentage__c = 50;
                            opptysplits.add(split1);
                            split2.Sales_Team_Member__c = accountIdToOwnerIdMap.get(oppty.accountId);
                            split2.Split_Percentage__c = 50;
                            opptysplits.add(split2);
                        }
                    
                    /*
                    //if (oppty.OwnerId == accounts.get(oppty.accountId).parent.ownerid){
                        //opportunity ownerid is the same as the parent account ownerid, so create 1 100% split
                        split1.Sales_Team_Member__c = oppty.OwnerId;
                        split1.Split_Percentage__c = 100;
                        opptysplits.add(split1);
                    }else{
                        //the opportunity ownerid and the parent account ownerid are different, so create a split between the two
                        split1.Sales_Team_Member__c = oppty.OwnerId;
                        split1.Split_Percentage__c = 50;
                        opptysplits.add(split1);
                        // get parent account's ownerId
                        Id parentAcctId = accountIdToParentIdMap.get(oppty.accountId);
                        if (parentAcctId != null) {
                            Account parentAcct = parentAccounts.get(parentAcctId);               
                            split2.Sales_Team_Member__c = parentAcct.ownerId;
                            split2.Split_Percentage__c = 50;
                            opptysplits.add(split2);
                        } else {
                            System.debug(LoggingLevel.INFO, '+++++++++++++++++ Opportunity is not associated with Parent Account:' + oppty);
                        }
                    }*/
                }
                
            }
        }
        System.debug(LoggingLevel.INFO, '+++++++++++++++++ Opportunity splits that are created:' + opptysplits);
        insert opptysplits;
    } 
        
        
   //
   //Used to create Opportunity Contact Role:        
    public static void insertOpportunityContactRole(Map<Id,Opportunity> insertedOpportunityMap) {           
        system.debug(LoggingLevel.INFO, '!!!! Inside CR ');
        
        List<Id> accountId = new List<Id>();
        List<OpportunityContactRole> allContactRoles =  new List<OpportunityContactRole>();
        Opportunity oppty =  new Opportunity();
        // create accountId list
        Set<Id> opptyIds = insertedOpportunityMap.keySet();
        for (Id opptyId: opptyIds) {
            oppty = insertedOpportunityMap.get(opptyId);
            //accountId.add(oppty.accountId);
            
            OpportunityContactRole cr =  new OpportunityContactRole();
            cr.ContactId = oppty.Original_Decision_Maker__c;
            cr.IsPrimary = true;
            cr.OpportunityId = oppty.Id;
            cr.role = 'Decision Maker';         
            allContactRoles.add(cr);
        }       
        
        System.debug(LoggingLevel.INFO, '!!!!!! CR about to be created:' + allContactRoles);
        insert allContactRoles;
        System.debug(LoggingLevel.INFO, '!!!!!! CR created:' + allContactRoles);
        
    }        
    
    public static testMethod void testInsertOpportunityContactRole() {
        Account acct = new Account (Name = 'Test Acct', Account_Classification__c = 'Local');
        acct.BillingState = 'F';
        insert acct;
        Contact cntc = New Contact (FirstName = 'TestFirst', LastName = 'TestLast', email = 'TestContact@test.com', accountId = acct.Id);
        insert cntc;
        Date closedDate = System.Today();
        closedDate = closedDate.addYears(1);
        Opportunity oppty = new Opportunity(Name='Test Oppt Contact Role', accountId = acct.Id, StageName = 'Closed Won', Original_Decision_Maker__c = cntc.id, CloseDate = closedDate, Estimated_Proposal_Date__c= system.today() + 1);
        insert oppty;
        List<OpportunityContactRole> allContactRoles = [Select o.ContactId, o.Id, o.IsPrimary, o.OpportunityId, o.Role from OpportunityContactRole o where OpportunityId =: oppty.Id];
        System.debug(LoggingLevel.INFO, '++++++++++ OpportunityContactRole: ' + allContactRoles );
        
        for (OpportunityContactRole ocr :allContactRoles)
        {
        System.AssertEquals(ocr.ContactId, cntc.id);
        System.AssertEquals(ocr.Role, 'Decision Maker');
        System.AssertEquals(ocr.IsPrimary, true);
        }
        /*
        System.AssertEquals([Select Original_Decision_Maker__c from Opportunity where Name = 'Test Oppt Contact Role'], [Select o.ContactId from OpportunityContactRole o where OpportunityId =: oppty.Id]);
        System.AssertEquals([Select o.Role from OpportunityContactRole o where OpportunityId =: oppty.Id limit 1], 'Decision Maker');
        System.AssertEquals([Select o.IsPrimary from OpportunityContactRole o where OpportunityId =: oppty.Id], true);
        */
    } 
        
    /*
        
        //Parent Account Info
        map<Id,Account> accounts = new map<Id, Account>([Select a.Id, ParentId From Account a where a.Id in: accountId]);
        system.debug(LoggingLevel.INFO, '++++++ Accounts associated with Opportunity: ' + accounts);
        
        Map<Id, Id> accountIdToParentIdMap = new Map<Id,Id>();
        List<Id> parentAccountId = new List<Id>();
        List<Id> contactIds = new List<Id>();
        for (Account acct: accounts.values()) {                     
            //accountIdToParentIdMap.put(acct.Id, acct.parentId);
            //parentAccountIds.add(acct.parentId);            
            //parentAccountId.add(acct.ParentId);
            
            if (acct.parentId == null) {
               parentAccountId.add(acct.Id);
               
               system.debug(LoggingLevel.INFO, '!!!! CR Parent Account: ' + parentAccountId);
            }
        }      
        
        //Get all contacts under parent accountId
        Map<Id,Contact> parentAccountsContacts = new Map<Id, Contact>([Select c.Id, c.email From Contact c where c.AccountId in: parentAccountId]);        
        //system.debug(LoggingLevel.INFO, '++++++ parent acct ' + parentAccounts);
        system.debug(LoggingLevel.INFO, '!!!!! CR Contact in Parent' + parentAccountsContacts);
        for (Contact  cont: parentAccountsContacts.values()) {                     
            //accountIdToParentIdMap.put(cont.Id, cont.parentId);
            contactIds.add(cont.Id);
            
            system.debug(LoggingLevel.INFO, '!!!!! CR Each Contact in Parent' + cont.Id);
        }
        
        //all contact roles
        List<OpportunityContactRole> allContactRoles = new List<OpportunityContactRole>();
        
        for (Id contId: contactIds ){           
            OpportunityContactRole cr =  new OpportunityContactRole();
            cr.ContactId = contId;
            cr.IsPrimary = true;
            cr.OpportunityId = oppty.Id;            
            allContactRoles.add(cr);
        }
        
        System.debug(LoggingLevel.INFO, '!!!!!! CR about to be created:' + allContactRoles);
        insert allContactRoles;
        System.debug(LoggingLevel.INFO, '!!!!!! CR created:' + allContactRoles);
        
        */
    
    public static testMethod void testinsertOpportunitySplitLocal() {
        Account acct = new Account (Name = 'Test acct1', Account_Classification__c = 'Local');
        acct.BillingState = 'IL';
        insert acct;
        Contact cntc = New Contact (FirstName = 'TestFirst', LastName = 'TestLast', email = 'TestContact@test.com', accountId = acct.Id);
        insert cntc;        
        Date closedDate = System.Today();
        closedDate = closedDate.addYears(1);
        Opportunity oppty = new Opportunity(Name='Test Oppty', accountId = acct.Id, StageName = 'Closed Won', Original_Decision_Maker__c = cntc.id, CloseDate = closedDate, Estimated_Proposal_Date__c= system.today() + 1);
        insert oppty;
        List<Opportunity_Split__c> splits = [select id,Split_Percentage__c, Sales_Team_Member__c from Opportunity_Split__c where Opportunity__c =: oppty.Id];
        System.debug(LoggingLevel.INFO, '++++++++++ Oppty Splits: ' + splits);
    }
    
    public static testMethod void testinsertOpportunitySplitNational() {
        
        Account acct = new Account (Name = 'Test acct1 Parent', Account_Classification__c = 'Local');
        acct.BillingState = 'IL';
        insert acct;
        Contact cntc = New Contact (FirstName = 'TestFirst', LastName = 'TestLast', email = 'TestContact@test.com', accountId = acct.Id);
        insert cntc;          
        Account acct2 = new Account (Name = 'Test acct1', parentId = acct.Id, Account_Classification__c = 'National');
        acct2.BillingState = 'IL';
        insert acct2;
        Date closedDate = System.Today();
        closedDate = closedDate.addYears(1);
        Opportunity oppty = new Opportunity(Name='Test Oppty', accountId = acct2.Id, StageName = 'Closed Won', Original_Decision_Maker__c = cntc.id, CloseDate = closedDate, Estimated_Proposal_Date__c= system.today() + 1);
        insert oppty;
        List<Opportunity_Split__c> splits = [select id,Split_Percentage__c, Sales_Team_Member__c from Opportunity_Split__c where Opportunity__c =: oppty.Id];
        System.debug(LoggingLevel.INFO, '++++++++++ Oppty Splits: ' + splits);
    }
    
     public static testMethod void testinsertOpportunitySplitCoordinated() {
        
        Account acct = new Account (Name = 'Test acct1 Parent', Account_Classification__c = 'Local');
        acct.BillingState = 'IL';
        insert acct;        
        Account acct2 = new Account (Name = 'Test acct1', parentId = acct.Id, Account_Classification__c = 'Coordinated');
        acct2.BillingState = 'IL';
        insert acct2;
        Contact cntc = New Contact (FirstName = 'TestFirst', LastName = 'TestLast', email = 'TestContact@test.com', accountId = acct.Id);
        insert cntc;          
        Date closedDate = System.Today();
        closedDate = closedDate.addYears(1);
        Opportunity oppty = new Opportunity(Name='Test Oppty', accountId = acct2.Id, StageName = 'Closed Won', Original_Decision_Maker__c = cntc.id, CloseDate = closedDate, Estimated_Proposal_Date__c= system.today() + 1);
        insert oppty;
        List<Opportunity_Split__c> splits = [select id,Split_Percentage__c, Sales_Team_Member__c from Opportunity_Split__c where Opportunity__c =: oppty.Id];
        System.debug(LoggingLevel.INFO, '++++++++++ Oppty Splits: ' + splits);
    }
    
}