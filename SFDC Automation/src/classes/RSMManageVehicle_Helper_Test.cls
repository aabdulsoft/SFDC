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
@isTest
private class RSMManageVehicle_Helper_Test {

    static testMethod void myUnitTest()
    {
        Test.startTest();
        
        RSMCreateTestData.GetCustomSettingsRecord();
        
        Account ac = new Account();
        ac.Name = 'Test1';
        ac.LesseeNo__c = '123';
        ac.RSM_CCMs__c = UserInfo.getUserId();
        ac.RSM_Onboarding__c = '';
        ac.RSM_AC_Classification__c  =  'National';
        insert ac;
  /*      ac.RSM_Plus_Total_Units__c  =  100;*/
        update ac;
        
        Customer_Branch__c cb = new Customer_Branch__c();
        cb.Name = 'Test Customer Branch';
        cb.Ryder_HQ_Account__c = ac.Id;
        insert cb;
        Vehicle__c v = new Vehicle__c();
        v.Name = '1234';
        v.CUSTOMER_BRANCH__c = cb.Id;
        v.RSM__c = 'Approved';
        v.RSM_Service_Level__c = 'STD';
        
        insert v;
        
        Vehicle__c v1 = new Vehicle__c();
        v1.Name = '1234';
        v1.CUSTOMER_BRANCH__c = cb.Id;
        v1.RSM__c = 'Approved';
        v1.RSM_Service_Level__c = 'Plus';
        
        insert v1;
        
        Vehicle__c v2 = new Vehicle__c();
        v2.Name = '1234';
        v2.CUSTOMER_BRANCH__c = cb.Id;
        v2.RSM__c = 'Approved';
        v2.RSM_Service_Level__c = 'Plus 1';
        v2.RSM__c = 'New';
        insert v2;
        
        v2.RSM_Demo__c = true;
        v2.RSM_To__c = System.today();
        v2.RSM_From__c = System.today().addDays(-20);
        v2.RSM__c = 'Approved';     
        update new List<Vehicle__c>{v,v1,v2};
        
        List<RecordType> lRecordType = [select Id from RecordType 
        								where sObjectType = 'Vehicle__c' and 
        								Name = 'Non Ryder Vehicle (NRV)' limit 1];
    	if(lRecordType != null && lRecordType.size() > 0)
    	{
	        Vehicle__c v3 = new Vehicle__c();
	        v3.Name = '1234';
	        v3.CUSTOMER_BRANCH__c = cb.Id;
	        v3.RSM__c = 'Approved';
	        v3.RSM_Service_Level__c = 'Plus';
	        v3.RecordTypeId = lRecordType[0].Id;
	        insert v3;
    	}
        
        RSMTaskForDemoVehicleEnd ClassObj = new RSMTaskForDemoVehicleEnd();
        database.executebatch(ClassObj,500);
        
        Test.stopTest();
    }
}