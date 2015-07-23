/****************************************************************************
 /**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 
 ****************************************************************************
 * Date             Name                  Description
  --------        ---------------       ----------------
 *12/12/2012      Swetha Mandadi          SFDC Visibility Enhancement
 ****************************************************************************/


@isTest (SeeAllData=true)
public class test_Duplicaterecordscheck
{
    private void initialise()
    {
        
    }
    public static testMethod void testConstructor()
    {
        Account acc = new Account(Name='Abc Group Inc', CO_SEGMENT__c='0 - Three trucks or less', BillingState='CA' ); 
        insert acc;
        Lead leadInfo = new Lead(FirstName='Swetha', LastName='Reddy', Status='Accepted', LeadSource='BDM', PRODUCT_LINE__c='RPM', Email='abc@gmail.com', State='CA', Country='US', Company='Pride' );
        insert leadInfo;
        Test.setCurrentpage(Page.Duplicaterecordscheck);
        Duplicaterecordscheck controller = new Duplicaterecordscheck(new ApexPages.StandardController(leadInfo));
        System.assertEquals(leadInfo.Id, controller.leadInfo.Id);
        /*
        System.assertEquals(controller.searchCriteriaCompany, leadInfo.Company);
        System.assertEquals(controller.searchCriteriaFirstName, leadInfo.FirstName);
        System.assertEquals(controller.searchCriteriaLastName, leadInfo.LastName);
        System.assertEquals(controller.searchCriteriaEmail, leadInfo.Email);
        System.assertEquals(controller.searchCriteriaState, leadInfo.State);
        System.assertEquals(controller.searchCriteriaCountry, leadInfo.Country);
        */
    }
    
    public static testMethod void testReset()
    {
        Account acc = new Account(Name='pride info systems', CO_SEGMENT__c='0 - Three trucks or less', BillingState='CA' ); 
        insert acc;
        Lead leadInfo = new Lead(FirstName='Swetha', LastName='Reddy', Status='Accepted', LeadSource='BDM', PRODUCT_LINE__c='RPM', Email='abc@gmail.com', State='CA', Country='US', Company='Pride' );
        insert leadInfo;
        Test.setCurrentpage(Page.Duplicaterecordscheck);
        Duplicaterecordscheck controller = new Duplicaterecordscheck(new ApexPages.StandardController(leadInfo));
        //System.assertEquals(leadInfo.Id, controller.leadInfo.Id);
        System.assertEquals(controller.searchCriteriaCompany, leadInfo.Company);
        System.assertEquals(controller.searchCriteriaFirstName, leadInfo.FirstName);
        System.assertEquals(controller.searchCriteriaLastName, leadInfo.LastName);
        System.assertEquals(controller.searchCriteriaEmail, leadInfo.Email);
        System.assertEquals(controller.searchCriteriaState, leadInfo.State);
        System.assertEquals(controller.searchCriteriaCountry, leadInfo.Country);
        
        System.assert(controller.stdAccountController.getResultSize()>0);
    }

    public static testMethod void testGetPageAccounts()
    {
        Test.setCurrentpage(Page.Duplicaterecordscheck);
        Duplicaterecordscheck controller = new Duplicaterecordscheck(new ApexPages.StandardController(new Lead()));
        controller.getPageAccounts();
    }

    public static testMethod void testGetPageContacts()
    {
        Test.setCurrentpage(Page.Duplicaterecordscheck);
        Duplicaterecordscheck controller = new Duplicaterecordscheck(new ApexPages.StandardController(new Lead()));
        controller.getPageContacts();
    }

    public static testMethod void testGetPageContactsMatchingEmail()
    {
        Test.setCurrentpage(Page.Duplicaterecordscheck);
        Duplicaterecordscheck controller = new Duplicaterecordscheck(new ApexPages.StandardController(new Lead()));
        controller.getPageContactsMatchingEmail();
    }

    public static testMethod void testGetPageLeads()
    {
        Test.setCurrentpage(Page.Duplicaterecordscheck);
        Duplicaterecordscheck controller = new Duplicaterecordscheck(new ApexPages.StandardController(new Lead()));
        controller.getPageLeads();
    }

    public static testMethod void testGetPageLeadsMatchingEmail()
    {
        Test.setCurrentpage(Page.Duplicaterecordscheck);
        Duplicaterecordscheck controller = new Duplicaterecordscheck(new ApexPages.StandardController(new Lead()));
        controller.getPageLeadsMatchingEmail();
    }

    public static testMethod void testChangeOrder()
    {
        Test.setCurrentpage(Page.Duplicaterecordscheck);
        Duplicaterecordscheck controller = new Duplicaterecordscheck(new ApexPages.StandardController(new Lead()));
        controller.sortOrder = 'DSC';
        controller.changeOrder();
        controller.sortOrder = 'ASC';
        controller.changeOrder();
    }

    public static testMethod void testSearchData()
    {
        Test.setCurrentpage(Page.Duplicaterecordscheck);
        Duplicaterecordscheck controller = new Duplicaterecordscheck(new ApexPages.StandardController(new Lead()));
        controller.searchData();
    }



}