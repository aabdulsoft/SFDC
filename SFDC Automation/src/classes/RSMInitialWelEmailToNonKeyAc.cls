//FR010-Batch Class to Send Initial Welcome Email to Non-Key Ac once Onboarding begins
global class RSMInitialWelEmailToNonKeyAc implements Database.Batchable<SObject>{

    public String query;
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('query : '+query);
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Account> scope){
        List<Messaging.SingleEmailMessage> EmailList=new List<Messaging.SingleEmailMessage>();
        List<Account> updateAcctList=new List<Account>();
        Set<Id> accountIdSet=new Set<Id>();
        Set<Id> taskExistAccIds=new Set<Id>();
        Set<Id> accIds=new Set<Id>(); 
        
        for(Account acc:scope){
            accountIdSet.add(acc.Id);
        }
      
        //String rsmRT=[select Id from RecordType where sobjecttype='Task' and developerName='RydeSmart_Task'].Id;
        for(Task t:[select Id,whatId from Task where subject='Email: Welcome to Ryder' and whatId in:accountIdSet]){
            taskExistAccIds.add(t.whatId);
        }
        accountIdSet.removeAll(taskExistAccIds);
      
        Set<Id> custBranch=new Set<Id>();
        Map<String,String> keyContactMap=new Map<String,String>();
        Map<String,String> keyContactEmailMap=new Map<String,String>();
        system.debug('accIds:'+accIds);
        for(Key_Contact__c kc:[select Id,Contact__c,Contact__r.Email,AccountId__c from Key_Contact__c where Contact__c!=null and Contact__r.Email!='' and Contact_Role__c='RydeSmart' and AccountId__c in :accountIdSet]){
            keyContactMap.put(kc.AccountId__c,kc.Contact__c);
            keyContactEmailMap.put(kc.AccountId__c,kc.Contact__r.Email);
        }
        system.debug('keyContactEmailMap:'+keyContactEmailMap);
        system.debug('keyContactMap:'+keyContactMap);
        for(Account acc:[select Id from Account where Id in:accountIdSet]){
        if(keyContactMap.get(acc.Id)!=null){      
            String etId=[select Id from EmailTemplate where developerName='RSMInitialWelEmailToNonKeyAc'].Id;      
          
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{keyContactEmailMap.get(acc.Id)});
            mail.setTargetObjectId(keyContactMap.get(acc.Id));
            mail.setTemplateId(etId);
            mail.setBccSender(true);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(true);
            mail.setWhatId(acc.Id);
            System.debug('Mail : '+mail);
            EmailList.add(mail);   
        }
        } 
      	if(EmailList.size() > 0 && !Test.isRunningTest())
       		Messaging.sendEmail(EmailList);
       
    }

    global void finish(Database.BatchableContext BC){
    }
}