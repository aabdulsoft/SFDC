/**=============================================================================
 * Created By: Nimisha (Appirio, Inc)
 * Created Date: [09/18/2014]
 * Description: Test class for Product Trigger Helper.

 Date   Modified By       Description

==============================================================================*/
@isTest(seeAllData = true)
private class ProductTriggerHelperTest {
  static User uvsUser;
  static testMethod void myUnitTest() {
  	uvsUser = TestUtilUVS.createUser(true);
  	system.runAs(uvsUser) {
  		
  		PriceBook2 pb = new PriceBook2();
  		map<String, Id> pbRecordTypeMap = TestUtilUVS.getRecordType('PriceBook2');
  		if(pbRecordTypeMap != null) {
  			pb.RecordTypeId = pbRecordTypeMap.get('UVS');
  		}
  		
  		pb.Name = 'Standard Price Book';
  		insert pb;
  		
  		Product2 prod = new Product2();
      prod.Name = 'UVS product1';
      prod.CurrencyIsoCode = 'USD';
      prod.Family = 'DCC Light';
      insert prod;
      
//      list<PriceBookEntry> pbeList = [SELECT Id FROM PriceBookEntry WHERE Product2Id = :prod.Id]; 
//      system.assertEquals(1,pbeList.size());
  	}
  }
}