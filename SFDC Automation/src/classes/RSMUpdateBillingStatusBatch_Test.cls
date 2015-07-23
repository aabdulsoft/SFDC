@isTest
private class RSMUpdateBillingStatusBatch_Test{

    static testmethod void unitTest()
    {
    	
    	Test.startTest();
		RSMCreateTestData.GetCustomSettingsRecord();
    	
		Account Acc1 = new Account();
        Acc1.name = 'Test';
        Acc1.account_classification__c = 'Key Account';
        Acc1.central_decisionmaking__c = False;
        Acc1.type = 'Customer';
        Acc1.Account_Classification__c = 'National';
        Acc1.LesseeNo__c = '0123123';
        insert Acc1;
    	
    	Customer_Branch__c CustomerBranch = new Customer_Branch__c();
	    CustomerBranch.Name = 'Test Customer Branch';
	    CustomerBranch.Ryder_HQ_Account__c = Acc1.Id;
	    insert CustomerBranch;
	    
	    Customer_Branch__c CustomerBranch1 = new Customer_Branch__c();
	    CustomerBranch1.Name = 'Test Customer Branch';
	    CustomerBranch1.Ryder_HQ_Account__c = Acc1.Id;
	    insert CustomerBranch1;
    
		Contact Cont1 = new Contact();
		Cont1.AccountId = Acc1.Id;
		Cont1.FirstName = 'Test Contact';
		Cont1.LastName = 'Sample';
		Cont1.Email = 'test8979123@rydertest.com';
		Cont1.Maintenance_Contact_Type__c = 'Primary';
		Cont1.Phone = '(123) 456-8789';
		Cont1.Contact_Source__c = 'Lead Conversion';
		insert Cont1;
    	
    	Vehicle__c Vehicle = new Vehicle__c();
	    Vehicle.Name = '1234';
	    Vehicle.CUSTOMER_BRANCH__c = CustomerBranch.Id;
	    Vehicle.RSM__c = 'Approved';
	    Vehicle.Account__c = Acc1.Id;
	    Vehicle.RSM_Billing_Status__c = true;
	    insert Vehicle;
    	
    	RSMUpdateBillingStatusBatch rubs= new RSMUpdateBillingStatusBatch ();
    	rubs.query='select Id,RSM_Billing__c from Account limit 1'; 
    	database.executebatch(rubs);
    
    	Test.stopTest();

	}
}