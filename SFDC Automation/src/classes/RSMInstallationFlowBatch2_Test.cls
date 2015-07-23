@isTest
private class RSMInstallationFlowBatch2_Test{

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
      Vehicle.RSM_Billing_Status__c=false;
      Vehicle.RSM_Device_Status__c='Installed';
      Vehicle.RSM_Health_Status__c='No issues reported';
      Vehicle.RSM_Billing_Email_Date__c=Date.valueOf('2014-03-01');
      insert Vehicle;
     
              
    RSMInstallationFlowBatch2 rif2= new RSMInstallationFlowBatch2 ();
    rif2.query='select Id from Account Limit 1'; 
    database.executebatch(rif2);
    
    Test.stopTest();

}
}