@isTest
private class RSMCreateSalesQuestionaairTask_Test{

static testmethod void unitTest(){
    RSMCreateTestData.GetCustomSettingsRecord();
    
    Account ac=new Account();
    ac.Name='Test1';
    ac.LesseeNo__c='123';
    ac.RSM_CCMs__c=UserInfo.getUserId();
    ac.RSM_Onboarding__c='';
    insert ac;
    
    Customer_Branch__c cb=new Customer_Branch__c();
    cb.Name='Test Customer Branch';
    cb.Ryder_HQ_Account__c=ac.Id;
    insert cb;
    Vehicle__c v=new Vehicle__c();
    v.Name='1234';
    v.CUSTOMER_BRANCH__c=cb.Id;
    v.RSM__c='Approved';
    insert v;
    
    Account ac1=new Account();
    ac1.Name='Test12';
    ac1.LesseeNo__c='1234';
    ac1.RSM_CCMs__c=UserInfo.getUserId();
    ac1.RSM_Onboarding__c='';
    insert ac1;
    RecordType rt=[select Id from RecordType where sobjecttype='Task' and DeveloperName='RydeSmart_Task'];
    Task t1=new Task();
    t1.Subject='Sales Questionaair';
    t1.whatId=ac1.Id;
    t1.RecordtypeId=rt.Id;
    insert t1;
    
    Test.startTest();
    
    RSMCreateSalesQuestionaairTask rcsq=new RSMCreateSalesQuestionaairTask ();
    rcsq.query='select Id from Account where RSM_Onboarding__c=\'\' and Id in ('+'\''+ac.Id+'\',\''+ac1.Id+'\') limit 2 '; 
    Database.executeBatch(rcsq);
    
    Test.stopTest();

}
}