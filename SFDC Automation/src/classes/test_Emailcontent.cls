@isTest(SeeAllData=true)
private class test_Emailcontent {
    static testMethod void TestEmailcontent(){
       Account acct = TestUtil.createAccount('Ryder FMS Parent Account', 'Customer');
        insert acct;
       Contact cont = TestUtil.createContact(acct.Id);
       insert cont;
        Ryder_Surveys__c rs= new Ryder_Surveys__c();
        rs.RecordTypeId=[Select Id from RecordType where name=: 'CSI Survey' and SobjectType =: 'Ryder_Surveys__c'].Id;
        rs.Contact__c=cont.id;
        rs.CS_Score__c=4;
        rs.Customer_Sat_Overall_Satisfaction_FSL__c= '8';
        rs.Customer_Sat_Likelihood_to_Renew__c='8';
        rs.Customer_Sat_Willingness_to_Refer__c ='8';
        rs.Customer_Sat_Shop_Communications__c='8';
        rs.Customer_Sat_Maintenance_Satisfaction__c ='8';
        rs.Customer_Sat_Acct_Mgr_Satisfaction__c='8';
        insert rs; 
        List<String> str=new List<String>();
        str.add('abc@gmail.com');
        str.add('abc@gmail1.com');
    
       //(string[] idList, Ryder_Surveys__c rs, string objType)
    
        Emailcontent.sendMail(str, rs, 'Survey');
    }
}