@isTest
private class RSMUpdateAccountRevenueBatch_Test{

    static testmethod void unitTest(){
    Test.startTest();
	RSMCreateTestData.GetCustomSettingsRecord();
    
    Account Ac=new Account ();
    Ac.RSM_Billing__c=true;
    Ac.Name ='Test';
    insert Ac;
    
    Customer_Branch__c cb=new Customer_Branch__c();
    cb.Name='Test Customer Branch Acc';
    cb.Ryder_HQ_Account__c=Ac.Id;
    
    insert cb;
    
    Vehicle__c v=new Vehicle__c();
    v.RSM_Billing_Status__c=True;
    v.CUSTOMER_BRANCH__c=cb.Id;
    v.Name='423242';
    v.Account__c=Ac.Id;
    insert v;
    
    RSM_Contract__c rc=new RSM_Contract__c();
    rc.Name='423242';
    
    insert rc;
    
    RSM_ContractDetail__c rcd=new RSM_ContractDetail__c();
    rcd.Is_Current__c=True;
    rcd.Unit_Number__c=v.Id;
    rcd.Contract_Number__c=rc.Id;
    insert rcd;
  
      RSMUpdateAccountRevenueBatch rurs= new RSMUpdateAccountRevenueBatch ();
      rurs.query='select Id from Account where Id=\''+Ac.Id +'\' Limit 1'; 
      database.executebatch(rurs);
    
    Test.stopTest();

}
}