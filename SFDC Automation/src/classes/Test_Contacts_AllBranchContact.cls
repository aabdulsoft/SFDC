@isTest
private class Test_Contacts_AllBranchContact  {
    
    static testMethod void testContactAllBranchContactOperations()
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
            
        test.startTest();
        // create all branch contact for child
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
        	
        	
        	 // create a regular contact and update to all branch
        Contact regularContact = TestUtil.createContact(childAcct.Id, 'test989898@test123.com');
        insert regularContact;
        
            
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
        
        test.stopTest();
    }
    

}