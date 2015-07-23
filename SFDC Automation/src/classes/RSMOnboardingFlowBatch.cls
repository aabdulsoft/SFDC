//Batch Class to create a task for the CCM to Schedule Training
global class RSMOnboardingFlowBatch implements Database.Batchable<SObject>{

  public String query;
  global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<Account> scope){
       Set<Id> accIds=new Set<Id>();
       Set<Id> taskExistAccIds=new Set<Id>();
       for(Account a:scope){
           accIds.add(a.Id);
       }
           
       String rsmRT=[select Id from RecordType where sobjecttype='Task' and developerName='RydeSmart_Task'].Id;
       for(Task t:[select Id,whatId from Task where recordTypeId=:rsmRT and Subject='Contact Customer and schedule Training' and whatId in:accIds]){
           taskExistAccIds.add(t.whatId);
       }
       accIds.removeAll(taskExistAccIds);
              
       List<Task> taskList=new List<Task>();
       List<Account> accUpdateList=new List<Account>();
       System.debug('accIds : '+accIds);
       for(Account acc:[select Id,OwnerId,RSM_CCMs__c from Account where Id in:accIds and RSM_Onboarding__c NOT IN ('trained','Contacted and Training Scheduled')]){
         if(acc.RSM_CCMs__c!=null){
           Task t=new Task();
           t.OwnerId=acc.RSM_CCMs__c;
           t.whatId=acc.Id;
           t.type='Other';
           t.subject='Contact Customer and schedule Training';
           t.status='Not Started';
           t.priority='Normal';
           t.ActivityDate=System.today();
           t.recordtypeId=rsmRT;
           taskList.add(t);
           }
       } 
       
        if(taskList!=null && taskList.size()>0){
               insert taskList;
           }
      
   }

   global void finish(Database.BatchableContext BC){
   }
}