/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAlldata = true)
private class OpportunityProductManagement_Helper_Test {
	
	static User uvsUser;
  static Account acc;
  static Contact con;
  static Vehicle__c veh;
  static Product2 prod;
  static Opportunity opp;
  static OpportunityLineItem oli;
  
  static testMethod void validateOnInsertTest() {
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
      
      PriceBookEntry pbe = [Select Name , Pricebook2Id , Pricebook2.name , CurrencyIsoCode From PricebookEntry where Pricebook2.name= 'UVS' LIMIT 1];
      pbe.isActive = true;
      update pbe;

      opp = TestUtilUVS.createOpportunity('National Rental Opportunity', acc, false, con);
      opp.Original_Decision_Maker__c = con.Id;
      opp.Pricebook2Id = pbe.Pricebook2Id;
      opp.CurrencyIsoCode = pbe.CurrencyIsoCode;
      insert opp;

      veh = TestUtilUVS.createUVSVehicle(acc, true);

      Test.StartTest();
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
      insert oLI;
      
      oLI.Quantity = 2;
      oLI.Rental_Period__c = 100;
      update oLI;

      
      //OpportunityProductManagement_Helper.ValidateOnInsert(oLI);
      Test.StopTest();
    }
  }
  
  /*
  static testMethod void validateProductSalesPriceOnTier99Test() {
  	uvsUser = TestUtilUVS.createUser(true);
    system.runAs(uvsUser) {
    	acc = TestUtilUVS.createAccount('Vendor', 'FMS', true);
	    List<Vehicle__c> vehicleList = TestUtilUVS.createVehList(true);
	    Test.StartTest();
	    List<OpportunityLineItem> lOpportunityLineItem = TestUtilUVS.createOpportunityLineItemList(acc, vehicleList, true);
	    Test.StopTest();
	    system.debug('============MANISHA==========OPPLI========' + lOpportunityLineItem);
      Map<Id,OpportunityLineItem> mOpportunityLineItem = new Map<Id,OpportunityLineItem>([select id, UnitPrice from OpportunityLineItem where OppRecordTypeName__c = 'National Rental Opportunity' and id in :lOpportunityLineItem]);
      //system.debug(lOpportunityLineItem[0].OppRecordTypeName__c+'>>>>>>>>>.'+mOpportunityLineItem);
      OpportunityProductManagement_Helper.ValidateOnUpdate(lOpportunityLineItem, mOpportunityLineItem);
      OpportunityProductManagement_Helper.ValidateOpportunityTotals(mOpportunityLineItem);
    }
  }
  */
  
}