//Scheduler to create a task to the Sales Representative (FR024)
global class RSMCreateSalesQuestionaairTask implements Database.Batchable<SObject>{

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
       for(Task t:[select Id,whatId from Task where recordTypeId=:rsmRT and whatId in:accIds]){
           taskExistAccIds.add(t.whatId);
       }
       accIds.removeAll(taskExistAccIds);
       System.debug('Accountids----->'+accIds);
      Set<Id> custBranch=new Set<Id>();
       for(Account acc:[select Id,(select id from Customer_Branches__r ) from Account where Id in:accIds]){
           for(Customer_Branch__c cb:acc.Customer_Branches__r){
               custBranch.add(cb.Id);    
           }    
       }
       Set<Id> createTaskList=new Set<Id>();
       for(Vehicle__c v:[select Id,CUSTOMER_BRANCH__r.Ryder_HQ_Account__c from Vehicle__c where RSM__c='Approved' and CUSTOMER_BRANCH__c in:custBranch]){
           createTaskList.add(v.CUSTOMER_BRANCH__r.Ryder_HQ_Account__c);    
       }

      /* Set<Id> createTaskList=new Set<Id>();
       for(Vehicle__c v:[select Id, Account__c from Vehicle__c where RSM__c='Approved' and Account__c in:accIds]){
           createTaskList.add(v.Account__c);    
       } */
       System.debug('createTaskList----->'+createTaskList);
       List<Task> taskList=new List<Task>();
       List<Account> accUpdateList=new List<Account>();
       for(Account acc:[select Id,OwnerId from Account where Id in:createTaskList]){
           Task t=new Task();
           t.OwnerId=acc.OwnerId;
           t.whatId=acc.Id;
           t.type='Other';
           t.subject='RydeSmart Sales Questionnaire';
           t.status='Not Started';
           t.priority='Normal';
           t.ActivityDate=System.today();
           t.recordtypeId=rsmRT;
           taskList.add(t);
           
           Account ac=new Account(Id=acc.Id,RSM_Onboarding__c='Initiation');
           accUpdateList.add(ac);
       }
       try{
           if(taskList!=null && taskList.size()>0){
               insert taskList;
           }
           if(accUpdateList!=null && accUpdateList.size()>0){
               update accUpdateList;
           }
       }catch(Exception e){
       }
       
   }

   global void finish(Database.BatchableContext BC){
   }
}