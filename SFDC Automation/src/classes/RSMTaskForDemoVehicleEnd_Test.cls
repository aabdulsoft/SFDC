@isTest
private class RSMTaskForDemoVehicleEnd_Test
{
    static testmethod void unitTest()
    {
        Test.startTest();
    
        RSMCreateTestData.GetCustomSettingsRecord();
        
        //RecordType RT = new RecordType(SobjectType = 'Task', Name = 'RydeSmart Task');
        //insert RT; 
        
        Account Acc1 = new Account();
        Acc1.name = 'Test';
        Acc1.account_classification__c = 'Key Account';
        Acc1.central_decisionmaking__c = False;
        Acc1.type = 'Customer';
        Acc1.Account_Classification__c = 'National';
        Acc1.LesseeNo__c = '123123';
        Acc1.RSM_CCMs__c = Userinfo.getUserId();
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
    
        Vehicle__c Vehicle = new Vehicle__c();
        Vehicle.Name = '1234';
        Vehicle.CUSTOMER_BRANCH__c = CustomerBranch.Id;
        Vehicle.RSM__c = 'Approved';
        Vehicle.Account__c = Acc1.Id;
        Vehicle.RSM_From__c = System.Today();
        Vehicle.RSM_To__c = System.Today();
        Vehicle.RSM_Demo__c = true;
        insert Vehicle;
      
        RSMTaskForDemoVehicleEnd rcsq = new RSMTaskForDemoVehicleEnd();
        Id BatchprocessId = Database.executeBatch(rcsq);
             
        Test.stopTest();

    }
}