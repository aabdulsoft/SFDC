/**=============================================================================
 * Created By: Nimisha (Appirio, Inc)
 * Created Date: [09/20/2014]
 * Description: Test class for OpptyTypeRouterController Class

==============================================================================*/
@isTest
private class OpptyTypeRouterControllerTest {
  static User uvsUser;
  static Account acc;
  static Contact con;
  static Opportunity opp;
  static list<Vehicle_List__c> vehList;
  static RyderConfig__c rydConf;
  static Ryder_Account_Team_Role_Map__c ryAccTRM;
    static testMethod void myUnitTest() {
      uvsUser = TestUtilUVS.createUser(true);
      system.runAs(uvsUser) {
        vehList=TestUtilUVS.createVehicleList(true);
        rydConf = TestUtilUVS.createRyderConfig(true);
        ryAccTRM = TestUtilUVS.createRyderAccountTeamRoleMap(true);

        acc = TestUtilUVS.createAccount('Vendor','FMS',false);
        insert acc;
        con = TestUtilUVS.createContact(acc.Id, false);
        con.Additional_Comments__c = 'Testing';
        con.OwnerId = UserInfo.getUserId();
        insert con;
        opp = TestUtilUVS.createOpportunity('UVS Opportunity', acc, false, con);
        opp.Original_Decision_Maker__c = con.Id;
        insert opp;
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        OpptyTypeRouterController controller = new OpptyTypeRouterController(sc);
        controller.redirectToAddProduct();
        opp.RecordTypeId = [Select Id from RecordType where Name = 'Parent Opportunity' and sObjectType = 'Opportunity' ].get(0).Id;
        update opp;
        sc = new ApexPages.StandardController(opp);
        controller = new OpptyTypeRouterController(sc);
        controller.redirectToAddProduct();

      }
    }
}