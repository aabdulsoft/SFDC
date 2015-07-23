/**=============================================================================
 * Created By: Gaurav Gupta (Appirio, Inc)
 * Created Date: [16/10/2014]
 * Description: Test class for UVS_VehicleStatsController

==============================================================================*/
@isTest
private class UVS_VehicleStatsControllerTest {

    static testMethod void myUnitTest() {
    	
    	User sysAdmin = TestUtilUvs.createAdminUser(True);
    	
    	System.runAs ( sysAdmin ) {
    	  RyderConfig__c rydConf = new RyderConfig__c();
    	  rydConf = TestUtilUVS.createRyderConfig(true);
    	  
			Account acc =TestUtilUVS.createAccount('Vendor','FMS',false);
			acc.Transaction_Type__c = 'Retail';
			acc.Accountsource = 'Advertisement';
			acc.SAM_Cust_ID__c = 'abc';
			insert acc;
			    	  
			Ryder_Branch__c rb = new Ryder_Branch__c();
			rb.Branch_Code__c = '123';
			rb.Country_Name__c = 'India';
			insert rb;
			Customer_Branch__c cstB = new Customer_Branch__c();
			cstB.Ryder_branch__c = rb.id;
			cstB.Ryder_HQ_Account__c = acc.id;
			insert cstB;       	  
    	  
    	  
    	  List<vehicle__c>  lstVehicles= TestUtilUVS.createVehList(false);	
    	  lstVehicles[0].Days_At_UTC__c = 150;
    	  lstVehicles[0].SAM_Class__c = 'ABC-CDE';
    	  lstVehicles[0].Model_Year__c =1989;
    	  lstVehicles[0].CUSTOMER_BRANCH__c = cstB.id;
    	  insert lstVehicles[0];
    	  
    	  BTR_Stats__c btrStats = new BTR_Stats__c();
    	  btrStats.Sam_Class__c = 'ABC-CDE';
    	  btrStats.Year__c = '1989';
    	  btrStats.Is_Current_Inventory__c=true;
    	  btrStats.Country__c = 'India';
    	  btrStats.Make__c = 'Test';
    	  btrStats.Model__c = 'Test';
    	  btrStats.Selling_Age__c = 18;
    	  insert btrStats;
    	  
    	  BTR_Stats__c btrStats1 = new BTR_Stats__c();
    	  btrStats1.Sam_Class__c = 'ABC-CDE';
    	  btrStats1.Year__c = '1989';
    	  btrStats1.Is_Current_Inventory__c= false;
    	  btrStats1.Country__c = 'India';
    	  btrStats1.Make__c = 'Test';
    	  btrStats1.Model__c = 'Test';
    	  btrStats1.Selling_Age__c = 18;
    	  insert btrStats1;
    	  
    	      	  
   		  PageReference tpageRef = Page.UVS_VehicleStats;
		  Test.setCurrentPage(tpageRef);
		
		  ApexPages.currentPage().getParameters().put('id',lstVehicles[0].id);
		  
		  UVS_VehicleStatsController uvsStatsCtrl = new UVS_VehicleStatsController();
		  uvsStatsCtrl.getListSAMClass();
		  system.assertequals(uvsStatsCtrl.country , 'India');
		  //system.assertequals(uvsStatsCtrl.sellingage , '0 - 180 days');
		  
    	}
    }
}