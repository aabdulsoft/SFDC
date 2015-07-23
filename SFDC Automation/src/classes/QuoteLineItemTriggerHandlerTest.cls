/*************************************************************************************************
Created By:    Nimisha Prashant
Date:          October 1, 2014
Description  : Test class for Handler class for QuoteLineItem Trigger
**************************************************************************************************/
@isTest(seeAllData = true)
private class QuoteLineItemTriggerHandlerTest {
  static User uvsUser;
  static Account acc;
  static Contact con;
  static Vehicle__c veh;
  static Product2 prod;
  static Opportunity opp;
  static OpportunityLineItem oli;
  static Quote quote;
  static list<QuoteLineItem> qliList = new list<QuoteLineItem>();
  static testMethod void testSyncQuoteLineItemsOnInsert() {
    uvsUser = TestUtilUVS.createUser(true);
    system.runAs(uvsUser) {
    	acc = TestUtilUVS.createAccount('Ryder FMS Parent Account', 'FMS', true);
    	con = TestUtilUVS.createContact(acc.Id,false);
      con.Additional_Comments__c = 'Test1';
      con.Email = 'test2@rydertest.com';
      con.OwnerId = UserInfo.getUserId();
      insert con;
      prod = new Product2();
	    prod.Name = 'testUVS123';
	    prod.CurrencyIsoCode = 'USD';
	    prod.IsActive = true;

	    insert prod;

	    /*PriceBookEntry pbe = [SELECT Id,Pricebook2Id
	                          FROM PriceBookEntry
	                          WHERE Product2Id = :prod.Id
	                          LIMIT 1];
	    pbe.isActive = true;
	    update pbe;*/

		PriceBookEntry pbe = [Select Name , Pricebook2Id , Pricebook2.name , CurrencyIsoCode From PricebookEntry where Pricebook2.name= 'UVS' LIMIT 1];
        pbe.isActive = true;
        update pbe;

      opp = TestUtilUVS.createOpportunity('UVS Opportunity', acc, false, con);
      opp.Original_Decision_Maker__c = con.Id;
      opp.Pricebook2Id = pbe.Pricebook2Id;
      opp.CurrencyIsoCode = pbe.CurrencyIsoCode;
      insert opp;

      veh = TestUtilUVS.createUVSVehicle(acc, true);

      quote = new Quote();
      quote.Name = 'test-Quote UVS';
      quote.OpportunityId = opp.Id;
      quote.Pricebook2Id = pbe.Pricebook2Id;
      //quote.IsSyncing = true;
      insert quote;

      oLI = new OpportunityLineItem();
      oLI.OpportunityId = opp.Id;
      oLI.Unit_Number__c = veh.Id;
      oLI.PricebookEntryId = pbe.Id;
      oLI.Quantity = 1;
      oLI.UnitPrice = 123;
      //oLI.Take_Price__c = 12;
      oLI.Transaction_Type__c = 'New Location';
      oLI.Product_Line__c = 'FSL';
      oLI.Product_Detail__c = 'VOSA';

      Test.StartTest();
      //insert oLI;


      QuoteLineItem qLI = new QuoteLineItem();
      qLI.PriceBookEntryId = pbe.Id;
      qLI.Quantity = 1;
      qLI.UnitPrice = 123;
      qLI.Vehicle__c = veh.Id;
      qLI.QuoteId = quote.Id;
	  qLI.Interest_Rate__c = '12';
	  qLI.Term__c = '12';
      qliList.add(qLI);

      if(!qliList.isEmpty()) {
      	insert qliList;
      }

	  Test.StopTest();

      //opp = [Select Id, SyncedQuoteId from Opportunity where Id = :opp.Id limit 1];
      //opp.SyncedQuoteId = quote.Id;

      //update opp;



      //qLI = [select Id, UnitPrice from QuoteLineItem where Id in :qliList].get(0);

      qLI.Approved_Price__c = 1234;
      qLI.Interest_Rate__c = '12';
	  qLI.Term__c = '12';
	  qLI.UnitPrice = 12;
      update qLI;



    }
  }
}