/**=====================================================================
 * Appirio, Inc
 * Name: LeadManagement_HelperTest
 * Description: Test class for helper class LeadManagement_Helper
 * Created Date: [12/24/2014]
 * Created By: [Rajeev Arya] (Appirio)
 * Date Modified                Modified By                  Description of the update
 
 =====================================================================*/
@isTest
private class LeadManagement_HelperTest {

    static testMethod void myUnitTest() {
        
        User user1 = TestUtilUVS.createUser(false);
        user1.region__c = 'Canada';
        insert user1;
        
        ID queueNorthEastId = [select id from group where type = 'queue' and name = 'TSA_Northeast' limit 1].Id;
        ID queueCanadaId = [select id from group where type = 'queue' and name = 'TSA_Canada' limit 1].Id;
        
        Postal_Code__c pos = new Postal_Code__c (Name = '98055', Postal_Code__c = '98055', DOS__c = user1.Id, 
                            City__c = 'FOREST PARK', State__c = 'GA', State_Name__c = 'GEORGIA', Country__c = 'US');
        insert pos;
        
        UVS_Profiles__c settings = UVS_Profiles__c.getOrgDefaults();
			
	    if(settings.Profile_Name__c == null) {
			settings = new UVS_Profiles__c();
			settings.SetupOwnerId = UserInfo.GetOrganizationId();
			settings.Profile_Name__c = 'VP Asset Management;FAM;DAM;VSM_VSR;UVS Business Admin;UVS VP Assistant;System Administrator';
			insert settings;
			system.debug('settings:::::::Profile_Name__c::::22222::::::'+settings.Profile_Name__c);
		}
        
        Lead le = TestUtilUVS.createLead(false);
        le.ownerId = LABEL.TSA_Lead_Assignment_QueueIncluded;
        le.PostalCode = '98055';
        insert le;
        
        system.assertEquals([select ownerID from lead where id =: le.Id].ownerId, queueCanadaId);
        
        test.startTest();
        Postal_Code__c pos1 = new Postal_Code__c (Name = '34023', Postal_Code__c = '34023', DOS__c = user1.Id, 
                            City__c = 'FOREST PARK', State__c = 'GA', State_Name__c = 'GEORGIA', Country__c = 'US');
        insert pos1;
        
        le.ownerId = queueNorthEastId;
        le.PostalCode = '34023';
        update le;
        
        test.stopTest();
    }
}