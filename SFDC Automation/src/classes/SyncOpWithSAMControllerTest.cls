/**=============================================================================
 * Created By: Gaurav Gupta (Appirio, Inc)
 * Created Date: [15/10/2014]
 * Description: Test class for SyncOpWithSAMController

==============================================================================*/
@isTest
private class SyncOpWithSAMControllerTest {

    static testMethod void myUnitTest() {
        Ryder_Branch__c rb = TestUtilUvs.createRyderBranch();
        User sysAdmin = TestUtilUvs.createAdminUser(false);
        sysAdmin.UTC__c = rb.Branch_Code__c;
        insert sysAdmin; 

        System.runAs ( sysAdmin ) {
            RyderConfig__c rydConf = new RyderConfig__c();
            rydConf = TestUtilUVS.createRyderConfig(true);

            UVS_SAM_Sales_Type__c stCs = new UVS_SAM_Sales_Type__c();
            stCs.name = 'Retail';
            insert stCs;

            UVS_SAM_Sales_Source__c ssCs = new UVS_SAM_Sales_Source__c();
            ssCs.name = 'Advertisement';
            insert ssCs;

            Account acc =TestUtilUVS.createAccount('Vendor','FMS',false);
            acc.Transaction_Type__c = 'Retail';
            acc.SAM_Account_Source__c = 'Other';
            acc.Accountsource = 'Advertisement';
            acc.SAM_Cust_ID__c = 'abc';
            acc.Phone = '12345678900';
            insert acc;
            test.startTest();
            /*
            Ryder_Branch__c rb = new Ryder_Branch__c();
            rb.Branch_Code__c = '123';
            insert rb;
            */
            Customer_Branch__c cstB = new Customer_Branch__c();
            cstB.Ryder_branch__c = rb.id;
            cstB.Ryder_HQ_Account__c = acc.id;
            insert cstB;
                Vehicle__c v = new Vehicle__c(Name='1');
                v.CUSTOMER_BRANCH__c = cstB.id;
                v.Ask_Price__c = 20000.0;
                insert v;
                Opportunity opp = TestUtilUVS.createOpportunity('UVS Opportunity',acc , True, null);

                OpportunityLineItem oppLI1 = new OpportunityLineItem();
                Product2 prod = new Product2();
                prod.Name = 'Standard Price Book UVS';
                prod.CurrencyIsoCode = 'CAD';
                insert prod;

                PriceBookEntry pbe = [SELECT Id
                                  FROM PriceBookEntry
                                  WHERE Product2Id = :prod.Id
                                  LIMIT 1];
                pbe.isActive = true;
                update pbe;


            oppLI1.PricebookEntryId = pbe.Id;
            oppLI1.OpportunityId = opp.id;
            oppLI1.Unit_Number__c = v.id;
            oppLI1.Quantity = 1;
            oppLI1.UnitPrice = 123;
            oppLI1.Transaction_Type__c = 'Term Extension';
            oppLI1.Product_Line__c = 'Insurance';
            oppLI1.Product_Detail__c = 'Physical Damage';
            insert oppLI1;
            //
            list<Vehicle__c> vehilist = [Select id from Vehicle__c where Name < '10'];

            Contact newCon = TestUtilUVS.createContact(acc.Id,false);
            newCon.Additional_Comments__c = 'Test1';
            newCon.Email = 'test1@rydertest.com';
            newCon.OwnerId = UserInfo.getUserId();
            newCon.fax = '1234567890';
            insert newCon;
            test.stopTest();


            Quote q = TestUtilUVS.createQuote('UVS', false);
            q.contactId = newCon.id;
            q.OpportunityId = opp.id;
            //q.AccountId = acc.Id;
            insert q;
            ApexPages.StandardController sc = new ApexPages.standardController(q);

            SyncOpWithSAMController syncOpWithController = new SyncOpWithSAMController(sc);

            syncOpWithController.selectAccount();
            syncOpWithController.isForceInsert = True;
            syncOpWithController.callWS();
            system.assertequals(syncOpWithController.getHasPageMessage() , true);
            system.assertequals(syncOpWithController.isError , True);
            system.assertequals(syncOpWithController.quote.Opportunity.AccountId , acc.id);

        }
    }
}