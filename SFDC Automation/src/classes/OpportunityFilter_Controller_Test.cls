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
@isTest(seeAllData=true)
private class OpportunityFilter_Controller_Test
{
	static User uvsUser;
    static Account acc;
    static Opportunity opp;
    static List<Vehicle__c> vehList;
    static testMethod void testSyncQuoteLineItems() 
    {
    	uvsUser = TestUtilUVS.createUser(true);
        system.runAs(uvsUser)
        {
        	acc = TestUtilUVS.createAccount('Ryder FMS Parent Account', 'FMS', false);
            acc.Type = null;
            insert acc;
          	
          	Contact newCon = TestUtilUVS.createContact(acc.Id,false);
          	newCon.Additional_Comments__c = 'Test1';
          	newCon.Email = 'test2@rydertest.com';
          	newCon.OwnerId = UserInfo.getUserId();
          	insert newCon;
    
          	Product2 prod = new Product2();
            prod.Name = 'testUVS123';
            prod.CurrencyIsoCode = 'USD';
            prod.IsActive = true;
            insert prod;
    
            PriceBookEntry pbe = [SELECT Id,Pricebook2Id FROM PriceBookEntry WHERE Product2Id = :prod.Id LIMIT 1];
            pbe.isActive = true;
            update pbe;
    
          	opp = TestUtilUVS.createOpportunity('UVS Opportunity', acc, false, newCon);
          	opp.Original_Decision_Maker__c = newCon.Id;
          	opp.Pricebook2Id = pbe.Pricebook2Id;    
          	insert opp;
          	
			ApexPages.StandardController ApexControl = new ApexPages.StandardController(opp);
        	OpportunityFilter_Controller Control = new OpportunityFilter_Controller(ApexControl);        	
    	}
     }
}