@isTest
private class RSMActivateBillingCtrl_Test{

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
    
        Vehicle__c Vehicle = new Vehicle__c();
        Vehicle.Name = '1234';
        Vehicle.CUSTOMER_BRANCH__c = CustomerBranch.Id;
        Vehicle.RSM__c = 'Approved';
        Vehicle.Account__c = Acc1.Id;
        Vehicle.RSM_Request_for_Billing__c='Send to Activate Billing';
        Vehicle.RSM_Billing_Status__c = false;
        insert Vehicle;
        
        RSMActivateBillingCtrl rbc = new RSMActivateBillingCtrl();   
        List<Vehicle__c> vehList = rbc.vehList;
        Test.stopTest();

    }
}