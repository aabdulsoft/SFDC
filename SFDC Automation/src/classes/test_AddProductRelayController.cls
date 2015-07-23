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
private class test_AddProductRelayController {

    static testMethod void myUnitTest() {
        Account a = TestUtil.createAccount('Ryder FMS Parent Account', 'FMS');
	    a.billingstate = 'IL';
	    a.BillingPostalCode = '12347';
	    a.BillingCountry = 'US';
	    insert a;
	    
	    Contact c = New Contact (FirstName = 'TestFirst', LastName = 'TestLast', email = 'TestContact@test.com', accountId = a.Id);
    	insert c;
	    
	    List<Opportunity> opptyList = new List<Opportunity>();
	    Opportunity o = TestUtil.createOppty(a, c, 'Standard Opportunity'); 
	    insert o;
	    
	    List<OpportunityContactRole> allContactRoles = [Select opp.ContactId, opp.Id, opp.IsPrimary, opp.OpportunityId, opp.Role from OpportunityContactRole opp where OpportunityId =: o.Id];
    
	    for (OpportunityContactRole ocr :allContactRoles)
	    {
	    	System.AssertEquals(ocr.ContactId, c.id);
	    	System.AssertEquals(ocr.Role, 'Decision Maker');
	    	System.AssertEquals(ocr.IsPrimary, true);
	    }
	    
	    // Start the test
        Test.startTest();
                    
        // Set the Page Reference
        PageReference productRelayPage = Page.AddProductRelayPage;
        Test.setCurrentPage(productRelayPage);
                    
        // Set the model action
        ApexPages.currentPage().getParameters().put('id', o.Id);

        //create instance of pages controller
        AddProductRelayController controller = new AddProductRelayController();
        PageReference ref1 = controller.init();
        PageReference ref2 = controller.backToOpportunity();
        Test.stopTest();

    }
    
    static testMethod void myUnitTest2() {
        Account a = TestUtil.createAccount('Ryder FMS Parent Account', 'FMS');
        a.billingstate = 'IL';
        a.BillingPostalCode = '12347';
        a.BillingCountry = 'US';
        insert a;
        
        Contact c = New Contact (FirstName = 'TestFirst', LastName = 'TestLast', email = 'TestContact@test.com', accountId = a.Id);
    	insert c;
	    
	    List<Opportunity> opptyList = new List<Opportunity>();
	    Opportunity o = TestUtil.createOppty(a, c, 'Standard Opportunity');
	    insert o;
	    
	    List<OpportunityContactRole> allContactRoles = [Select opp.ContactId, opp.Id, opp.IsPrimary, opp.OpportunityId, opp.Role from OpportunityContactRole opp where OpportunityId =: o.Id];
    
	    for (OpportunityContactRole ocr :allContactRoles)
	    {
	    	System.AssertEquals(ocr.ContactId, c.id);
	    	System.AssertEquals(ocr.Role, 'Decision Maker');
	    	System.AssertEquals(ocr.IsPrimary, true);
	    }
        
        // Start the test
        Test.startTest();
                    
        // Set the Page Reference
        PageReference productRelayPage = Page.AddProductRelayPage;
        Test.setCurrentPage(productRelayPage);
                    
        // Set the model action
        ApexPages.currentPage().getParameters().put('id', o.Id);
        ApexPages.currentPage().getParameters().put('multiItemEdit', '1');

        //create instance of pages controller
        AddProductRelayController controller = new AddProductRelayController();
        PageReference ref1 = controller.init();
        PageReference ref2 = controller.backToOpportunity();
        Test.stopTest();

    }
}