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
 * to a production organization. In additi	on, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class RSMManageAccount_Helper_Test
{
	static testMethod void myUnitTest()
    {
        // TO DO: implement unit test
        RSMCreateTestData.GetCustomSettingsRecord();
    
        Account Acc = new Account();
		Acc.Name = 'Generic Company Name';
		Acc.Site_Duns__c = '123456789';
		Acc.BillingState = 'IL';
		Acc.Account_Classification__c = 'National';
		insert Acc;
		Acc.Account_Classification__c = 'Local';
		update Acc;
		Acc.RSM_Plus1_Total_Unit__c = 10;
		update Acc;
		Acc.RSM_Plus1_Total_Unit__c = 1;
		Acc.RSM_Plus_Total_Unit__c = 50;
		update Acc;
		Acc.RSM_STD_Total_Unit__c = 100;
		Acc.RSM_Plus1_Total_Unit__c = 1;
		Acc.RSM_Plus_Total_Unit__c = 5;
		Acc.RSM_AC_Classification__c = 'Non Key Account';
		update Acc;
    }
}