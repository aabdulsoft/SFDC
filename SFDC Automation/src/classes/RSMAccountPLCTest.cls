@isTest 
public with sharing class RSMAccountPLCTest {
    
    static testmethod void test_searchPreLaunchChecklist()
    {
        RSMCreateTestData.GetCustomSettingsRecord();
        Account Ac=new Account ();
        Ac.RSM_Billing__c=true;
        Ac.Name ='Test';
        Ac.LesseeNo__c = '0000001';
        insert Ac;
        
        RSM_Contract__c RSM_Con=new RSM_Contract__c();
        RSM_Con.Name = '123';
        RSM_Con.Document_Type_Name__c = 'FSL';
        RSM_Con.Effective_Date__c = date.today();
        RSM_Con.Lessee__c = '0000001';
        RSM_Con.Lessee_Email__c = 'test@test.com';
        RSM_Con.Status_Name__c = 'Approved';
        insert RSM_Con; 
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(Ac);
        
        RSMAccountPLC rsmPLC = new RSMAccountPLC(stdController);
        rsmPLC.searchPreLaunchChecklist();
        rsmPLC.saveRecord();
		rsmPLC.getPagePreLaunchChecklist();
		
    }
    
}