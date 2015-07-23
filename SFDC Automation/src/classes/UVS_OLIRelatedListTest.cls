/*************************************************************************************************
Created By:     Nimisha Prashant
Date:           September 22, 2014
Description  :  Test Class for UVS_OLIRelatedList Controller Class

**************************************************************************************************/
@isTest(seeAllData = true)
private class UVS_OLIRelatedListTest {
  static User uvsUser;
  static Account acc;
  static Opportunity opp;
  static List<Vehicle__c> vehList;
  static testMethod void myUnitTest() {
    uvsUser = TestUtilUVS.createUser(true);
    system.runAs(uvsUser) {

	test.starttest();
    acc = TestUtilUVS.createAccount('Vendor', 'FMS', true);

	  Contact newCon = TestUtilUVS.createContact(acc.Id,false);
      newCon.Additional_Comments__c = 'Test1';
      newCon.Email = 'test2@rydertest.com';
      newCon.OwnerId = UserInfo.getUserId();
      insert newCon;

      opp = TestUtilUVS.createOpportunity('UVS Opportunity', acc, false, newCon);
      opp.Original_Decision_Maker__c = newCon.Id;

      insert opp;

      //List<Vehicle__c> vehicleList = TestUtilUVS.createVehList(true);

      //List<OpportunityLineItem> oppLIList = TestUtilUVS.createOpportunityLineItemList(acc, vehicleList, true);
		test.stoptest();
      ApexPages.StandardController sc = new ApexPages.StandardController(opp);
      UVS_OLIRelatedList controller = new UVS_OLIRelatedList(sc);
      //controller.deleteRecordId = oppLIList.get(0).Id;
      controller.deleteRecord();

      System.assertEquals(0,[Select Id from OpportunityLineItem where OpportunityId = :opp.Id].size());
    }
  }
}