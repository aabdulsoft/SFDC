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
private class test_ContactToCustomerBranchs {

    static testMethod void test_ContactToCustomerBranchs(){
        
        Account acct = TestUtil.createAccount('Ryder FMS Parent Account', 'Customer');
        insert acct;
        
        Customer_Branch__c cb = new Customer_Branch__c();
        cb.Name = 'test branch';
        cb.Ryder_HQ_Account__c = acct.Id;
        insert cb;
        
        Customer_Branch__c cb2 = new Customer_Branch__c();
        cb2.Name = 'test branch2';
        cb2.Ryder_HQ_Account__c = acct.Id;
        insert cb2;
        
        Customer_Branch__c cb3 = new Customer_Branch__c();
        cb3.Name = 'test branch3';
        cb3.Ryder_HQ_Account__c = acct.Id;
        insert cb3;
        
        Contact contct = TestUtil.createContact(acct.Id);
        contct.CSI_Contact_Type__c = 'Primary';
        contct.Maintenance_Contact_Type__c = 'Primary';
        List<Contact> contactList = new List<Contact>();
        contactList.add(contct);
        Contact contct2 = TestUtil.createContact(acct.Id);
        contct2.Email = 'abc123@xyz.com';
        contactList.add(contct2);
        insert contactList;
        
        Key_Contact__c keyContact = new Key_Contact__c ();
        keyContact.Contact__c = contct.Id;
        keyContact.Contact_Role__c = RyderGlobalVariables.MAINTENANCE_ROLE_TEXT;
        keyContact.Contact_Type__c = 'Secondary';
        keyContact.Customer_Branch__c = cb2.id;
        insert keyContact;
        
        Key_Contact__c keyContact2 = new Key_Contact__c ();
        keyContact2.Contact__c = contct.Id;
        keyContact2.Contact_Role__c = RyderGlobalVariables.CSI_ROLE_TEXT;
        keyContact2.Contact_Type__c = 'Secondary';
        keyContact2.Customer_Branch__c = cb3.id;
        insert keyContact2;
        
        // Start the test
        Test.startTest();
                   
        RyderGlobalVariables.IS_TEST = true;
        RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = false;
        
        // Set the Page Reference
        PageReference testPage = Page.ContactToCustomerBranches;
        Test.setCurrentPage(testPage);
                    
        // Create a standard controller 
        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(contct); 

        //create instance of pages controller
        ContactToCustomerBranchs contactToCustomerBranchs = new ContactToCustomerBranchs(controller);
        System.assertNotEquals(null, contactToCustomerBranchs.keyContactList);
    }
    
        
    
    
    static testMethod void DeleteAllKEyContactsContact(){
        
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
        insert contactList;
        
        Key_Contact__c keyContact = new Key_Contact__c ();
        keyContact.Contact__c = contactList[0].Id;
        keyContact.Contact_Role__c = RyderGlobalVariables.MAINTENANCE_ROLE_TEXT;
        keyContact.Contact_Type__c = 'Secondary';
        keyContact.Customer_Branch__c = cb.id;
        keyContact.All_Branch_Contact__c = false;
        insert keyContact;
        
        // Start the test
        Test.startTest();
                   
        RyderGlobalVariables.IS_TEST = true;
        RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = false;
        
       
         // Set the Page Reference
        PageReference testPage1 = Page.ContactToCustomerBranches;
        Test.setCurrentPage(testPage1);
        
        // Create a standard controller 
        ApexPages.Standardcontroller controller1 = new ApexPages.Standardcontroller(contactList[0]); 
        
        ContactToCustomerBranchs cCB = new ContactToCustomerBranchs(controller1);
        ContactUtil.isDeleteFromTrigger = false;
        cCB.DeleteAllKEyContactsContact();
        Test.stopTest();  
    
    }
    

    

}