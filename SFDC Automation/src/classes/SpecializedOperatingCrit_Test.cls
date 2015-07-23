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
private class SpecializedOperatingCrit_Test
{
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
    
    Contact c = New Contact (); 
      c.FirstName = 'TestFirst'; 
      c.LastName = 'TestLast'; 
      c.email = 'TestContact@test.com';
      c.accountId = ac.Id;
      c.Contact_Source__c = 'Lead Conversion';
      insert c;
      
        Opportunity o = new Opportunity();
        o.AccountId = ac.id;
        o.Original_Decision_Maker__c = c.id;
        o.CloseDate = date.today()+2;
        o.StageName = 'Qualifying';
        o.name = 'test opportunity';
        o.Estimated_Proposal_Date__c = System.today() + 1;  
        o.Specialized_Operating_Criteria__c = 'Parking Lot;Natural Gas;Test';      
        insert o;
        
        Test.stopTest();
    }
}