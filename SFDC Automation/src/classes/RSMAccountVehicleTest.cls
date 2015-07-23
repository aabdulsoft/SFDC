@isTest
public with sharing class RSMAccountVehicleTest {
    
    static testmethod void test_searchVehicles()
    {
        RSMCreateTestData.GetCustomSettingsRecord();
        Account Ac=new Account ();
        Ac.RSM_Billing__c=true;
        Ac.Name ='Test';
        Ac.LesseeNo__c = '0000001';
        insert Ac;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(Ac);
        
        RSMAccountVehicle rsmVeh = new RSMAccountVehicle(stdController);
        rsmVeh.getPageVehicles();
        rsmVeh.changeOrder();
        rsmVeh.sortOrder = 'DESC';
        rsmVeh.changeOrder();
        
    }
    
}