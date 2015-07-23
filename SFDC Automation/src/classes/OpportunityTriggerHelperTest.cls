/*******************************************************************
Name  : OpportunityTriggerHelperTest
Author: Samarth (Appirio)
Date  : October 9, 2014
Discription: Test Class for the Helper class OpportunityTriggerHelper
*************************************************************************/

@isTest(SeeAllData=true)
private class OpportunityTriggerHelperTest { 
//test.starttest(); 
  static testMethod void validateOpportunityClosed(){
    //First check : if Opportunity Closed, All vehicles set to sold.
    Ryder_Branch__c ryderBranch = TestUtilUVS.createRyderBranch();
    User adminUser = TestUtilUVS.createUser(false);
    adminUser.UTC__c = ryderBranch.Branch_Code__c;
    ID profileID = adminUser.ProfileId;
    insert adminUser;
    System.runAs(adminUser){

        RyderConfig__c rdc = RyderConfig__c.getOrgDefaults();
        if(rdc == null){
            rdc = TestUtilUVS.createRyderConfig(true);
        }
        Ryder_Account_Team_Role_Map__c rmap = Ryder_Account_Team_Role_Map__c.getValues('Default');
        
        if(rmap == null){
            TestUtilUVS.createRyderAccountTeamRoleMap(true);
        }
        Account a = TestUtilUVS.createAccount('Ryder FMS Parent Account', 'FMS Rental', true);// Confirm Created Account fine?

        list<Vehicle__c> vehilist = TestUtilUVS.createVehList(true);

        list<OpportunityLineItem> opplilist = TestUtilUVS.createOpportunityLineItemList(a,vehilist,true);


        //Get the Opportunity Ids associated to the items in OpportunityLineItem
        Set<Id> Oppids = new Set<Id>();
        for(OpportunityLineItem oli : [Select OpportunityId from OpportunityLineItem where id in :opplilist]){
            Oppids.add(oli.Opportunityid);          
        }

        test.starttest();
        Contact newCon = TestUtilUVS.createContact(a.Id,false);
        newCon.Additional_Comments__c = 'Test1';
        newCon.Email = 'test1@rydertest.com';
        newCon.OwnerId = UserInfo.getUserId();
        newCon.fax = '123456789';
        insert newCon;
        
        Lead l = TestUtilUVS.createLead(false);
        l.Email = 'ggupta@appirio.com';
        l.Employee_Email__c = 'abc@xyz.com';
        l.status = 'Accepted';
        l.Original_Decision_Maker__c = newCon.id;
        insert l;
        //}

        UVS_Profiles__c settings11 = UVS_Profiles__c.getOrgDefaults();
        system.debug('settings11::::::::::::::::::'+settings11);
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(l.id);
        lc.setConvertedStatus('Qualified');
        //lc.setAccountId(a.id);
        //lc.setAccountId(newCon.id);


        Database.LeadConvertResult lcr = Database.convertLead(lc);

        l = [select id , ConvertedOpportunityId from Lead  where id = :l.id];


         Id recordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('UVS Opportunity').getRecordTypeId();
        Opportunity o = [select id , isclosed from Opportunity where id = :l.ConvertedOpportunityId];

        o.recordtypeid = recordTypeId;
        //o.stagename = 'Booked'; AAK - throwing error while deployment due to validation rule
        o.stagename = 'Signed';
        update o;
        test.stoptest();

        Map<Id, List<OpportunityLineItem>> mapOpp = new Map<Id, List<OpportunityLineItem>>();
        mapOpp.put(o.id, opplilist);
        OpportunityTriggerHelper.createTask(mapOpp.keySet(), mapOpp);
        OpportunityTriggerHelper.postChatterFeed(Oppids);
        
        list<Opportunity> ols = new list<Opportunity>();
        ols.add(o);
        OpportunityTriggerHelper.updateUTC(ols);

   }
  }

  static testMethod void validateSomeVehicleSold(){
System.runAs(TestUtilUVS.createAdminUser(true)){
        RyderConfig__c rdc = RyderConfig__c.getOrgDefaults();
        if(rdc == null){
            rdc = TestUtilUVS.createRyderConfig(true);
        }
        
            Account acc =TestUtilUVS.createAccount('Vendor','FMS',false);
            acc.Transaction_Type__c = 'Retail';
            acc.Accountsource = 'Advertisement';
            acc.SAM_Cust_ID__c = 'abc';
            insert acc;

            Ryder_Branch__c rb = new Ryder_Branch__c();
            rb.Branch_Code__c = '123';
            insert rb;
            Customer_Branch__c cstB = new Customer_Branch__c();
            cstB.Ryder_branch__c = rb.id;
            cstB.Ryder_HQ_Account__c = acc.id;
            insert cstB;
                Vehicle__c v = new Vehicle__c(Name='1');
                v.CUSTOMER_BRANCH__c = cstB.id;
                v.Sold_Flag__c = false;
                v.Ask_Price__c = 20000.0;
                insert v;
                list<Vehicle__c> lstV = new list<Vehicle__c>();
                lstV.add(v);
                test.startTest();
                /*list<opportunity> lstopp = new list<opportunity>();
                Opportunity opp = TestUtilUVS.createOpportunity('UVS Opportunity',acc , false, null);
                lstopp.add(opp);
                Opportunity opp1 = TestUtilUVS.createOpportunity('UVS Opportunity',acc , false, null);
                lstopp.add(opp1);
                insert lstopp;
                Product2 prod = new Product2();
                prod.Name = 'Standard Price Book UVS';
                prod.CurrencyIsoCode = 'CAD';
                insert prod;
                Opportunity oppUpdated = [select id,Pricebook2Id from Opportunity where ID=: opp.ID];
                Opportunity opp1Updated = [select id,Pricebook2Id from Opportunity where ID=: opp1.ID];
                
                PriceBookEntry pbe = [SELECT Id
                                  FROM PriceBookEntry
                                  WHERE Pricebook2Id = :oppUpdated.Pricebook2Id 
                                  LIMIT 1];
                pbe.isActive = true;
                update pbe;
                PriceBookEntry pbe1 = [SELECT Id
                                  FROM PriceBookEntry
                                  WHERE Pricebook2Id = :opp1Updated.Pricebook2Id 
                                  LIMIT 1];
                pbe1.isActive = true;
                update pbe1;

            list<OpportunityLineItem> lstOppLineItems = new list<OpportunityLineItem>();
            OpportunityLineItem oppLI1 = new OpportunityLineItem();
            oppLI1.PricebookEntryId = pbe.Id;
            oppLI1.OpportunityId = opp.id;
            oppLI1.Unit_Number__c = v.id;
            oppLI1.Quantity = 1;
            oppLI1.UnitPrice = 123;
            oppLI1.Transaction_Type__c = 'Term Extension';
            oppLI1.Product_Line__c = 'Insurance';
            oppLI1.Product_Detail__c = 'Physical Damage';
            lstOppLineItems.add(oppLI1);
            insert oppLI1;
            OpportunityLineItem oppLI2 = new OpportunityLineItem();
            oppLI2.PricebookEntryId = pbe1.Id;
            oppLI2.OpportunityId = opp1.id;
            oppLI2.Unit_Number__c = v.id;
            oppLI2.Quantity = 1;
            oppLI2.UnitPrice = 123;
            oppLI2.Transaction_Type__c = 'Term Extension';
            oppLI2.Product_Line__c = 'Insurance'; 
            oppLI2.Product_Detail__c = 'Physical Damage';
            lstOppLineItems.add(oppLI2);
            insert oppLI2;
            //insert    lstOppLineItems;*/
            list<OpportunityLineItem> opplilist = TestUtilUVS.createOpportunityLineItemList(acc,lstV,true);
            test.stopTest();
            Opportunity opp = new Opportunity(ID=opplilist[0].OpportunityId);
            Id uvsOppRT = UVS_Util.UVSRecordType_Opp;
            //opp.stagename = 'Booked'; AAK - throwing error while deployment due to validation rule
            opp.stagename = 'Booked';
            
            opp.recordtypeid = uvsOppRT;
            update opp;
  //List<Task> lstTask = [select id from Task];
  //system.assert(lstTask.size()>0);

   }
  }


}