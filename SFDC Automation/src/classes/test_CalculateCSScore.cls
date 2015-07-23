@isTest
private class test_CalculateCSScore {

    static testMethod void insertRyderSurvey() {

Ryder_Surveys__c rs= new Ryder_Surveys__c();
rs.Customer_Sat_Overall_Satisfaction_FSL__c= '8';
rs.Customer_Sat_Likelihood_to_Renew__c='8';
rs.Customer_Sat_Willingness_to_Refer__c ='8';
rs.Customer_Sat_Shop_Communications__c='8';
rs.Customer_Sat_Maintenance_Satisfaction__c ='8';
rs.Customer_Sat_Acct_Mgr_Satisfaction__c='8';
insert rs;  
}
}