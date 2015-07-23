/*************************************************************************************************
Created By:     Nimisha Prashant
Date:           September 22, 2014
Description  :  Test Class for UVS_QLIRelatedList Controller Class

**************************************************************************************************/
@isTest(seeAllData = true)
private class UVS_QLIRelatedListTest {
  static User uvsUser;
  static Account acc;
  static Opportunity opp;
  static List<Vehicle__c> vehList;
  static testMethod void myUnitTest() {
    uvsUser = TestUtilUVS.createUser(true);
    system.runAs(uvsUser) {
      acc = TestUtilUVS.createAccount('Vendor', 'FMS', true);
      Contact newCon = TestUtilUVS.createContact(acc.Id,false);
      newCon.Additional_Comments__c = 'Test1';
      newCon.Email = 'test2@rydertest.com';
      newCon.OwnerId = UserInfo.getUserId();
      insert newCon;
      Product2 prod = new Product2();
        prod.Name = 'testUVS123';
        prod.CurrencyIsoCode = 'CAD';
        prod.family = 'FSL';
        insert prod;

        /*PriceBookEntry pbe = [SELECT Id,Pricebook2Id
                              FROM PriceBookEntry
                              WHERE Product2Id = :prod.Id
                              LIMIT 1];
        pbe.isActive = true;
        update pbe;
        */
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
      vehList = TestUtilUVS.createVehList(true);


    List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
    for(Vehicle__c veh : vehList){
      OpportunityLineItem oppLI1 = new OpportunityLineItem();
      oppLI1.OpportunityId = opp.Id;
      oppLI1.Unit_Number__c = veh.Id;
      oppLI1.PricebookEntryId = pbe.Id;
      oppLI1.Quantity = 1;
      oppLI1.UnitPrice = 123;
      //oppLI1.Take_Price__c = 12;
      oppLI1.Transaction_Type__c = 'Term Extension';
      oppLI1.Product_Line__c= productFamily;
      oppLI1.Product_Detail__c = 'Physical Damage';
      oppLineItemList.add(oppLI1);
    }
      insert oppLineItemList;
      Quote quote = new Quote();

      quote.Contact = newcon;
      quote.Name = 'test-Quote';
      quote.OpportunityId = opp.Id;
      quote.Pricebook2Id = pbe.Pricebook2Id;
      insert quote;
      List<QuoteLineItem> qliList = new List<QuoteLineItem>();
      QuoteLineItem q;
      for(Vehicle__c veh : vehList){
        q = new QuoteLineItem();
        q.PriceBookEntryId = pbe.Id;
        q.Quantity = 1;
        q.UnitPrice = 1;
        q.Vehicle__c = veh.Id;
        q.QuoteId = quote.Id;
        qliList.add(q);
      }
      insert qliList;

      ApexPages.StandardController sc = new ApexPages.StandardController(quote);
      UVS_QLIRelatedList controller = new UVS_QLIRelatedList(sc);
      controller.deleteRecordId = q.Id;
      controller.deleteRecord();
  }


    }
  }