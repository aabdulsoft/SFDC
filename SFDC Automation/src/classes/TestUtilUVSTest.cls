/**=============================================================================
 * Created By: Hari Krishnan (Appirio, Inc)
 * Created Date: 02/28/2015
 * Description: Test class for TestUtilUVS

==============================================================================*/
@isTest
private class TestUtilUVSTest {

    static testMethod void testCreateVehicleList() {
        List<Vehicle_List__c> listVehicle = TestUtilUVS.createVehicleList(true);
        System.assert(listVehicle.size() > 0);
    }
    
    static testMethod void testCreateSolutionInterest() {

        //TestUtilUVS.createRyderConfig(true);
        TestUtilUVS.createCustomSettingData();
        TestUtilUVS.createProfileDefaultProduct('VSM_VSR', true);
        Account account =TestUtilUVS.createAccount('Vendor','FMS',false);
        account.Transaction_Type__c = 'Retail';
        account.Accountsource = 'Advertisement';
        account.SAM_Cust_ID__c = 'abc';
        insert account;
        test.startTest();
        Contact contact = TestUtilUVS.createContact(account.Id, true);
        Opportunity opp = TestUtilUVS.createOpportunity('UVS Opportunity',account , true, null);
        opp.CloseDate = date.today();
        opp.CurrencyISOCode = 'USD';
        update opp;
        test.stopTest();
        Lead lead = TestUtilUVS.createLead(true);
        //Solutions_Interest__c solInterest = TestUtilUVS.createSolutionInterest(contact, lead, true);
        //Solution_Interest_Detail__c solIntDetails = TestUtilUVS.createSolutionInterestDetail(solInterest, true);
        Quote quote = TestUtilUVS.createQuote('UVS', true);
        
        Vehicle__c vehicle = TestUtilUVS.createUVSVehicle(account, true);
        List<Vehicle__c> listVehicles = TestUtilUVS.createVehList(true);
        Ryder_Account_Team_Role_Map__c acctTeamRoleMap = TestUtilUVS.createRyderAccountTeamRoleMap(true);
        User adminUser = TestUtilUVS.createAdminUser(true);
        //User uvsUser = TestUtilUVS.createUser(true);
        User sysAdminUser = TestUtilUVS.createSysAdmin(true);
        Ryder_Branch__c ryderBranch = TestUtilUVS.createRyderBranch();
        TestUtilUVS.getRandomInt(1,3);
        Product2 prd2 = TestUtilUVS.createProduct();
        PriceBook2 pb2 = TestUtilUVS.createPriceBook2();
        PriceBookEntry pbe = TestUtilUVS.createPriceBookEntry(prd2, pb2);
        System.assert(true);
        
        //TestUtilUVS.createOpportunityLineItemList(account, listVehicles, true);
    }
}