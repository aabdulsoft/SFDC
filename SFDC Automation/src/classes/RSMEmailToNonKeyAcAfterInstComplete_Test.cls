@isTest
private class RSMEmailToNonKeyAcAfterInstComplete_Test{

    static testmethod void unitTest(){
    Test.startTest();
        
    RSMCreateTestData.GetCustomSettingsRecord();
    
    Account Acc1 = new Account();
    Acc1.name = 'Test';
    Acc1.account_classification__c = 'Key Account';
    Acc1.central_decisionmaking__c = False;
    Acc1.type = 'Customer';
    Acc1.Account_Classification__c = 'National';
    Acc1.LesseeNo__c = '123123';
    Acc1.RSM_AC_Classification__c = 'Non-Key Account';
    insert Acc1;
    
    Contact Cont1 = new Contact();
	Cont1.AccountId = Acc1.Id;
	Cont1.FirstName = 'Test Contact';
	Cont1.LastName = 'Sample';
	Cont1.Email = 'test8979123@rydertest.com';
	Cont1.Maintenance_Contact_Type__c = 'Primary';
	Cont1.Phone = '(123) 456-8789';
	Cont1.Contact_Source__c = 'Lead Conversion';
	Cont1.Email_does_not_exist__c = false;
	insert Cont1;
    
    Customer_Branch__c CustomerBranch = new Customer_Branch__c();
    CustomerBranch.Name = 'Test Customer Branch';
    CustomerBranch.Ryder_HQ_Account__c = Acc1.Id;
    insert CustomerBranch;
	    
    Vehicle__c Vehicle = new Vehicle__c();
    Vehicle.Name = '1234';
    Vehicle.CUSTOMER_BRANCH__c = CustomerBranch.Id;
    Vehicle.RSM__c = 'Approved';
    Vehicle.Account__c = Acc1.Id;
    Vehicle.RSM_Device_Status__c = 'Installed';
    insert Vehicle;
	
	Vehicle__c Vehicle1 = new Vehicle__c();
    Vehicle1.Name = '1234';
    Vehicle1.CUSTOMER_BRANCH__c = CustomerBranch.Id;
    Vehicle1.RSM__c = 'Approved';
    Vehicle1.Account__c = Acc1.Id;
    Vehicle1.RSM_Device_Status__c = 'Installed';
    insert Vehicle1;
	
	    
    RSMEmailToNonKeyAcAfterInstCompleted reaic= new RSMEmailToNonKeyAcAfterInstCompleted(); 
    reaic.query='select Id,RSM_AC_Classification__c from Account where RSM_AC_Classification__c=\'Non-Key Account\''; 
    database.executebatch(reaic);
	
	reaic= new RSMEmailToNonKeyAcAfterInstCompleted(); 
    reaic.query='select Id,RSM_AC_Classification__c from Account where RSM_AC_Classification__c=\'Non-Key Account\''; 
    database.executebatch(reaic);
    
    Test.stopTest();

}
}