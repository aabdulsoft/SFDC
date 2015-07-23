@isTest (seeAllData=true)
private with sharing class test_LeadManagement_Helper{
    static testMethod void test_LeadManagement_Helper()
    {
        User users = [select Id from User where Name = 'Eloqua Integration' limit 1];
        System.runAs(users)
        {
            Lead l= new Lead();
            l.ownerId = users.Id;
            l.FirstName='Jessica';
            l.LastName='Galindez';
            //l.Web_initiated__c=true;
            l.LeadSource='Cold Call';
            l.Country='US';
            l.State='FL';
            l.Status='Unread';
            //l.RecordTypeId='012P00000008Wbh';
            l.recordtypeid = [select id from recordtype where name = 'Marketing Automation Lead'][0].id;
            l.Company='Home Depot -test method ';
            //l.Web_Lead_Owner__c='11539';
            l.PRODUCT_LINE__c='Rental';
            l.PostalCode = '33144';
            insert(l);
        } 
    }

}