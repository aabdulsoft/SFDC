/**=============================================================================
 * Created By: Nimisha (Appirio, Inc)
 * Created Date: [09/20/2014]
 * Description: Test class for Contact Trigger Handler Class

==============================================================================*/
@isTest
private class LeadTriggerHandlerTest {
  static User uvsUser;
  static User sysAdmin;
  static list<Lead> newLeadList = new list<Lead>();
  static Profile_Default_Products__c profProduct;
  
  static testMethod void testCreateSolutionInterest() {
    uvsUser = TestUtilUVS.createUser(true);
    System.runAs(uvsUser) {
        UVS_Profiles__c settings = UVS_Profiles__c.getOrgDefaults();
            
            if(settings.Profile_Name__c == null) {
                settings = new UVS_Profiles__c();
                settings.SetupOwnerId = UserInfo.GetOrganizationId();
                settings.Profile_Name__c = 'VP Asset Management;FAM;DAM;VSM_VSR;UVS Business Admin;UVS VP Assistant';
                insert settings;
            }
            
            Test.startTest();
        String prName = [SELECT Id, Name FROM Profile WHERE Id = :userInfo.getProfileId()].get(0).Name;
        profProduct = TestUtilUVS.createProfileDefaultProduct(prName, true);
        
        //insert another Product Line
        Profile_Default_Products__c custSetting = new Profile_Default_Products__c();
      custSetting.Name = 'System Administrator';
      custSetting.Default_Product__c = 'Lease';
      insert custSetting;
      
        
        Lead newLead = TestUtilUVS.createLead(false);
        newLead.Source_Comment__c = 'Testing1';
        newLead.ownerId = UserInfo.getUserId();
        newLead.LeadSource = 'Employee Referral';
        newLead.Employee_Zipcode__c='12345';
          newLead.Employee_Phone__c='0123456879';
          newLead.Employee_Name__c ='ABC';
          newLead.SapID__c = 'some id here';
          newLead.Employee_Email__c='xyz@abc.com';
        newLeadList.add(newLead);
        newLead = TestUtilUVS.createLead(false);
        newLead.Source_Comment__c = 'Testing2';
        newLead.ownerId = UserInfo.getUserId();
        newLead.LeadSource = 'Other Referral';
        newLead.Lead_Source_Detail__c = 'Customer';
          RyderConfig__c rdc = TestUtilUVS.createRyderConfig(true);
          Account a = TestUtilUVS.createAccount('Ryder FMS Parent Account', 'FMS Rental', true);
        newLead.Customer_Account__c= a.id;
        newLeadList.add(newLead);
        insert newLeadList;
        
        Postal_Code__c pos = new Postal_Code__c (Name = '98055', Postal_Code__c = '12345', DOS__c = uvsUser.Id, 
                            City__c = 'FOREST PARK', State__c = 'GA', State_Name__c = 'GEORGIA', Country__c = 'US');
      pos.UVS_Assignee__c = uvsUser.Id;
      insert pos;
        
    
        LeadTriggerHandler.assignEmployeeLeads(newLeadList);
          
    
        Test.stopTest();
        List<Solutions_Interest__c> siList = [SELECT Id FROM Solutions_Interest__c WHERE Lead_Id__c in :newLeadList];
        //System.assertEquals(0,siList.size());
    
        sysAdmin = TestUtilUVS.createSysAdmin(true);
        
        List<Lead> leadUpdateList = new list<Lead>();
        system.debug('==========newLeadList========'+newLeadList);
        
        for(Lead l:[SELECT Id, OwnerId FROM Lead WHERE Id in :newLeadList]) {
            l.ownerId = sysAdmin.Id;
          leadUpdateList.add(l);
        }
        system.debug('--------leadUpdateList.size()-------'+leadUpdateList.size());
        
        if(leadUpdateList <> null) {
          update leadUpdateList;
        }
        
        //LeadTriggerHandler.addOwnerToQueue(leadUpdateList);
        
        
    }
  }
  
  static testMethod void testCreateSolutionInterest1() {
      User u = TestUtilUVS.createUser(true);
      Lead lead = TestUtilUVS.createLead(true);
      lead.OwnerId = u.Id;
      update lead;
      Map<Id, Lead> mapLeads = new Map<Id, Lead>();
      mapLeads.put(lead.Id, lead);
      LeadTriggerHandler.createSolutionInterest(mapLeads);
  }
  
      public static Lead createEloquaLead(Boolean isInsert) {
        //User u = TestUtilUVS.createSysAdmin(true);
        User u = TestUtilUVS.createUser(true);
        lead test_Lead = new lead (
            LastName = 'test value',
            FirstName = 'test value',
            Company = 'test value'
        );
        test_Lead.Entity_Type__c = 'Incorporated';
        test_Lead.Country = 'US';
        test_Lead.State = 'FL';
        test_Lead.Phone = '(123) 456-8789';
        test_Lead.Is_UVS__c = true;
        test_Lead.PostalCode = '00501';
        test_Lead.OwnerId = u.Id;
        //Vehicle__c veh = [SELECT unit__c FROM Vehicle__c LIMIT 1];
        //test_Lead.Unit__c = veh.Unit__c;
        test_Lead.Unit__c = '211211';
        //system.debug('veh : ' + veh);
        
        if(isInsert) {
            insert test_Lead;
        }
        return test_Lead;
    }
    
  static testMethod void testCreateSolutionInterestOnProfileChangedEloquaUVSLeads() {
        Lead lead = createEloquaLead(true);
  }
  
  static testMethod void testCreateSolutionInterestOnProfileChanged() {
      User u = TestUtilUVS.createUser(true);
      Lead lead = TestUtilUVS.createLead(true);
      lead.OwnerId = u.Id;
      update lead;
      Map<Id, Lead> mapLeads = new Map<Id, Lead>();
      mapLeads.put(lead.Id, lead);
      
      User u2 = TestUtilUVS.createSysAdmin(true);
      Lead lead2 = lead;
      lead2.OwnerId = u2.Id;
      update lead2;
      List<Lead> listLeads = new List<Lead>();
      listLeads.add(lead2);
      Map<Id, Lead> mapLeads2 = new Map<Id, Lead>();
      mapLeads2.put(lead2.Id, lead2);
      LeadTriggerHandler.createSolutionInterestOnProfileChanged(mapLeads, listLeads, mapLeads2);
  }
  
  static testMethod void testUpdateUTC() {
      Ryder_Branch__c rb = TestUtilUVS.createRyderBranch();
      UVS_Profiles__c uvsProfiles = createUVSProfilesSetting();
      User u = TestUtilUVS.createUser(true);
      
      u.UTC__c = rb.branch_code__c;
      update u;
      Lead lead = TestUtilUVS.createLead(true);
      lead.OwnerId = u.Id;
      update lead;
      List<Lead> listLeads = new List<Lead>();
      listLeads.add(lead);
      /*
      Map<Id, Lead> mapLeads = new Map<Id, Lead>();
      mapLeads.put(lead.Id, lead);
      
      User u2 = TestUtilUVS.createSysAdmin(true);
      Lead lead2 = lead;
      lead2.OwnerId = u2.Id;
      update lead2;
      List<Lead> listLeads = new List<Lead>();
      listLeads.add(lead2);
      Map<Id, Lead> mapLeads2 = new Map<Id, Lead>();
      mapLeads2.put(lead2.Id, lead2);
      */
      LeadTriggerHandler.updateUTC(listLeads, null, true);
  }
  
  
  /*
   static User createUser(Boolean isInsert) {
        Profile p = [select p.id from Profile p where p.Name in ('VSM_VSR') LIMIT 1];

        //Creating the user
        User u = new User( Username = 'uvs@rydertest.com',
                                    Alias = 'autocln', FirstName = 'Ryder', LastName = 'Tester', Email = 'uvs@rydertest.com',
                                    EmailEncodingKey = USER_EMAIL_ENCODING, LanguageLocaleKey = 'en_US',
                                    LocalesIdKey = 'en_US', ProfileId = p.Id, TimeZonesIdKey = USER_TIMEZONE,
                                    isActive = true);
        if(isInsert){
            insert u;
        }
        return u;
    }
  */
  
  public static UVS_Profiles__c createUVSProfilesSetting() {
      UVS_Profiles__c uvsProfiles = new UVS_Profiles__c();
      uvsProfiles.Profile_Name__c = 'VP Asset Management;FAM;DAM;VSM_VSR;UVS Business Admin;UVS VP Assistant';
      insert uvsProfiles;
      return uvsProfiles;
  }
}