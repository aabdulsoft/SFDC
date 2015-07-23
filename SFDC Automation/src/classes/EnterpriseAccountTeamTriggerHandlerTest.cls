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
private class EnterpriseAccountTeamTriggerHandlerTest {

    
    static testMethod void EnterpriseAcountandManagerValidationTest() {

        Test.startTest();        

	   	Profile p = [select p.id from Profile p where p.Name in ('BDM', 'CDM') LIMIT 1];
	   	User usr = new User();
	   	//Creating the user
        User u = new User( Username = 'standarduser@rydertest.com', 
                                    Alias = 'standt', FirstName = 'Ryder', LastName = 'Tester', Email = 'standarduser@rydertest.com',
                                    EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
                                    LocalesIdKey = 'en_US', ProfileId = p.Id, TimeZonesIdKey = 'America/Los_Angeles',
                                    isActive = true);        
        insert u;
        system.debug('user : ' + u);      
        
        system.runAs(u){
			
			RSMCreateTestData.GetCustomSettingsRecord();			
	        Account acct = TestUtil.createAccount('Ryder FMS Parent Account', 'FMS');
	        insert acct;
	
	        try{
	        	acct.Additional_Classifications__c = 'Enterprise Account';
	            acct.Enterprise_Account_Manager__c = null;
	        	update acct;
	        }
	        catch(Exception e){
	            system.assert(e.getMessage().contains('Additional Classifications can only be assigned'));
	        }
        }
        Test.stopTest();              
    }       

    static testMethod void EnterpriseAcountandManagerUserTest() {

        Test.startTest();        

	   	Profile p = [select p.id from Profile p where p.Name in ('BDM', 'CDM') LIMIT 1];
	   	User usr = new User();
	   	//Creating the user
        User u = new User( Username = 'standarduser@rydertest.com', 
                                    Alias = 'standt', FirstName = 'Ryder', LastName = 'Tester', Email = 'standarduser@rydertest.com',
                                    EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
                                    LocalesIdKey = 'en_US', ProfileId = p.Id, TimeZonesIdKey = 'America/Los_Angeles',
                                    isActive = true);        
        insert u;
        system.debug('user : ' + u);      
        
        system.runAs(u){
        
            RSMCreateTestData.GetCustomSettingsRecord();			
            Account acct2 = TestUtil.createAccount('Ryder FMS Parent Account', 'FMS');
            insert acct2;
    
            try{
                acct2.Additional_Classifications__c = 'Enterprise Account';
                acct2.Enterprise_Account_Manager__c = u.Id;
                update acct2;
            }
            catch(Exception e){
                system.assert(e.getMessage().contains('Enterprise Account Manager must be a'));
            }
        }
        Test.stopTest();              
    }      
    
    
    
    
    static testMethod void updateAccountTeamMemberTest() {

        Test.startTest();        

        UserRole r = [Select u.Name, u.Id From UserRole u where u.Name = 'Director of Enterprise Sales' ];
	   	Profile p = [select p.id from Profile p where p.Name in ('DNA') LIMIT 1];
        Profile pAdmin = [select p.id from Profile p where p.Name in ('System Administrator') LIMIT 1];
	   	//Creating the user
        User uEAM = new User( Username = 'eam@rydertest.com', 
                                    Alias = 'eamuser', FirstName = 'Ryder', LastName = 'Tester', Email = 'eam@rydertest.com',
                                    EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', UserRoleId = r.Id,
                                    LocalesIdKey = 'en_US', ProfileId = p.Id, TimeZonesIdKey = 'America/Los_Angeles',
                                    isActive = true);        
        insert uEAM;
        system.debug('user role : ' + uEAM);   

        User uEAM2 = new User( Username = 'eam2@rydertest.com', 
                                    Alias = 'eamuser2', FirstName = 'Ryder2', LastName = 'Tester', Email = 'eam2@rydertest.com',
                                    EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', UserRoleId = r.Id,
                                    LocalesIdKey = 'en_US', ProfileId = p.Id, TimeZonesIdKey = 'America/Los_Angeles',
                                    isActive = true);        
        insert uEAM2;

        
	   	//Creating the user
        User u = new User( Username = 'standarduser@rydertest.com', 
                                    Alias = 'standt', FirstName = 'Ryder', LastName = 'Tester', Email = 'standarduser@rydertest.com',
                                    EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
                                    LocalesIdKey = 'en_US', ProfileId = pAdmin.Id, TimeZonesIdKey = 'America/Los_Angeles',
                                    isActive = true);        
        insert u;
        system.debug('user : ' + u);            
        
        System.runAs(u) {
               
            RSMCreateTestData.GetCustomSettingsRecord();
            Ryder_Account_Team_Role_Map__c settings = new Ryder_Account_Team_Role_Map__c();
            settings.Name = 'DNA';
            settings.Account_Team_Role__c = 'Enterprise Account Manager'; 
	        if(settings.Id == null)
    	        insert settings;
        	else
            	update settings;
            
            //Creating two for testing trigger for multiple accounts. Add one user to this account
            Account acct = TestUtil.createAccount('Ryder FMS Parent Account', 'FMS');
            insert acct;
    		
            Account acct2 = TestUtil.createAccount('Ryder FMS Parent Account', 'FMS');
            insert acct2;

            try{
                
                AccountTeamMember member = new AccountTeamMember(AccountId = acct2.Id, UserId = uEAM.Id);
                insert member;

                acct.Account_Classification__c = 'National';
                acct.Additional_Classifications__c = 'Enterprise Account';
                acct.Enterprise_Account_Manager__c = ueam.Id;
                
                acct2.Account_Classification__c = 'National';
                acct2.Additional_Classifications__c = 'Enterprise Account';
                acct2.Additional_Classifications__c = 'Enterprise Subsidiary';
                acct2.Enterprise_Account_Manager__c = ueam.Id;

				List<Account> laccttoUpdate = new List<Account>{acct, acct2};
                
                update laccttoUpdate;
                
				laccttoUpdate.clear();
                acct.Additional_Classifications__c = 'Enterprise Account';
                acct.Enterprise_Account_Manager__c = ueam2.Id;
                laccttoUpdate.add(acct);
                update laccttoUpdate;
                
                
				AccountTeamMember member2 = [Select a.UserId, a.AccountId 
                          	From AccountTeamMember a 
							where a.AccountId =: acct.Id And a.UserId =: uEAM.Id];                
                system.debug('member after : ' + member2);                
            }
            catch(Exception e){
                system.debug('general test : ' + e.getMessage());
            }
            Test.stopTest();                          
            
        }
        
        
    }    
    
}