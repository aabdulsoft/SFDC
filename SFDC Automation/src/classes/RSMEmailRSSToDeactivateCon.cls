//FR033-Generate Email to RSS once unit cancels their contract to request de-activation
global class RSMEmailRSSToDeactivateCon implements Database.Batchable<SObject>{
    
    public String query;
    global Database.QueryLocator start(Database.BatchableContext BC){
          System.debug('query : '+query);
          return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<RSM_ContractDetail__c> scope){
    
        List<Messaging.SingleEmailMessage> EmailList=new List<Messaging.SingleEmailMessage>();
        List<RSM_ContractDetail__c> updateCDList=new List<RSM_ContractDetail__c>();
        Set<Id> conDetId=new Set<Id>(); 
        String[] userIds=new String[]{};
        User u=[select Id from User where userName = : RyderGlobalVariables.RyderSmart_RSS];
        String etId=[select Id from EmailTemplate where developerName='RSMEmailRSSToDeactivateCon'].Id;       
        if(scope!=null && scope.size()>0){
            for(RSM_ContractDetail__c cd:scope){
                cd.Email_sent_to_De_Activate_contract__c=true;
                updateCDList.add(cd);
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(u.id);                 
            mail.setTemplateId(etId);
            mail.setBccSender(true);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(false);
            //mail.setWhatId(cd.Id);
            EmailList.add(mail);
       }
       if(EmailList.size() > 0 && !Test.isRunningTest()) 
       		Messaging.sendEmail(EmailList);
        
        update updateCDList;
    }

    global void finish(Database.BatchableContext BC){
    }
}