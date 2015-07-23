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
private class test_insertUpdateContact {

    static testMethod void insertContact() {
        Account acct = TestUtil.createAccount('Ryder FMS Parent Account', 'Customer');
        insert acct;
        
        Customer_Branch__c cb = new Customer_Branch__c();
        cb.Name = 'test branch';
        cb.Ryder_HQ_Account__c = acct.Id;
        insert cb;
        
        Contact contct = TestUtil.createContact(acct.Id);
        contct.CSI_Contact_Type__c = 'Primary';
        contct.Maintenance_Contact_Type__c = 'Primary';
        List<Contact> contactList = new List<Contact>();
        contactList.add(contct);
        Contact contct2 = TestUtil.createContact(acct.Id);
        contct2.Email='swe@tha.com';
        contactList.add(contct2);
        
      
        // Start the test
        Test.startTest();
        insert contactList;
        contct.CSI_Contact_Type__c = 'Secondary';
        update contct;
        contct2.Maintenance_Contact_Type__c = 'Primary';
        try {
            update contct2;
        } catch (System.Dmlexception ex) {
            System.assertEquals(true, ex.getMessage().length()> 0);
        }
        contct2.CSI_Contact_Type__c = 'Secondary';
        try {
            update contct2;
        } catch (System.Dmlexception ex) {
            System.assertEquals(true, ex.getMessage().length()> 0);
        }
        
        Test.stopTest();

    }
}