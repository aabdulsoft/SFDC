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
private class test_EditProductRelayController {

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
	    
        PriceBook2  stdPriceBook = [Select p.Name, p.Id From Pricebook2 p where p.Name = 'Standard Price Book' and p.IsActive = true LIMIT 1];
        
        // Select p.VHC_TYPE__c, p.SAM_Class__c, p.ProductCode, p.Name, p.Family From Product2 p
        Product2 tempProduct = new Product2();
        tempProduct.ProductCode = 'Test Product2';
        tempProduct.Name = 'Test Product2';
        tempProduct.Family = 'Test Family';
        tempProduct.VHC_TYPE__c = 'New';
        tempProduct.SAM_Class__c = '10 - Panel Van or Pickup';
        insert tempProduct;
        
        //Select p.Product2Id, p.Pricebook2Id, p.Name, p.Id From PricebookEntry p
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = stdPriceBook.Id;
        pbe.Product2Id = tempProduct.Id;
        pbe.UnitPrice = 1.00;
        pbe.IsActive = true;
        pbe.CurrencyIsoCode = 'USD';
        pbe.UseStandardPrice = false;
        insert pbe;
        
        //Select o.Transaction_Type__c, o.Quantity, o.Product_Line__c, o.Product_Detail__c, o.PricebookEntryId, o.OpportunityId, o.Id From OpportunityLineItem o
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.quantity = 1;
        oli.PricebookEntryId = pbe.Id;
        oli.OpportunityId = o.Id;
        oli.Product_Line__c = 'Insurance';
        oli.Product_Detail__c = 'GAP';
        oli.Transaction_Type__c = 'Replacement';
        oli.TotalPrice = 129.00;
        insert oli;
        
        // Start the test
        Test.startTest();
                    
        // Set the Page Reference
        PageReference productRelayPage = Page.EditProductRelay;
        Test.setCurrentPage(productRelayPage);
                    
        // Set the model action
        ApexPages.currentPage().getParameters().put('id', oli.Id);

        // Create a standard controller 
        ApexPages.Standardcontroller stdcontroller = new ApexPages.Standardcontroller(oli); 
        
        //create instance of pages controller
        EditProductRelayController controller = new EditProductRelayController(stdcontroller);
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
	    
        PriceBook2  stdPriceBook = [Select p.Name, p.Id From Pricebook2 p where p.Name = 'Standard Price Book' and p.IsActive = true LIMIT 1];
        
        // Select p.VHC_TYPE__c, p.SAM_Class__c, p.ProductCode, p.Name, p.Family From Product2 p
        Product2 tempProduct = new Product2();
        tempProduct.ProductCode = 'Test Product2';
        tempProduct.Name = 'Test Product2';
        tempProduct.Family = 'Test Family';
        tempProduct.VHC_TYPE__c = 'New';
        tempProduct.SAM_Class__c = '10 - Panel Van or Pickup';
        insert tempProduct;
        
        //Select p.Product2Id, p.Pricebook2Id, p.Name, p.Id From PricebookEntry p
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = stdPriceBook.Id;
        pbe.Product2Id = tempProduct.Id;
        pbe.UnitPrice = 1.00;
        pbe.IsActive = true;
        pbe.CurrencyIsoCode = 'USD';
        pbe.UseStandardPrice = false;
        insert pbe;
        
        //Select o.Transaction_Type__c, o.Quantity, o.Product_Line__c, o.Product_Detail__c, o.PricebookEntryId, o.OpportunityId, o.Id From OpportunityLineItem o
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.quantity = 1;
        oli.PricebookEntryId = pbe.Id;
        oli.OpportunityId = o.Id;
        oli.Product_Line__c = 'Insurance';
        oli.Product_Detail__c = 'GAP';
        oli.Transaction_Type__c = 'Replacement';
        oli.TotalPrice = 129.00;
        insert oli;
        // Start the test
        Test.startTest();
                    
        // Set the Page Reference
        PageReference productRelayPage = Page.EditProductRelay;
        Test.setCurrentPage(productRelayPage);
        
        // Create a standard controller 
        ApexPages.Standardcontroller stdcontroller = new ApexPages.Standardcontroller(oli);
                            
        // Set the model action
        ApexPages.currentPage().getParameters().put('id', o.Id);
        ApexPages.currentPage().getParameters().put('multiItemEdit', '1');

        //create instance of pages controller
        EditProductRelayController controller = new EditProductRelayController(stdcontroller);
        PageReference ref1 = controller.init();
        PageReference ref2 = controller.backToOpportunity();
        Test.stopTest();

    }
}