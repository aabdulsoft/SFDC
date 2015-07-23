@isTest
private class Test_Contacts_KeyContacts {
    
    static testMethod void testContactKeyContactOperations()
    {
        // create parent account
        Account parentAcct = TestUtil.createAccount('Ryder FMS Parent Account', 'Customer');
        insert parentAcct;
        
        // create child account
        Account childAcct= new Account();
        childAcct.ParentId=parentAcct.Id;
        childAcct.Name='Child-Abc Group Inc';
        childAcct.Type='Customer';
        childAcct.BillingStreet='5401 Flagler street';
        childAcct.BillingCity='Miami';
        childAcct.BillingCity='FL';
        childAcct.BillingCountry='US';
        childAcct.BillingPostalCode = RyderGlobalVariables.TEST_POST_CODE;
        RecordType rt=[Select r.SobjectType, r.Name, r.IsActive, r.Id From RecordType r where  r.SobjectType='Account'  AND r.IsActive=true and r.Name='Ryder FMS Branch Account'];
        if (rt!=null) childAcct.RecordTypeId=rt.Id;
        insert childAcct;
            
        // create all branch contact for child
        /*
        Contact allbranchContact = new Contact();
        allbranchContact.accountId = childAcct.Id;
        allbranchContact.FirstName = 'Test All Branch contact';
        allbranchContact.LastName = 'Smith';
        allbranchContact.Email = 'abc123456789@abc999888.com';
        allbranchContact.Phone = '(123) 456-8789';
        allbranchContact.CSI_Contact_Type__c='Secondary';
        allbranchContact.Maintenance_Contact_Type__c = 'Primary';
        allbranchContact.Available_24_7__c='Yes';
        allbranchContact.Is_Duplicate__c=true;
        insert allbranchContact;
         
         
        // update an all branch contact
           
        allbranchContact.CSI_Contact_Type__c='Tertiary';
        allbranchContact.Maintenance_Contact_Type__c = 'Tertiary';
        
        // delete all branch contact
        if(allbranchContact.Is_Duplicate__c==true)
        	delete allbranchContact;
         */
        // create a regular contact and update to all branch
        Contact regularContact = TestUtil.createContact(childAcct.Id, 'test989898@test123.com');
        insert regularContact;
        test.startTest();
          /*  neelima-08/23 code moved to test_contacts_allbranchContact 
        // update regular contact to all branch
        System.debug(LoggingLevel.INFO, 'update regular contact to all branch');
        regularContact.CSI_Contact_Type__c = 'Primary';
        regularContact.Maintenance_Contact_Type__c = 'Secondary';
        regularContact.Available_24_7__c='Yes';
        update regularContact;
                
        // undo the all branch contact
        System.debug(LoggingLevel.INFO, 'undo the all branch contact');
        regularContact.CSI_Contact_Type__c=null;
        regularContact.Maintenance_Contact_Type__c = null;
                
        update regularContact; 
        */
                
        // create a customer branch
        Customer_Branch__c cb = new Customer_Branch__c();
        cb.Name = 'test branch';
        cb.Ryder_HQ_Account__c = parentAcct.Id;
        cb.Customer_Branch_Status__c='Active';
        insert cb;
        
        Contact con= [Select c.HQ_Account_ID__c from Contact c  where id =:regularContact.Id] ;
        
        // insert key contact1.
       System.debug(LoggingLevel.INFO, 'insert key contact1');
        Key_Contact__c kc= new Key_Contact__c();
        kc.Customer_Branch__c= cb.Id;
        kc.Available_24_7__c='Yes';
        kc.Contact__c= con.Id;
        kc.Contact_Role__c='CSI Contact';
        kc.Contact_Type__c='Secondary';
        insert kc;
        
               
        // update key contact
        kc.Contact_Type__c='Tertiary';
        update kc;
        
        // create another contact to test contact update on key contact
        Contact regularContact2 = TestUtil.createContact(childAcct.Id, 'test85678@test321.com');
        insert regularContact2;
        
         Contact con2= [Select c.HQ_Account_ID__c from Contact c  where id =:regularContact2.Id] ;
        kc.Contact__c=con2.Id;
          System.debug(LoggingLevel.INFO, 'updating key contact2');
        update kc;
        
           System.debug(LoggingLevel.INFO, 'deleting key contact');      
        // delete key contact
        delete kc;
        
        // insert key contact2.
         Key_Contact__c kc2= new Key_Contact__c();
        kc2.Customer_Branch__c= cb.Id;
        kc2.Available_24_7__c='Yes';
        kc2.Contact__c= regularContact.Id;
        kc2.Contact_Role__c='CSI Contact';
        kc2.Contact_Type__c='Primary';
        insert kc2;
        
       
        
      regularContact2.Maintenance_Contact_Type__c='Tertiary';
       // update regularContact2;
        // test createnewkeycontact function
       //Key_Contact__c kc3= contactUtil.CreateNewKeyContact(regularContact2, cb, RyderGlobalVariables.CSI_ROLE_TEXT, true);
       //insert kc3;
       
       
         System.debug(LoggingLevel.INFO, 'updating cust branch');
        // update customer branch from active to inactive
        cb.Customer_Branch_Status__c='Inactive';
        update cb;
        
        // update customer branch from Inactive to active
        cb.Customer_Branch_Status__c='Active';
        update cb;
        
        //delete customer branch
         System.debug(LoggingLevel.INFO, 'deleting cust branch');
        delete cb;  
        
         System.debug(LoggingLevel.INFO, 'deleting regular contact');
         // delete a regular contact
         if(regularContact.Is_Duplicate__c==true)
            delete regularContact;
        // delete an all branch contact
         System.debug(LoggingLevel.INFO, 'deleting contact 2');
         if(regularContact2.Is_Duplicate__c==true)
            delete regularContact2;
        test.stopTest();
    }
    

}