@isTest(SeeAllData=true)
public with sharing class LeadConversionResultTest
{
	static User uvsUser;

	static testMethod void myUnitTest()
	{
		uvsUser = TestUtilUVS.createUser(true);
		system.runAs(uvsUser)
		{			
			RyderConfig__c rdc =  RyderConfig__c.getOrgDefaults();
			if(rdc == null){
				rdc = TestUtilUVS.createRyderConfig(true);
			}
			Ryder_Account_Team_Role_Map__c ryAccTRM = Ryder_Account_Team_Role_Map__c.getValues('Default'); 
			if(ryAccTRM == null){
				ryAccTRM = TestUtilUVS.createRyderAccountTeamRoleMap(true);
			}
			string strCurrentUserProfileName = [SELECT Id, Name
								FROM Profile
								WHERE Id = : userInfo.getProfileId()].get(0).Name;
			Profile_Default_Products__c custSetting = Profile_Default_Products__c.getValues(strCurrentUserProfileName); 
			if(custSetting == null){
				custSetting = new Profile_Default_Products__c();
				custSetting.Name = strCurrentUserProfileName;
				custSetting.Default_Product__c = 'Used Vehicles';
				insert custSetting;
			}




			Account a = TestUtilUVS.createAccount('Vendor', 'FMS', true); // Confirm Created Account fine?
			Contact newCon = TestUtilUVS.createContact(a.Id, false);
			newCon.Additional_Comments__c = 'Test1';
			newCon.Email = 'test1@rydertest.com';
			newCon.OwnerId = UserInfo.getUserId();
			newCon.fax = '123456789';
			insert newCon;



			Test.startTest();
			UVS_Profiles__c settings = UVS_Profiles__c.getOrgDefaults();
			if(settings.Profile_Name__c == null) {
				settings = new UVS_Profiles__c();
				settings.SetupOwnerId = UserInfo.GetOrganizationId();
				settings.Profile_Name__c = 'VP Asset Management;FAM;DAM;VSM_VSR;UVS Business Admin;UVS VP Assistant;System Administrator';
				insert settings;
				system.debug('settings:::::::Profile_Name__c::::22222::::::'+settings.Profile_Name__c);
			} 
			Lead myLead = TestUtilUVS.createLead(false);
			myLead.status = 'Accepted';
			myLead.email = 'testRyeder@gmail.com';
			myLead.Original_Decision_Maker__c = newCon.id;
			insert myLead;

			Database.LeadConvert lc = new Database.LeadConvert();
			lc.setLeadId(myLead.id);

			LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
			lc.setConvertedStatus(convertStatus.MasterLabel);

			Database.LeadConvertResult lcr = Database.convertLead(lc);
			System.assert(lcr.isSuccess());
			Test.stopTest();
			PageReference pageRef = Page.LeadConversionResult;
			Test.setCurrentPage(pageRef);
			// Add parameters to page URL
			ApexPages.currentPage().getParameters().put('id', myLead.id);
			LeadConversionResult result = new LeadConversionResult();
		}

	}
}