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
@isTest(seeAllData = true)
private class OpportunityClosedDateInPast_Test
{
	//create Admin uvs user
    public static User CreateAdminUser(Boolean isInsert)
    {
        Profile p = [select p.id from Profile p where p.Name in ('DOS') LIMIT 1];
		String USER_EMAIL_ENCODING = 'UTF-8';
   		String USER_TIMEZONE = 'America/Los_Angeles';
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
    
    //
    //Test to validate the UVS user can update/insert Opportunity Lineitem into an Opportunity in the past. 
    //
	static testMethod void ExecutePastClosedUVSOpportunity_Test()
	{
        User uvsAdminUser = TestUtilUVS.CreateAdminUser(true);
        system.runAs(uvsAdminUser) {
        	test.startTest();
        	list<QuoteLineItem> quotelineItemList = new list<QuoteLineItem>();
            Account acc = TestUtilUVS.createAccount('Ryder FMS Parent Account', 'FMS', true);
            Contact con = TestUtilUVS.createContact(acc.Id,True);
            
            Product2 prod = new Product2();
	        prod.Name = 'Standard Price Book UVS';
	        prod.CurrencyIsoCode = 'CAD';
	        prod.family = 'FSL';
	        insert prod;
	       /* PriceBookEntry pbe = [SELECT Id , Pricebook2Id
	                              FROM PriceBookEntry
	                              WHERE Product2Id = :prod.Id
	                              LIMIT 1];*/
	        PriceBookEntry pbe = [Select Name ,Product2.Family,Product2.Id, Pricebook2Id , Pricebook2.name , CurrencyIsoCode From PricebookEntry where Pricebook2.name= 'UVS' LIMIT 1];
            pbe.isActive = true;
            update pbe;
            
            system.debug('::PBE :::'+pbe);
            String productFamily = pbe.Product2.Family;
            Opportunity opp = TestUtilUVS.createOpportunity('UVS Opportunity', acc, false, con);
            opp.Original_Decision_Maker__c = con.Id;
            opp.Pricebook2Id = pbe.Pricebook2Id;
            opp.CurrencyIsoCode = pbe.CurrencyIsoCode;
            // Update the Close date to 2 days early so the Validation Rule can be tested by forcing the Opportunity to be in the past.
      		opp.CloseDate = date.today().addDays(-2);            
            insert opp;
			test.stopTest();

            Vehicle__c veh = new Vehicle__c();
            veh.Name = 'test1';
            veh.Account__c = acc.Id;
            veh.Ask_Price__c = 11;
            veh.Take_Price__c = 11;
            veh.NBV__c = 11;
            veh.Ask_Price__c = 20000.0;

            insert Veh;
            
            OpportunityLineItem oLI = new OpportunityLineItem();
            oLI.OpportunityId=opp.Id;
            oLI.Unit_Number__c=veh.Id;
            oLI.PricebookEntryId=pbe.Id;

            oLI.Quantity=1;
            oLI.UnitPrice=123;
            oLI.Transaction_Type__c='NewCustomer';
            oLI.Product_Line__c= productFamily;
            oLI.Product_Detail__c='VOSA';
            //oLi.IsTestRunning__c = true;
            // below Insert statement confirms that the Validation rule doesn't fires on UVS Opportunity
            // Validation Rule Name is: OpportunityEstimatedCloseDateInPast	
            insert oLI;
            System.assertEquals(true, oLI.Id != null);            
            
		}

    }
    
    //
    //Test to validate the Lease user cannot update/insert Opportunity Lineitem into an Opportunity in the past. 
    //
    static testMethod void ExecutePastClosedFMSOpportunity_Test()
    {
        User uvsAdminUser = CreateAdminUser(true);
        system.runAs(uvsAdminUser) {
        	test.startTest();
        	list<QuoteLineItem> quotelineItemList = new list<QuoteLineItem>();
            Account acc = TestUtilUVS.createAccount('Ryder FMS Parent Account', 'FMS', true);
            Contact con = TestUtilUVS.createContact(acc.Id,True);
            
            Product2 prod = new Product2();
	        prod.Name = 'Standard Price Book';
	        prod.CurrencyIsoCode = 'CAD';
	        prod.family = 'FSL';
	        insert prod;
	       /* PriceBookEntry pbe = [SELECT Id , Pricebook2Id
	                              FROM PriceBookEntry
	                              WHERE Product2Id = :prod.Id
	                              LIMIT 1];*/
	        PriceBookEntry pbe = [Select Name ,Product2.Family,Product2.Id, Pricebook2Id , Pricebook2.name , CurrencyIsoCode From PricebookEntry where Pricebook2.name != 'UVS' LIMIT 1];
            pbe.isActive = true;
            update pbe;
            
            system.debug('::PBE :::'+pbe);
            String productFamily = pbe.Product2.Family;
            
            Opportunity opp = TestUtilUVS.createOpportunity('Standard Opportunity', acc, false, con);
            opp.Original_Decision_Maker__c = con.Id;
            opp.Pricebook2Id = pbe.Pricebook2Id;
            opp.CurrencyIsoCode = pbe.CurrencyIsoCode;
            // Update the Close date to 2 days early so the Validation Rule can be tested by forcing the Opportunity to be in the past.
      		opp.CloseDate = date.today().addDays(-2);            
            insert opp;
			test.stopTest();
            
            Vehicle__c veh = new Vehicle__c();
            veh.Name = 'test1';
            veh.Account__c = acc.Id;
            veh.Ask_Price__c = 11;
            veh.Take_Price__c = 11;
            veh.NBV__c = 11;
            veh.Ask_Price__c = 20000.0;
            insert Veh;
            
      
            OpportunityLineItem oLI = new OpportunityLineItem();
            oLI.OpportunityId=opp.Id;
            oLI.Unit_Number__c=veh.Id;
            oLI.PricebookEntryId=pbe.Id;

            oLI.Quantity=1;
            oLI.UnitPrice=123;
            //oLI.Take_Price__c=12;
            oLI.Transaction_Type__c='NewCustomer';
            oLI.Product_Line__c= productFamily;
            oLI.Product_Detail__c='VOSA';
            //oLi.IsTestRunning__c = true;
            try
            {
            	insert oLI;
            }
            catch(exception Ex)
            {
            	// below Assert statement confirm that the Validation rule fires on Opportunities which are not UVS Opportunity
            	// Validation Rule Name is: OpportunityEstimatedCloseDateInPast	
            	System.assertEquals(false, oLI.Id != null);
            	System.assertEquals(Ex.getMessage(), 'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Estimated Close Date for Opportunity is in past, Please select an Estimated Close Date in the future.: [OpportunityId]');
            }
      }

    }
}