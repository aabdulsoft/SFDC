/**=====================================================================
 * Appirio, Inc
 * Name: LeadConvertRelayControllerTest
 * Description: Test class for helper class LeadConvertRelayController
 * Created Date: [12/24/2014]
 * Created By: [Rajeev Arya] (Appirio)
 * Date Modified                Modified By                  Description of the update
 
 =====================================================================*/
@isTest(SeeAllData = true)
private class LeadConvertRelayControllerTest {

    static Lead le = new Lead();
    
    private static void createTestData(){
        User user1 = TestUtilUVS.createUser(false);
        user1.region__c = 'Canada';
        insert user1;
        
        ID queueNorthEastId = [select id from group where type = 'queue' and name = 'TSA_Northeast' limit 1].Id;
        ID queueCanadaId = [select id from group where type = 'queue' and name = 'TSA_Canada' limit 1].Id;
        
        Postal_Code__c pos = new Postal_Code__c (Name = '98055', Postal_Code__c = '98055', DOS__c = user1.Id, 
                            City__c = 'FOREST PARK', State__c = 'GA', State_Name__c = 'GEORGIA', Country__c = 'US');
        insert pos;
        
        le = TestUtilUVS.createLead(false);
        le.ownerId = LABEL.TSA_Lead_Assignment_QueueIncluded;
        le.PostalCode = '98055';
        le.FirstName = 'test';
        le.LastName = 'name';
        le.Company = 'Dade paper';
        le.Status = 'Qualified';
        le.LeadSource = 'Advertisement';
        le.Street = '123 Test drive';
        le.City = 'Test City';
        le.State = 'Test State';
        le.PostalCode = '33378';
        le.Country = 'US';
        
        le.Customer_Type__c = RyderGlobalVariables.CustomerType.FMS.name();
        insert le;
    }
    
    static testMethod void ControllerTest(){
       
        Test.startTest();
                    
        RyderGlobalVariables.IS_TEST = true;
       
        PageReference leadConvertPage = Page.LeadConvertRelay;
        Test.setCurrentPage(leadConvertPage);
                    
        // Set the model action
        ApexPages.currentPage().getParameters().put('id', le.Id);

        // Create a standard controller 
        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(le); 
        
        //create instance of pages controller
        LeadConvertRelayController leadConvertRelayController = new LeadConvertRelayController(controller);
        leadConvertRelayController.init();
        Test.stopTest();
    
    }
}