/**=============================================================================
 * Created By: Nimisha (Appirio, Inc)
 * Created Date: [09/19/2014]
 * Description: Test class for Contact Trigger Handler Class

==============================================================================*/
@isTest
private class ContactTriggerHandlerTest {
  static User uvsUser;
  static Account acc;
  static list<Contact> newConList = new list<Contact>();

  // RA: Please provide proper Indentation
  // RA: Please write SOQL query in proper format as mentioned in "Ryder_UVS_Artifacts_Overview" Google Sheet
  static testMethod void testCreateSolutionInterest() {
    uvsUser = TestUtilUVS.createUser(true);
    system.runAs(uvsUser) {
    	Test.startTest();
    	list<Vehicle_List__c> vehList = TestUtilUVS.createVehicleList(true);
      RyderConfig__c rydConf = TestUtilUVS.createRyderConfig(true);
      Ryder_Account_Team_Role_Map__c ryAccTRM = TestUtilUVS.createRyderAccountTeamRoleMap(true);

      // RA: We can create below custom setting record from Utility class.
      Profile_Default_Products__c custSetting = new Profile_Default_Products__c();
      custSetting.Name = [SELECT Id, Name 
                          FROM Profile 
                          WHERE Id = :userInfo.getProfileId()].get(0).Name;
      custSetting.Default_Product__c = 'Used Vehicles';
      insert custSetting;

      // RA: We can pass isInsert Param value as true here
    	acc = TestUtilUVS.createAccount('Vendor','FMS',true);

      Contact newCon = TestUtilUVS.createContact(acc.Id,false);
      newCon.Additional_Comments__c = 'Test1';
      newCon.Email = 'test1@rydertest.com';
      newCon.OwnerId = UserInfo.getUserId();
      newConList.add(newCon);
//      Solutions_Interest__c si = TestUtilUVS.createSolutionInterest(newCon, null, true);

      newCon = TestUtilUVS.createContact(acc.Id,false);
      newCon.Additional_Comments__c = 'Test2';
      newCon.Email = 'test2@rydertest.com';
      newCon.OwnerId = UserInfo.getUserId();
      newConList.add(newCon);

      if(newConList <> null) {
      	insert newConList;
      }

      Test.stopTest();
      list<Solutions_Interest__c> siList = [SELECT Id 
                                            FROM Solutions_Interest__c 
                                            WHERE Contact_Id__c = :newcon.Id];
      System.assertEquals(1,siList.size());
    }

  }
}