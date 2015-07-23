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
private class QuoteExtensions_Test {

    static testMethod void myUnitTest() {
    	
		   User sysAdmin = TestUtilUVS.createAdminUser(true);
		    System.runAs(sysAdmin){
		    
		      RyderConfig__c rdc = TestUtilUVS.createRyderConfig(true);
		      
		      Product2 prod = new Product2();
		      prod.Name = 'Standard Price Book UVS';
		      prod.CurrencyIsoCode = 'CAD';
		      insert prod;
		      
		      Pricebook2 pb = new pricebook2(name='test');
		      insert pb;
		
		      PricebookEntry pbe = new PricebookEntry(pricebook2id=pb.id, product2id=prod.id,unitprice=1.0, isActive=true);
		      insert pbe;
		      
		      Account acc = TestUtilUVS.createAccount('Vendor', 'FMS', true);
		      Vehicle__c veh = TestUtilUVS.createUVSVehicle(acc, true);
		      
		      Quote q1 = TestUtilUVS.createQuote('UVS',true);
		      q1.pricebook2id=pb.id;
		      q1.status = 'Needs Review';
		      update q1;
		      
		      list <QuoteLineItem> lstQuoteLineItem = new List< QuoteLineItem>();
		      lstQuoteLineItem.add(new QuoteLineItem( Quantity = 1.0 ,Vehicle__c = veh.id,  quoteid= q1.id,
		                                            UnitPrice = 21951.0 , Take_Price2__c = 18951.0,Approval_Level__c= 2,PricebookEntryId=pbe.id,
		                                            Interest_Rate__c = '12',
													Term__c = '12'
		                                            ));
		      insert lstQuoteLineItem;   
        
  
        			
			QuoteExtensions controller = new QuoteExtensions(new ApexPages.Standardcontroller(q1));
			system.assertequals(False , controller.showMessage);

    }
    }
}