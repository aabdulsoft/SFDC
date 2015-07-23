//Trigger to Update onboarding status once the CCM schedules the training and closes the task
trigger RSMUpdateOnboardingStatus on Task (after update) {    
    List<Task> Tasklist=new List<Task>();
    List<Account> AccList=new List<Account>();
    String rsmRT=[select Id from RecordType where sobjecttype='Task' and developerName='RydeSmart_Task'].Id;
    for(Task T:Trigger.new){
       if(T.recordtypeId==rsmRT && T.Subject=='Contact Customer and schedule Training' && T.status=='Completed'){
           Account ac=new Account(Id=t.whatId,RSM_bypass__c=true,RSM_Onboarding__c='Contacted and Training Scheduled');
           AccList.add(ac);
       }
    }
    
    update AccList;
    
}