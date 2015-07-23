@isTest
private with sharing class test_LeadUpdateTrigger {
    static testMethod void test_LeadUpdateTrigger()
    {
        Lead l= new Lead();
        l.FirstName='Jessica';
        l.LastName='Galindez';
        //l.Web_initiated__c=true;
        l.LeadSource='Cold Call';
        l.Country='US';
        l.State='FL';
        l.Status='Unread';
        //l.RecordTypeId='012P00000008Wbh';
        l.recordtypeid = [select id from recordtype where name = 'Full Data Lead'][0].id;
        l.Company='Home Depot -test method ';
        l.Web_Lead_Owner__c='11539';
        l.PRODUCT_LINE__c='Rental';
        insert(l);
        
        
    }

}