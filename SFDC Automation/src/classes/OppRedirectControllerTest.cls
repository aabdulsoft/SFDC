/*******************************************************************
Name  : OppRedirectControllerTest 
Author: Hari Krishnan (Appirio)
Date  : February 27, 2015
Discription: Test Class for the OppRedirectController class.
*************************************************************************/
@isTest(seeAllData=true)
public with sharing class OppRedirectControllerTest {

    static testMethod void testOppRedirect1() {
        User uvsUser = TestUtilUVS.createUser(true);
        system.runAs(uvsUser) {
            //RyderConfig__c rydConf = TestUtilUVS.createRyderConfig(true);
            //Ryder_Account_Team_Role_Map__c ryAccTRM = TestUtilUVS.createRyderAccountTeamRoleMap(true);

            Account acc = TestUtilUVS.createAccount('Vendor','FMS',false);
            insert acc;
            Contact con = TestUtilUVS.createContact(acc.Id, false);
            con.Additional_Comments__c = 'Testing';
            con.OwnerId = UserInfo.getUserId();
            insert con;
            Opportunity opp = TestUtilUVS.createOpportunity('UVS Opportunity', acc, false, con);
            opp.Original_Decision_Maker__c = con.Id;
            insert opp;
              
            PageReference pageOppRedirect = Page.OppRedirect;
            Test.setCurrentPage(pageOppRedirect);
            ApexPages.currentPage().getParameters().put('id', opp.Id);
              
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            OppRedirectController orController = new OppRedirectController(sc);
            PageReference pageOpptyDetail2 = Page.OpptyDetail2;
            PageReference newPage = orController.doRedir();
            String expected = 'nooverride=1';
            System.assertEquals(true, newPage.getUrl().contains('nooverride=1'));
        }
    }
    
    static testMethod void testOppRedirect2() {
        Account a = TestUtil.createAccount('Ryder FMS Parent Account', 'FMS');
        a.BillingState = 'IL';
        a.BillingPostalCode = '94023';
        a.BillingCountry = 'US';
        a.ShippingState = 'IL';
        a.ShippingCountry = 'US';
        a.ShippingPostalCode = '94023';
        insert a;
        
        Contact c = New Contact (FirstName = 'TestFirst', LastName = 'TestLast', email = 'TestContact@test.com', accountId = a.Id);
        insert c;
        Opportunity Opp = TestUtil.createOppty(a, c, 'Standard Opportunity');        
        insert Opp;
        
        PageReference pageOppRedirect = Page.OppRedirect;
        Test.setCurrentPage(pageOppRedirect);
        ApexPages.currentPage().getParameters().put('id', opp.Id);
          
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        OppRedirectController orController = new OppRedirectController(sc);
        PageReference pageOpptyDetail2 = Page.OpptyDetail2;
        PageReference newPage = orController.doRedir();
        System.assertEquals(pageOpptyDetail2.getUrl().contains('apex/opptyDetail2'), newPage.getUrl().contains('apex/opptyDetails2'));

    }
}