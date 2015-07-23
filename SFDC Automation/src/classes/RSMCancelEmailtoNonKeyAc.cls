//FR134-Cancellation Email to Non-Key Accounts once contract cancels
//when all the units have cancelled the contract
global class RSMCancelEmailtoNonKeyAc implements Database.Batchable<SObject>{
    
    public String query;
    global Database.QueryLocator start(Database.BatchableContext BC){
          System.debug('query : '+query);
          return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        List<Messaging.SingleEmailMessage> EmailList=new List<Messaging.SingleEmailMessage>();
        Set<string> LesseeNoSet=new Set<String>(); 
        Set<Id> accountIdSet=new Set<Id>();
        Set<Id> conIds=new Set<Id>();
        Set<Id> conIdsToEmail=new Set<Id>(); 
        Set<Id>  taskExistConIdsSet=new Set<Id>();          
        for(Account acc:scope){
            LesseeNoSet.add(acc.LesseeNo__c);
        }

    Map<String,String> keyContactEmailMap=new Map<String,String>();
        for(Key_Contact__c kc:[select Id,Contact__r.Email,AccountId__r.LesseeNo__c from Key_Contact__c where Contact_Role__c='RydeSmart' and AccountId__r.LesseeNo__c in :LesseeNoSet]){
            keyContactEmailMap.put(kc.AccountId__r.LesseeNo__c,kc.Contact__c);
        }
        
    for(RSM_Contract__c c:[select Id,Lessee__c,Contract_Number__c, Cancelled_Contract_details__c,Total_Contract_Detail__c from RSM_Contract__c where Lessee__c in :LesseeNoSet and Status_Name__c='Approved']){
        if(c.Cancelled_Contract_details__c > 0 && c.Total_Contract_Detail__c>0 && c.Total_Contract_Detail__c==c.Cancelled_Contract_details__c){
            conIdsToEmail.add(c.Id);
        }
    }
       
    for(Task t:[select Id,whatId from Task where subject='Email: RydeSmart Cancellation' and whatId in:conIdsToEmail]){
        taskExistConIdsSet.add(t.whatId);
    } 
    conIdsToEmail.removeAll(taskExistConIdsSet);
    String etId=[select Id from EmailTemplate where developerName='RSMCancelEmailtoNonKeyAc'].Id;       
    System.debug('Saad etId = ' + etId);
    for(RSM_Contract__c c:[select Id,Lessee__c,Contract_Number__c, Cancelled_Contract_details__c,Total_Contract_Detail__c from RSM_Contract__c where Id in:conIdsToEmail]){
       System.debug('Saad c = ' + c);        
       if(keyContactEmailMap.get(c.Lessee__c)!=null){    
            System.debug('Saad c.Lessee__c = ' + c.Lessee__c);      
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(keyContactEmailMap.get(c.Lessee__c));                 
            mail.setTemplateId(etId);
            mail.setBccSender(true);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(true);
            mail.setWhatId(c.Id);
            EmailList.add(mail);   
            System.debug('Saad EmailList = ' + EmailList);
        }  
    } 
    if(EmailList!=null && EmailList.size()>0 && !Test.isRunningTest()){
        System.debug('EmailList : '+EmailList);
        Messaging.sendEmail(EmailList);
    } 
    }

    global void finish(Database.BatchableContext BC){
    }
}