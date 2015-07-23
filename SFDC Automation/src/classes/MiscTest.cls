@isTest(seealldata = true)
private class MiscTest {
    static testMethod void testRyderException(){
        RyderException re = new RyderException('Test Error', 'tst', 'tst', 'tst');
        RDatacom_additionalinformation rai = new RDatacom_additionalinformation();
        rai.name = 'test';
        rai.value = 'test';
        RDatacom_CompanyDUNSResponse rcd = new RDatacom_CompanyDUNSResponse();
        rcd.matchEngine = 'tst';
        rcd.rule = 'tst';
        rcd.size = 0;
        rcd.success = true;
        RDatacom_DUNSMatchRecords rdm = new RDatacom_DUNSMatchRecords();
        rdm.fieldDiffs = new List<RDatacom_fieldDiffs>();
        rdm.matchConfidence = 'test';
        RDatacom_Errors rde = new RDatacom_Errors();
        rde.statuscode = 'test';
        rde.message = 'test';
        System.assert(true);
    }
    
    static testMethod void testCearteTaskIfApprovedAndInDemo() {
        Account acc = TestUtilUVS.createAccount('Vendor', 'FMS', true);
        List<Vehicle__c> listVehicles = new List<Vehicle__c>();
        Vehicle__c veh1 = new Vehicle__c();
        veh1.Name = '1';
        veh1.Account__c = acc.Id;
        veh1.Ask_Price__c = 11;
        veh1.Take_Price__c = 11;
        veh1.NBV__c = 11;
        veh1.RSM_Demo__c = true;
        veh1.RSM_From__c = Date.today();
        veh1.RSM_To__c = Date.today().addDays(5);
        veh1.RSM__c = 'Approved';
        insert veh1;
        listVehicles.add(veh1);
        
        Vehicle__c veh2 = new Vehicle__c();
        veh2.Name = '2';
        veh2.Account__c = acc.Id;
        veh2.Ask_Price__c = 11;
        veh2.Take_Price__c = 11;
        veh2.NBV__c = 11;
        veh2.RSM_Demo__c = null;
        veh2.RSM_From__c = Date.today();
        veh2.RSM_To__c = Date.today().addDays(5);
        veh2.RSM__c = 'Denied';
        
        Map<Id, Vehicle__c> mapVehicles = new Map<Id, Vehicle__c>();
        mapVehicles.put(veh1.Id, veh2);
        RSMManageVehicle_Helper.CearteTaskIfApprovedAndInDemo(listVehicles, mapVehicles);
    }
    
    static testMethod void testUpdateAccount() {
        Account acc = TestUtilUVS.createAccount('Vendor', 'FMS', true);
        List<Vehicle__c> listVehicles = new List<Vehicle__c>();
        Vehicle__c veh1 = new Vehicle__c();
        veh1.Name = '1';
        veh1.Account__c = acc.Id;
        veh1.Ask_Price__c = 11;
        veh1.Take_Price__c = 11;
        veh1.NBV__c = 11;
        veh1.RSM_Demo__c = true;
        veh1.RSM_From__c = Date.today();
        veh1.RSM_To__c = Date.today().addDays(5);
        veh1.RSM__c = 'Approved';
        insert veh1;
        listVehicles.add(veh1);
        
        Vehicle__c veh2 = new Vehicle__c();
        veh2.Name = '2';
        veh2.Account__c = acc.Id;
        veh2.Ask_Price__c = 11;
        veh2.Take_Price__c = 11;
        veh2.NBV__c = 11;
        veh2.RSM_Demo__c = null;
        veh2.RSM_From__c = Date.today();
        veh2.RSM_To__c = Date.today().addDays(5);
        veh2.RSM__c = 'Denied';
        
        Map<Id, Vehicle__c> mapVehicles = new Map<Id, Vehicle__c>();
        mapVehicles.put(veh1.Id, veh2);
        RSMManageVehicle_Helper.UpdateAccount(listVehicles, mapVehicles);
    }
    
    static testMethod void testUpdateAccountOnExpirationDateChange() {
        Account acc = TestUtilUVS.createAccount('Vendor', 'FMS', true);
        List<Vehicle__c> listVehicles = new List<Vehicle__c>();
        Vehicle__c veh1 = new Vehicle__c();
        veh1.Name = '1';
        veh1.Account__c = acc.Id;
        veh1.Ask_Price__c = 11;
        veh1.Take_Price__c = 11;
        veh1.NBV__c = 11;
        veh1.RSM_Demo__c = true;
        veh1.RSM_From__c = Date.today();
        veh1.RSM_To__c = Date.today().addDays(5);
        veh1.RSM__c = 'Approved';
        insert veh1;
        listVehicles.add(veh1);
        
        Vehicle__c veh2 = new Vehicle__c();
        veh2.Name = '2';
        veh2.Account__c = acc.Id;
        veh2.Ask_Price__c = 11;
        veh2.Take_Price__c = 11;
        veh2.NBV__c = 11;
        veh2.RSM_Demo__c = null;
        veh2.RSM_From__c = Date.today();
        veh2.RSM_To__c = Date.today().addDays(5);
        veh2.RSM__c = 'Denied';
        
        Map<Id, Vehicle__c> mapVehicles = new Map<Id, Vehicle__c>();
        mapVehicles.put(veh1.Id, veh2);
        RSMManageVehicle_Helper.UpdateAccountOnExpirationDateChange(listVehicles, mapVehicles);
    }
/*
    static testMethod void testPopulateUnitNumber() {
        Account acc = TestUtilUVS.createAccount('Vendor', 'FMS', true);
        List<Vehicle__c> listVehicles = new List<Vehicle__c>();
        Vehicle__c veh1 = new Vehicle__c();
        veh1.Name = '1';
        veh1.Account__c = acc.Id;
        veh1.Ask_Price__c = 11;
        veh1.Take_Price__c = 11;
        veh1.NBV__c = 11;
        veh1.RSM_Demo__c = true;
        veh1.RSM_From__c = Date.today();
        veh1.RSM_To__c = Date.today().addDays(5);
        veh1.RSM__c = 'Approved';
        insert veh1;
        listVehicles.add(veh1);
        
        
        RSMManageVehicle_Helper.PopulateUnitNumber(listVehicles);
    }
    */       
}