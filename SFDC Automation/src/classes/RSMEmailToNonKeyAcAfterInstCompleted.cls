//FR011-Batch Class to Send Email to Non-Key Ac once installation Process is complete for all the contracted vehicles
global class RSMEmailToNonKeyAcAfterInstCompleted implements Database.Batchable<SObject>{
    
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
        List<Vehicle__c> Updatevehlist=new List<Vehicle__c>();
        for(Account acc:scope){
            accountIdSet.add(acc.Id);
        }
        
        List<Task> ltask = [select Id,whatId from Task where subject='Email: RydeSmart Installation Complete' and whatId in:accountIdSet];       
        for(Task t:ltask){
            taskExistAccIds.add(t.whatId);
        }
        accountIdSet.removeAll(taskExistAccIds);
        Map<String,String> keyContactEmailMap=new Map<String,String>();
        List<Key_Contact__c> kcont = [select Id,Contact__r.Email,AccountId__c from 
                           Key_Contact__c where AccountId__c in :accountIdSet 
                           and Contact_Role__c = 'RydeSmart' and Contact__r.Email_does_not_exist__c = false and 
                           Contact__r.Email <> '' and Contact__r.EmailBouncedReason = ''];
        for(Key_Contact__c kc:kcont)
        {
            keyContactEmailMap.put(kc.AccountId__c,kc.Contact__c);
        }
                               
        Map<Id,Boolean> conAccId=new Map<Id,Boolean>();
        Map<Id,String> accVehMap = new Map<Id,String>();
        
        List<Vehicle__c> vhcl = [select Id,Name,RSM_Device_Status__c,Account__c,RSM__c 
                        from vehicle__c where Account__c  in :accountIdSet 
                        and RSM__c = 'Approved' and 
                        (RSM_Device_Status__c = 'Installed' or RSM_Device_Status__c = 'Installed with Repairs')];
        for(Vehicle__c v:vhcl)
        {
            if(accVehMap != null && accVehMap.get(v.Account__c) != null)
            {
                String sValue = accVehMap.get(v.Account__c);
                accVehMap.put(v.Account__c, sValue + ',' + v.Name);
            }
            else
            {
                accVehMap.put(v.Account__c,v.Name);
            }         
        }
        
        
        //String etId=[select Id from EmailTemplate where developerName='RSMEmailToNonKeyAcAfterInstCompleted'].Id;
        String sHTMLEmail = '<p> Hi, </p>';
        sHTMLEmail += '<p> RydeSmart Installation completed for all contracted vehicles. </p>';
        List<Task> lTasks = new List<Task>();
        List<Account> acnt = [select Id from Account where Id in:accountIdSet];
        for(Account acc: acnt)
        {
            sHTMLEmail = '<p> Hi, </p>';
            sHTMLEmail += '<p> RydeSmart Installation completed for all contracted vehicles. </p>';
            if(keyContactEmailMap.get(acc.Id) != null && accVehMap.get(acc.Id) != null)
            {
                sHTMLEmail += accVehMap.get(acc.Id);
                sHTMLEmail += '<p> Regards</p>';
                sHTMLEmail += '<p> RideSmart Support </p>';
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(keyContactEmailMap.get(acc.Id));                 
                //mail.setTemplateId(etId);
                mail.setHtmlBody(sHTMLEmail);
                mail.setSubject('RydeSmart Installation Complete');
                mail.setBccSender(true);
                mail.setUseSignature(false);
                mail.setSaveAsActivity(false);
                mail.setWhatId(acc.Id);             
                EmailList.add(mail);
                
                
                Task TaskObj = new Task();
                TaskObj.Subject = 'Email: RydeSmart Installation Complete';
                TaskObj.whatId = acc.Id;
                TaskObj.Description = sHTMLEmail;
                TaskObj.WhoId = keyContactEmailMap.get(acc.Id);
                TaskObj.ActivityDate = System.today();
                TaskObj.Status = 'Completed';
                TaskObj.Priority = 'Normal';
                TaskObj.OwnerId = UserInfo.getUserId();                
                lTasks.add(TaskObj);
            }
        } 
        if(EmailList.size() > 0 && !Test.isRunningTest())
            Messaging.sendEmail(EmailList);
        if(lTasks.size() > 0)
            insert lTasks;
    }

    global void finish(Database.BatchableContext BC){
    }
}