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
private class OppMultiEdit_Controller_Test {

    static testMethod void myUnitTest()
    {
        // TO DO: implement unit test
        Account a = TestUtil.createAccount('Ryder FMS Parent Account', 'FMS');
        a.BillingState = 'IL';
        a.BillingPostalCode = RyderGlobalVariables.TEST_POST_CODE;
        a.BillingCountry = 'US';
        a.ShippingState = 'IL';
        a.ShippingCountry = 'US';
        a.ShippingPostalCode = RyderGlobalVariables.TEST_POST_CODE;
        insert a;
        //system.assert(a.ShippingState, 'IL');
        //system.assert(a.ShippingCountry, 'US');
        //system.assert(a.BillingCountry, 'US');
        Contact c = New Contact (FirstName = 'TestFirst', LastName = 'TestLast', email = 'TestContact@test.com', accountId = a.Id);
        insert c;
        //system.assert(c.AccountId, a.Id);
        Opportunity Opp = TestUtil.createOppty(a, c, 'Standard Opportunity');        
        insert Opp;
        //system.assert(Opp.AccountId, a.Id);
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(new List<Opportunity>{new Opportunity()});
        OppMultiEdit_Controller ClassObj = new OppMultiEdit_Controller(controller);
        
        controller = new ApexPages.StandardSetController(new List<Opportunity>{Opp});
        controller.setSelected(new List<Opportunity>{Opp});
        ClassObj = new OppMultiEdit_Controller(controller);
        
        ClassObj.UpdateData();      
    }
}