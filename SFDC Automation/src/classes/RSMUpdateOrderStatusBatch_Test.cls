@isTest
private class RSMUpdateOrderStatusBatch_Test{

static testmethod void unitTest(){
    Test.startTest();
    RSMCreateTestData.GetCustomSettingsRecord();
    
    List<vehicle__c> vlist=new List<vehicle__c>();
        for(integer i=0;i<3;i++){
            Vehicle__c v=new Vehicle__c();
            v.Name=i+'';
            vList.add(v);
    }
    insert vList;
    RSM_PO__c rpo=new RSM_PO__c();
    rpo.unit_number__c=vlist[0].id;
    rpo.DateReceived__c=Date.valueOf('2014-03-01');
    insert rpo;
        
    RSM_PO__c rpo1=new RSM_PO__c();
    rpo1.unit_number__c=vlist[1].id;
    rpo1.DateShipped__c=Date.valueOf('2014-03-01');
    insert rpo1;
    
    RSM_PO__c rpo2=new RSM_PO__c();
    rpo2.unit_number__c=vlist[2].id;
    rpo2.DateOrdered__c=Date.valueOf('2014-03-01');
    insert rpo2;

    
    Vehicle__c v=new Vehicle__c();
    v.RSM_order_Status__c='Received';
    v.RSM_order_Status__c='Shipped';
    v.RSM_order_Status__c='Ordered';
    insert v;

    RSMUpdateOrderStatusBatch  ruo= new RSMUpdateOrderStatusBatch ();
    ruo.query='select Id,Unit_Number__c,DateReceived__c,DateShipped__c,DateOrdered__c from RSM_PO__c where LastModifiedDate=LAST_N_DAYS:0'; 
    database.executebatch(ruo);
    
    Test.stopTest();

}
}