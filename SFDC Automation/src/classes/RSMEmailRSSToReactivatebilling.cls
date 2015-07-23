//FR034-Generate an email to RSS to reactivate billing  when FSL is billing, approved contract for RydeSmart exists and RydeSmart is not billing. 
//RSM VehicleValidationDetails object - Rule # 11 satisfies the above condition
global class RSMEmailRSSToReactivatebilling implements Database.Batchable<SObject>{
    
    public String query;
    global Database.QueryLocator start(Database.BatchableContext BC){
          System.debug('query : '+query);
          return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<RSM_VehicleValidationDetails__c> scope){
    
        List<Messaging.SingleEmailMessage> EmailList=new List<Messaging.SingleEmailMessage>();
        List<RSM_ContractDetail__c> updateCDList=new List<RSM_ContractDetail__c>();
        Set<Id> VehIdSet=new Set<Id>();
        Set<Id> taskExistVehIds=new Set<Id>(); 
        String[] userIds=new String[]{};
        User u=[select Id from User where userName=: RyderGlobalVariables.RyderSmart_RSS];
        //EmailTemplate etId = [Select e.Subject, e.Id, e.HtmlValue From EmailTemplate e where developerName='RSMEmailRSSToReactivatebilling'];       
        
        //String sHtmlValue = etId.HtmlValue;
        
        if(scope!=null && scope.size()>0){
            for(RSM_VehicleValidationDetails__c v:scope){
                VehIdSet.add(v.id);
            }
        String rtType=[Select Id from RecordType where sobjecttype='Task' and developerName='RydeSmart_Task'].Id;
        for(Task t:[select Id,whatId from Task where recordtypeId=:rtType and  subject='Reactivate RydeSmart Billing' and whatId in:VehIdSet]){
            taskExistVehIds.add(t.whatId);
        }    
            VehIdSet.removeAll(taskExistVehIds);
         if(VehIdSet!=null && VehIdSet.size()>0)
         {
            String sVehicleIds = '';
            for(RSM_VehicleValidationDetails__c v:scope)
            {
                if(VehIdSet.contains(v.id))
                {
                    if (sVehicleIds == '')
                    {
                        sVehicleIds += v.Unit_Number__r.Name;
                    }
                    else
                    {
                        sVehicleIds += ',' + v.Unit_Number__r.Name;
                    }
                }
            }
            String sHtmlValue = '';
            sHtmlValue = '<p><img alt="" src="https://cs10.salesforce.com/servlet/servlet.ImageServer?oid=00DJ0000001MAFb&amp;id=01560000000jtOy" style="width: 177px; height: 88px;" /></p>';
            sHtmlValue += '<p>Hello,<br />';
            sHtmlValue += '<br />';
            sHtmlValue += 'Reactivate billing for the below Vehicles as FSL is billing, approved contract for RydeSmart exists and RydeSmart is not billing.<br />';
            sHtmlValue += 'Vehicle Numbers: ' + sVehicleIds;
            sHtmlValue += '<p>&nbsp;</p>';
            sHtmlValue += '<p>Regards,</p>';
            sHtmlValue += '<p>RydeSmart Support</p>';
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(u.id);                 
            //mail.setTemplateId(etId);
            mail.setHtmlBody(sHtmlValue);
            mail.setSubject('Reactivate RydeSmart Billing');
            mail.setBccSender(true);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(false);
            //mail.setWhatId(cd.Id);
            EmailList.add(mail);
        }
       }
       if(EmailList.size() > 0 && !Test.isRunningTest())
            Messaging.sendEmail(EmailList);
       
        //****
       String rsmRT=[select Id from RecordType where sobjecttype='Task' and developerName='RydeSmart_Task'].Id;     
       List<Task> taskList=new List<Task>();
       List<RSM_VehicleValidationDetails__c> VVDUpdateList=new List<RSM_VehicleValidationDetails__c>();
       for(RSM_VehicleValidationDetails__c vvd:[select Id,Name from RSM_VehicleValidationDetails__c where Id in:VehIdSet]){
           Task t=new Task();
           //t.OwnerId=vvd.Name;
           t.whatId=vvd.Id;
           t.type='Email Send';
           t.subject='Reactivate RydeSmart Billing';
           t.status='Completed';
           t.priority='Normal';
           t.ActivityDate=System.today();
           t.recordtypeId=rsmRT;
           taskList.add(t);
           
       }
       try{
           if(taskList!=null && taskList.size()>0){
               insert taskList;
           }
       }catch(Exception e){
       }
   //*******/  
           
    }

    global void finish(Database.BatchableContext BC){
    }
}