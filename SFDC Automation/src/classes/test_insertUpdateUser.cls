@isTest
public class test_insertUpdateUser {

    static testMethod void insertUpdateUser() 
    {
    Sales_Territory__c t= new Sales_Territory__c(Sales_Territory_Desc__c='test territory',Sales_Territory_code__c='99999');
    insert t;
    user u= testutil.createUser();
    u.Sales_Territory__c='test territory';
    system.debug('User*****' + u);
    test.starttest();
    insert u;
    test.stoptest();
    }
}