/**=============================================================================
 * Created By: Rahul Aeran (Appirio, Inc)
 * Created Date: [10/09/2014]
 * Description: Test class for BTRCustomerHistoryController

==============================================================================*/
@isTest
private class BTRCustomerHistoryControllerTest {
	static BTR__c btr;
	static testMethod void testCustomerHistoryController(){
		User sysAdmin = TestUtilUVS.createAdminUser(true);
		System.runAs(sysAdmin){
			createTestData();	
			PageReference pageRef = Page.BTRCustomerHistory;
			pageRef.getParameters().put('display', 'INACTIVE');
			Account acc = [Select id from Account where RecordType.Name ='Vendor' and CustomerTypeID__c='FMS' limit 1];
			Vehicle__c veh = TestUtilUVS.createUVSVehicle(acc, true);
			pageRef.getParameters().put('vehNumber', veh.Name);
			Test.setcurrentpage(pageRef);
			system.debug('======Samarth Mathur====== here is the vehicle' + veh +'======');
			BTRCustomerHistoryController btrchc = new BTRCustomerHistoryController();
		}
	}
	static void createTestData(){
        RyderConfig__c rdc = TestUtilUVS.createRyderConfig(true);
		Quote q1 = TestUtilUVS.createQuote('UVS',true);
		btr = new BTR__c();
		btr.Status__c = 'Submitted - With FAM';
		btr.Quote__c = q1.Id;
		insert btr;
		
	}

}