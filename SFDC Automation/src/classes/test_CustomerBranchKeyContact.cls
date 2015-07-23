@isTest
public class test_CustomerBranchKeyContact {

     static testMethod void test_CustomerBranchToContact(){
        
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
        contct2.Email = 'abc321@xyz.com';
        contactList.add(contct2);
        insert contactList;
        
        Key_Contact__c keyContact = new Key_Contact__c ();
        keyContact.Contact__c = contct2.Id;
        keyContact.Contact_Role__c = RyderGlobalVariables.MAINTENANCE_ROLE_TEXT;
        keyContact.Contact_Type__c = 'Secondary';
        keyContact.Customer_Branch__c = cb.id;
        insert keyContact;
        
        Key_Contact__c keyContact2 = new Key_Contact__c ();
        keyContact2.Contact__c = contct2.Id;
        keyContact2.Contact_Role__c = RyderGlobalVariables.CSI_ROLE_TEXT;
        keyContact2.Contact_Type__c = 'Secondary';
        keyContact2.Customer_Branch__c = cb.id;
        insert keyContact2;
        
        // Start the test
        Test.startTest();
                   
        RyderGlobalVariables.IS_TEST = true;
        RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER = false;
        
        // Set the Page Reference
        PageReference testPage = Page.CustomerBranchToKeyContacts;
        Test.setCurrentPage(testPage);
                    
        // Create a standard controller 
        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(cb); 

        //create instance of pages controller
        CustomerBranchKeyContact customerBranchKeyContact = new CustomerBranchKeyContact(controller);
        System.assertNotEquals(null, customerBranchKeyContact.keyContactList);
    }
    
        static testMethod void test_CustomerBranchToContactDeleteAllKEyContacts(){
        
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
        PageReference testPage = Page.CustomerBranchToKeyContacts;
        Test.setCurrentPage(testPage);
                    
        
        // Create a standard controller 
        ApexPages.Standardcontroller controller1 = new ApexPages.Standardcontroller(cb); 
        
        ContactUtil.isDeleteFromTrigger = false;
        CustomerBranchKeyContact custBranchKeyContact = new CustomerBranchKeyContact(controller1);
        custBranchKeyContact.DeleteAllKEyContactsFromCustomerBranch();
    //    System.assertNotEquals(null, customerBranchKeyContact.keyContactList);
        Test.stopTest(); 
            
     }

}