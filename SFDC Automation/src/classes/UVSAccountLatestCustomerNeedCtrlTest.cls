/*******************************************************************
Name  : OpportunityTriggerHelperTest
Author: Samarth (Appirio)
Date  : October 16, 2014
Discription: Test Class for the Helper class OpportunityTriggerHelper
*************************************************************************/
@isTest
private class UVSAccountLatestCustomerNeedCtrlTest {
    
    static testMethod void validateController(){
        System.runAs(TestUtilUVS.createAdminUser(true)){
        	UVS_Profiles__c settings = UVS_Profiles__c.getOrgDefaults();
			
			if(settings.Profile_Name__c == null) {
				settings = new UVS_Profiles__c();
				settings.SetupOwnerId = UserInfo.GetOrganizationId();
				settings.Profile_Name__c = 'VP Asset Management;FAM;DAM;VSM_VSR;UVS Business Admin;UVS VP Assistant;System Administrator';
				insert settings;
				system.debug('settings:::::::Profile_Name__c::::22222::::::'+settings.Profile_Name__c);
			}
			
            RyderConfig__c rdc = TestUtilUVS.createRyderConfig(true);
            Account a = TestUtilUVS.createAccount('Ryder FMS Parent Account', 'FMS Rental', true);
            Id accountId = a.Id;
            Profile_Default_Products__c pdp = TestUtilUVS.createProfileDefaultProduct('VSM/VSR UVS', true);
            Contact newCon = TestUtilUVS.createContact(accountId, true);
            Lead newLead = TestUtilUVS.createLead(true);
            Solutions_Interest__c si = TestUtilUVS.createSolutionInterest(newCon, newLead, true);
            Solution_Interest_Detail__c sid = TestUtilUVS.createSolutionInterestDetail(si, true);
            ApexPages.StandardController sc = new ApexPages.standardController(a);
            UVSAccountLatestCustomerNeedController uvsalcnc = new UVSAccountLatestCustomerNeedController(sc);
            
            ApexPages.StandardController sc1 = new ApexPages.standardController(sid);
            UVSAccountLatestCustomerNeedController uvsalcn = new UVSAccountLatestCustomerNeedController(sc1);
        }
    }

}