@isTest
private class RSMInitialWelEmailToNonKeyAc_Test
{

    static testmethod void unitTest()
    {
	    Test.startTest();

    	RSMCreateTestData.GetCustomSettingsRecord();
    	
		Account Acc1 = new Account();
        Acc1.name = 'Test';
        Acc1.account_classification__c = 'Non-Key Account';
        Acc1.central_decisionmaking__c = False;
        Acc1.type = 'Customer';
        Acc1.Account_Classification__c = 'National';
        Acc1.LesseeNo__c = '0123123';
        Acc1.RSM_Onboarding__c='Initiation';
        insert Acc1;
   		
   		Customer_Branch__c CustomerBranch = new Customer_Branch__c();
	    CustomerBranch.Name = 'Test Customer Branch';
	    CustomerBranch.Ryder_HQ_Account__c = Acc1.Id;
	    insert CustomerBranch;
    
		Contact Cont1 = new Contact();
		Cont1.AccountId = Acc1.Id;
		Cont1.FirstName = 'Test Contact';
		Cont1.LastName = 'Sample';
		Cont1.Email = 'test8979123@rydertest.com';
		Cont1.Maintenance_Contact_Type__c = 'Primary';
		Cont1.Phone = '(123) 456-8789';
		Cont1.Contact_Source__c = 'Lead Conversion';
		insert Cont1;
    	
    	Key_Contact__c Key_Contact = new Key_Contact__c(Contact_Role__c = 'RydeSmart',
    													Contact__c = Cont1.Id, AccountId__c = Acc1.Id, 
    													Customer_Branch__c = CustomerBranch.Id, Available_24_7__c = 'YES', 
    													Contact_Type__c = 'Primary');
    	insert Key_Contact;
    	
    	
	    RSMInitialWelEmailToNonKeyAc rsiw= new RSMInitialWelEmailToNonKeyAc (); 
	    rsiw.query='select Id,RSM_AC_Classification__c,RSM_Onboarding__c from Account where RSM_AC_Classification__c=\'Non-Key Account\' and RSM_Onboarding__c=\'Initiation\' LIMIT 200'; 
	    database.executebatch(rsiw);
	   
		rsiw= new RSMInitialWelEmailToNonKeyAc (); 
	    rsiw.query='select Id,RSM_AC_Classification__c,RSM_Onboarding__c from Account where RSM_AC_Classification__c=\'Non-Key Account\' and RSM_Onboarding__c=\'Initiation\' LIMIT 200'; 
	    database.executebatch(rsiw);
	    
	    Test.stopTest();

	}
}