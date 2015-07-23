@isTest
private class RSMUpdateVehicleBatch_Test{

static testmethod void unitTest(){
    Test.startTest();
    List<Vehicle__c> vList=new List<Vehicle__c>();
    for(integer i=0;i<2;i++){
            Vehicle__c v=new Vehicle__c();
            v.Name=i+'';
            vList.add(v);
    }
    insert vList;
    
    RSM_Contract__c rCon=new RSM_Contract__c();    
    rCon.Name='12345';    
    insert rCon;
    
    RSM_ContractDetail__c rc=new RSM_ContractDetail__c();
    rc.Name='test1';
    rc.Unit_Number__c=vList[0].Id;
    rc.Contract_Number__c=rCon.Id;
    rc.Action_Name__c='Add';
    rc.Is_Current__c = true;
    insert rc;
    
    RSM_ContractDetail__c rc1=new RSM_ContractDetail__c();
    rc1.Name='test1';
    rc1.Unit_Number__c=vList[1].Id;
    rc1.Contract_Number__c=rCon.Id;
    rc1.Action_Name__c='Cancel';
    rc1.Is_Current__c = true;
    insert rc1;
    
    RSMUpdateVehicleBatch rvb=new RSMUpdateVehicleBatch();
    rvb.query='select Is_Current__c, Contract_Number__r.Account__c, Id,Unit_Number__c,'
    			+'Service_Name__c,Contract_Number__r.Status_Name__c, '
    			+'RSM_ContractDetail__c.Unit_Number__r.Account__c,Action_Name__c from RSM_ContractDetail__c';
    Database.executeBatch(rvb);
    
    Test.stopTest();

}
}