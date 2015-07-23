@isTest
private class RSMCancelEmailtoNonKeyAc_Test{

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
    	
    	Vehicle__c Vehicle = new Vehicle__c();
	    Vehicle.Name = '1234';
	    Vehicle.CUSTOMER_BRANCH__c = CustomerBranch.Id;
	    Vehicle.RSM__c = 'Approved';
	    Vehicle.Account__c = Acc1.Id;
	    insert Vehicle;
	
    	RSM_Contract__c Contrt1 = new RSM_Contract__c();
	    Contrt1.Lessee__c = Acc1.LesseeNo__c;
	    Contrt1.Contract_Number__c = 2434;
	    Contrt1.Status_Name__c = 'Approved';	    
	    insert Contrt1;
	    
	    RSM_ContractDetail__c Contrt1Detail = new RSM_ContractDetail__c();
	    Contrt1Detail.Contract_Number__c = Contrt1.id;
	    Contrt1Detail.Action_Name__c = 'Cancel';
	    Contrt1Detail.Is_Current__c = True;
	    Contrt1Detail.Unit_Number__c = Vehicle.Id;
	    insert Contrt1Detail;
	    
	    RSM_ContractDetail__c Contrt1Detail1 = new RSM_ContractDetail__c();
	    Contrt1Detail1.Contract_Number__c = Contrt1.id;
	    Contrt1Detail1.Action_Name__c = 'Cancel';
	    Contrt1Detail1.Is_Current__c = True;
	    Contrt1Detail.Unit_Number__c = Vehicle.Id;
	    insert Contrt1Detail1;
	    
    	RSMCancelEmailtoNonKeyAc rscenk= new RSMCancelEmailtoNonKeyAc(); 
   		rscenk.query='select Id,LesseeNo__c,RSM_AC_Classification__c from Account where RSM_AC_Classification__c=\'Non-Key Account\' LIMIT 2'; 
    	database.executebatch(rscenk);
    	
   		rscenk= new RSMCancelEmailtoNonKeyAc(); 
   		rscenk.query='select Id,LesseeNo__c,RSM_AC_Classification__c from Account where RSM_AC_Classification__c=\'Non-Key Account\' LIMIT 2'; 
    	database.executebatch(rscenk);
    	
    	Test.stopTest();

	}
}