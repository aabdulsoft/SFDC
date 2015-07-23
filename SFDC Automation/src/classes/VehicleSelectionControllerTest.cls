/**=============================================================================
 * Created By: Nimisha (Appirio, Inc)
 * Created Date: [09/18/2014]
 * Description: Test class for Controller class for page Vehicle Selection on Lead detail page.

 Date   Modified By       Description

==============================================================================*/
@isTest(seeAllData = false)
private class VehicleSelectionControllerTest {
	static User sysAdmin;
	static Account acc;
	static Contact newCon;
	static Lead newLead;
	static list<Vehicle_List__c> vehList;
	static RyderConfig__c rydConf;
	static Ryder_Account_Team_Role_Map__c ryAccTRM;
		
  static testMethod void myUnitTest() {
    sysAdmin = TestUtilUVS.createUser(true);
    
    system.runAs(sysAdmin) {
    	vehList = TestUtilUVS.createVehicleList(true);
      
      rydConf = TestUtilUVS.createRyderConfig(true);
      ryAccTRM = TestUtilUVS.createRyderAccountTeamRoleMap(true);
      Profile_Default_Products__c custSetting = new Profile_Default_Products__c();
      custSetting.Name = [Select Id, Name from Profile where Id = :userInfo.getProfileId() limit 1].Name;
      custSetting.Default_Product__c = 'Used Vehicles';
      insert custSetting;
      
      Profile_Default_Products__c custSetting1 = new Profile_Default_Products__c();
      custSetting1.Name = 'VSM/VSR UVS';
      custSetting1.Default_Product__c = 'Used Vehicles';
      insert custSetting1;
          
      acc = TestUtilUVS.createAccount('Vendor','FMS',false);
      insert acc;
      
      newCon = TestUtilUVS.createContact(acc.Id,false);
      newCon.Additional_Comments__c = 'Testing';
      newCon.OwnerId = UserInfo.getUserId();
      insert newCon;
        	
      Solutions_Interest__c solInt = TestUtilUVS.createSolutionInterest(newCon, null, true);
      UVS_Profiles__c settings = UVS_Profiles__c.getOrgDefaults();
		if(settings.Profile_Name__c == null) {
			settings = new UVS_Profiles__c();
			settings.SetupOwnerId = UserInfo.GetOrganizationId();
			settings.Profile_Name__c = 'VP Asset Management;FAM;DAM;VSM_VSR;UVS Business Admin;UVS VP Assistant';
			insert settings;
			system.debug('settings:::::::Profile_Name__c::::22222::::::'+settings.Profile_Name__c);
		}
                
      ApexPages.StandardController sc = new ApexPages.StandardController(newCon);
      VehicleSelectionController controller = new VehicleSelectionController(sc);
      controller.save();
        	
      newLead = TestUtilUVS.createLead(false);
      newLead.Source_Comment__c = 'Testing';
      newLead.ownerId = UserInfo.getUserId();
	  insert newLead;
		 	    
		 	solInt = TestUtilUVS.createSolutionInterest(null, newLead, true);
      sc = new ApexPages.StandardController(newLead);
      controller = new VehicleSelectionController(sc);
        	
      Map<String, List<VehicleSelectionController.VehicleWrapper>> mapVehicleTypeVehicleList = controller.mapVehicleTypeVehicleList;
      
      for(String t :mapVehicleTypeVehicleList.keySet()){
	      List<VehicleSelectionController.VehicleWrapper> lstWrapper = mapVehicleTypeVehicleList.get(t);
	      for(VehicleSelectionController.VehicleWrapper wrapObj :lstWrapper){
	      	wrapObj.isSelected = true;
	      }
      }
      controller.save();
    }
  }
}