//Batch Class to Send Email to RSS Team when "Request for Billing=Send to Billing" in Vehicle object
//Note: should add RSS Team users to emailreceipent list
global class RSMInstallationFlowBatch2 implements Database.Batchable<SObject>{

  public String query;
  global Database.QueryLocator start(Database.BatchableContext BC){
      System.debug('query : '+query);
      return Database.getQueryLocator(query);
   }
   
   global void execute(Database.BatchableContext BC, List<Account> scope){
      List<Messaging.SingleEmailMessage> EmailList=new List<Messaging.SingleEmailMessage>();
      List<Vehicle__c> updateVehList=new List<Vehicle__c>();
      Set<Id> accountIdSet=new Set<Id>();
      for(Account acc:scope){
          accountIdSet.add(acc.Id);
      }
      String[] userIds=new String[]{};
      
      //User u=[select Id from User where userName=RyderGlobalVariables.ETLUSER];
      //User u=[select Id from User where userName=RyderConfig__c.getOrgDefaults().ETL_Username__c];
      User u=[select Id from User where userName=: RyderGlobalVariables.RyderSmart_RSS];
      String etId=[select Id from EmailTemplate where developerName='RSM_Activate_Billing'].Id;
      Set<Id> conAccId=new Set<Id>();
      for(Vehicle__c v:[select Id,Name,RSM_Device_Status__c,Account__c,RSM_Request_for_Billing__c,RSM_Health_Status__c,RSM_Billing_Status__c,RSM_Billing_Email_Date__c from vehicle__c where RSM_Request_for_Billing__c='Send to Activate Billing' and RSM_Billing_Status__c=false and Account__c  in :accountIdSet]){
          v.RSM_Request_for_Billing__c='Sent to Activate Billing';
          v.RSM_Billing_Email_Date__c=System.Today();
          updateVehList.add(v);
          conAccId.add(v.Account__c);
      }
      for(Id ac:conAccId){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(u.Id);
        mail.setTemplateId(etId);
        mail.setBccSender(true);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false);
        mail.setWhatId(ac);
        
        EmailList.add(mail);   
        
       
      } 
      
      If (EmailList.size() > 0 && !Test.isRunningTest())
      	Messaging.sendEmail(EmailList);
     
      update updateVehList;
   }

   global void finish(Database.BatchableContext BC){
   }
}