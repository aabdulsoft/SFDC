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
@isTest (seeAllData = true)
private class OpportunityManagement_Helper_Test {
	static User uvsUser;
    static testMethod void myUnitTest()
    {
			UserRole userRoleId_fam = [select Id from UserRole where name = 'DAM Canada'];
			User sysAdmin_fam = TestUtilUvs.createAdminUser(false);
			sysAdmin_fam.UserRoleId = userRoleId_fam.id;
			sysAdmin_fam.Username = 'uvs@rydertest_fam.com';
			
			insert sysAdmin_fam;
			    	
    	uvsUser = TestUtilUVS.createUser(False);
    	uvsUser.ManagerId = sysAdmin_fam.Id;
    	uvsUser.region__c = 'US';
    	insert uvsUser;
	      system.runAs(uvsUser) {
	        // TO DO: implement unit test
	        
	        ID RentalOppRecordTypeId = [Select r.Id From RecordType r where Name = 'National Rental Opportunity' 
	        							and SobjectType = 'Opportunity'].Id;
			ID RentalPriceBookRecordTypeId = [Select r.Id From RecordType r where 
												Name = 'National Rental PriceBook' 
												and SobjectType = 'PriceBook2'].Id;
	
			List<Pricebook2> lPricebook = [select Id from Pricebook2 where Name = 'Standard Price Book' limit 1];
			
			Pricebook2 p1 = new Pricebook2(IsActive = true, RecordTypeId = RentalPriceBookRecordTypeId, Name = 'Tier 1');
			insert p1;
			Pricebook2 p2 = new Pricebook2(IsActive = true, RecordTypeId = RentalPriceBookRecordTypeId, Name = 'Tier 99');
			insert p2;
			
			Product2 prd1 = new Product2(Name = 'Test Product 1');
	        insert prd1;
	        
	        Product2 prd2 = new Product2(Name = 'Test Product 1');
	        insert prd2;
	        
	        PricebookEntry pbe0 = new PricebookEntry();
	        pbe0.Pricebook2Id = lPricebook[0].id;
	        pbe0.Product2Id   = prd1.id;
	        pbe0.IsActive     = true;
	        pbe0.UnitPrice    = 1;
	        insert pbe0;
	        
	        PricebookEntry pbe00 = new PricebookEntry();
	        pbe00.Pricebook2Id = lPricebook[0].id;
	        pbe00.Product2Id   = prd2.id;
	        pbe00.IsActive     = true;
	        pbe00.UnitPrice    = 1;
	        insert pbe00;
	        
			PricebookEntry pbe1 = new PricebookEntry();
	        pbe1.Pricebook2Id = p1.id;
	        pbe1.Product2Id   = prd1.id;
	        pbe1.IsActive     = true;
	        pbe1.UnitPrice    = 1;
	        insert pbe1;
	        
	        PricebookEntry pbe2 = new PricebookEntry();
	        pbe2.Pricebook2Id = p2.id;
	        pbe2.Product2Id   = prd2.id;
	        pbe2.IsActive     = true;
	        pbe2.UnitPrice    = 1;
	        insert pbe2;
	        
	        System.debug('Nitin----p1->'+p1);
			System.debug('Nitin----p2->'+p2);
			
			
			Account a = TestUtil.createAccount('Ryder FMS Parent Account', 'FMS');
	        a.BillingState = 'IL';
	        a.BillingPostalCode = RyderGlobalVariables.TEST_POST_CODE;
	        a.BillingCountry = 'US';
	        a.ShippingState = 'IL';
	        a.ShippingCountry = 'US';
	        a.ShippingPostalCode = RyderGlobalVariables.TEST_POST_CODE;
	    	a.Rental_Price_Tier__c = 'Tier 1';
	    	insert a;
	    	
	    	Contact c = New Contact (FirstName = 'TestFirst', LastName = 'TestLast', email = 'TestContact@test.com', accountId = a.Id);
	    	insert c;
	    	
	    	Opportunity Opp = TestUtil.createOppty(a, c, 'National Rental Opportunity');
	    	opp.Specialized_Operating_Criteria__c = 'Mobile Maintenance';
	    	insert Opp;
	    	
	    	Opportunity Opp1 = TestUtil.createOppty(a, c, 'Standard Opportunity');
	    	opp1.Specialized_Operating_Criteria__c = 'Working Alone';
	    	insert Opp1;
	    	
	    	
	    	opp1.Customer_100_Ownership__c = 'Yes' ; 	
	    	//opp1.StageName = 'Booked'; AAK - throwing error during deployment during to validation rul
	    	opp1.StageName = 'Signed';
	    	
	    	opp1.Specialized_Operating_Criteria__c = 'Mobile Maintenance';
	    	update opp1;
	    	
	    	
	    }
    }
    static testMethod void TestSynchronizeMissingCustProspect()
    {
    	CommonFunctions commonFunction = new CommonFunctions();
    	
    	Account a = TestUtil.createAccount('Ryder FMS Branch Account', 'FMS');
		insert a;
		
		Contact c = TestUtil.createContact(a.Id, 'noemail@SFDCTest.com');
		insert c;
		
		Opportunity o = TestUtil.createOppty(a, c, 'Standard Opportunity');
		insert o;
		
		List<Opportunity> lOpp = new List<Opportunity>();
		lOpp.add(o);
		
		OpportunityManagement_Helper.SynchronizeMissingCustProspect(lOpp);
		//Force a negative test result by using a branch account with no parent
    	System.debug('@@@#### Cust Prospect' + a.CustProspectID__c);
		system.assert(a.CustProspectID__c == '' || a.CustProspectID__c == null);
    }
}