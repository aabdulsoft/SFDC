/*************************************************************************************************
Created By:     Nimisha Prashant
Date:           September 22, 2014
Description  :  Test Class for Handler class for Vehicle Trigger
Updated By:     Sunny Gill
Date:           September 22, 2014
**************************************************************************************************/
@isTest(seeAllData = true)
private class VehicleTriggerHandlerTest {
    static User uvsUser;
    static Account acc;
    static Opportunity opp;
    static List<Vehicle__c> oldVehList = new List<Vehicle__c>();
    static List<Vehicle__c> newVehList = new List<Vehicle__c>();
    static testMethod void testUpdateOppChatter() {
      uvsUser = TestUtilUVS.createUser(true);
      system.runAs(uvsUser) {
//        list<Vehicle_List__c> vehListconfig = TestUtilUVS.createVehicleList(true);
//        RyderConfig__c rydConf = TestUtilUVS.createRyderConfig(true);
//        Ryder_Account_Team_Role_Map__c ryAccTRM = TestUtilUVS.createRyderAccountTeamRoleMap(true);

        acc = TestUtilUVS.createAccount('Vendor', 'FMS', true);
        Contact newCon = TestUtilUVS.createContact(acc.Id,false);
        newCon.Additional_Comments__c = 'Test1';
        newCon.Email = 'test2@rydertest.com';
        newCon.OwnerId = UserInfo.getUserId();
        insert newCon;

        opp = TestUtilUVS.createOpportunity('UVS Opportunity', acc, false, newCon);
        opp.Original_Decision_Maker__c = newCon.Id;
        //test.starttest();
        insert opp;
        test.starttest();
        //test.stoptest();
        List<Vehicle__c> vehicleList = TestUtilUVS.createVehList(true);

        //List<OpportunityLineItem> oppLIList = TestUtilUVS.createOpportunityLineItemList(acc, vehicleList, true);

        oldVehList = [SELECT Id,Ask_Price__c,Take_Price__c,NBV__c FROM Vehicle__c where id in :vehicleList];
        Map<Id, Vehicle__c> oldmap = new Map<Id, Vehicle__c>();
        for(Vehicle__c v : oldVehList) {
            oldmap.put(v.id, v);
        }
        newVehList = [SELECT Id,Ask_Price__c,Take_Price__c,NBV__c FROM Vehicle__c  where id in :vehicleList];
        newVehList.get(0).Ask_Price__c = 12;
        newVehList.get(1).Take_Price__c = 12;
        newVehList.get(2).NBV__c = 12;
        Map<Id, Vehicle__c> newmap = new Map<Id, Vehicle__c>();
        for(Vehicle__c v : newVehList) {
            newmap.put(v.id, v);
        }
        System.debug(oldVehList);
        System.debug(newVehList);
        
        // Create OppLine Items 
        for(Id vhId:newmap.keySet()){
        	
        	 Product2 prod = new Product2();
	        prod.Name = 'Standard Price Book UVS';
	        prod.CurrencyIsoCode = 'CAD';
	        prod.family = 'FSL';
	        insert prod;
	       /* PriceBookEntry pbe = [SELECT Id , Pricebook2Id
	                              FROM PriceBookEntry
	                              WHERE Product2Id = :prod.Id
	                              LIMIT 1];*/
	        PriceBookEntry pbe = [Select Name ,Product2.Family,Product2.Id, Pricebook2Id , Pricebook2.name , CurrencyIsoCode From PricebookEntry where Pricebook2.name= 'UVS' LIMIT 1];
            pbe.isActive = true;
            update pbe;
            
            system.debug('::PBE :::'+pbe);
            String productFamily = pbe.Product2.Family;
            
            opp = TestUtilUVS.createOpportunity('UVS Opportunity', acc, false, newCon);
            opp.Original_Decision_Maker__c = newCon.Id;
            opp.Pricebook2Id = pbe.Pricebook2Id;
            opp.CurrencyIsoCode = pbe.CurrencyIsoCode;
            
            insert opp;

           
            //   veh = TestUtilUVS.createUVSVehicle(acc, true);
			//test.starttest();
            OpportunityLineItem oLI = new OpportunityLineItem();
            oLI.OpportunityId=opp.Id;
            oLI.Unit_Number__c=vhId;
            oLI.PricebookEntryId=pbe.Id;

            oLI.Quantity=1;
            oLI.UnitPrice=123;
            //oLI.Take_Price__c=12;
            oLI.Transaction_Type__c='NewCustomer';
            oLI.Product_Line__c= productFamily;
            oLI.Product_Detail__c='VOSA';
            oLI.Unit_Number__c = vhId;
            //oLi.IsTestRunning__c = true;
            insert oLI;
            break;
        }
        
        VehicleTriggerHandler.updateOppChatter(oldMap, newMap);
        test.stoptest();
      }
    }

}