@isTest
private class RSMVehicleContractTest {
    
    static testmethod void test_searchActiveContracts()
    {
        RSMCreateTestData.GetCustomSettingsRecord();
        Account Ac=new Account ();
        Ac.RSM_Billing__c=true;
        Ac.Name ='Test';
        Ac.LesseeNo__c = '0000001';
        insert Ac;
        
        Vehicle__c Veh=new Vehicle__c();
        Veh.Name = '123';
        Veh.Account__c = Ac.id;
        insert Veh; 
        
        RSM_Contract__c Contrt1 = new RSM_Contract__c();
        Contrt1.Lessee__c = Ac.LesseeNo__c;
        Contrt1.Contract_Number__c = 2434;
        Contrt1.Status_Name__c = 'Approved';
        insert Contrt1;
        
        RSM_ContractDetail__c Contrt1Detail = new RSM_ContractDetail__c();
        Contrt1Detail.Contract_Number__c = Contrt1.id;
        Contrt1Detail.Action_Name__c = 'Cancel';
        Contrt1Detail.Is_Current__c = True;
        Contrt1Detail.Unit_Number__c = Veh.Id;
        insert Contrt1Detail;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(Veh);
        
        RSMVehicleContract rsmVC = new RSMVehicleContract(stdController);
        rsmVC.getPageActiveContracts();
    }
    
}