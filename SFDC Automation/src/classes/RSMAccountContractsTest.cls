@isTest
private class RSMAccountContractsTest {
  
    static testmethod void test_searchAllContracts()
    {
        RSMCreateTestData.GetCustomSettingsRecord();
        Account Ac=new Account ();
        Ac.RSM_Billing__c=true;
        Ac.Name ='Test';
        Ac.LesseeNo__c = '0000001';
        insert Ac;
  
        ApexPages.StandardController stdController = new ApexPages.StandardController(Ac);
    
        RSMAccountContracts rsmAC = new RSMAccountContracts(stdController);
        rsmAC.getPageAllContracts();
        rsmAC.changeOrder();
        rsmAC.sortOrder = 'DESC';
        rsmAC.changeOrder();
    }
}