global with sharing class RSM_OrderReportWOContractFR083_Batch implements Database.Batchable<SObject>
{
    /* 
        Query the RSM_VehicleValidationDetails__c object where the Validation Id is: 7
        As this Id is always there which is matching the FR087 condition
    */ 
    public String query = 'Select r.Validation_Rule_Id__c, r.Unit_Number__c, r.Status_Date__c, '
                            +'r.Rule_Description__c, r.Name, r.Id, r.Unit_Number__r.Account__c, r.Unit_Number__r.Account__r.OwnerId '
                            +'From RSM_VehicleValidationDetails__c r where Validation_Rule_Id__c = \'7\'';
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        /* 
            Return the Query Data
        */
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<RSM_VehicleValidationDetails__c> lVehicleValidate)
    {
        /* 
            Get the Task RydeSmart Record Type Id from Custom Settings
        */
        String sTaskRecordTypeId = '';
        Global_Settings__c TaskRydeSmartRecordType = Global_Settings__c.getValues('6');
        // if the custom settings is not null then get the value from settings and out in a local variable
        if(TaskRydeSmartRecordType != null && TaskRydeSmartRecordType.IsActive__c)
            sTaskRecordTypeId = TaskRydeSmartRecordType.Value__c;
        Set<String> sVehicleIds = new Set<String>();
        Set<String> sVehicleExistIds = new Set<String>();
        /* 
            Iterate the Data and collect the Vehicle Ids
        */ 
        for(RSM_VehicleValidationDetails__c VehicleValidate : lVehicleValidate)
        {   
            sVehicleIds.add(VehicleValidate.Unit_Number__c);
        }
        /* 
            Query the Existing Task
        */
        if(sVehicleIds.size() > 0)
        {
            List<Task> lTaskExist = [Select t.WhatId, t.Subject, t.RecordTypeId 
                                    From Task t where RecordTypeId =: sTaskRecordTypeId and 
                                    Subject like '%is Reporting with no Contract' and 
                                    Subject like 'Unit No.%' and WhatId in : sVehicleIds];
            for(Task TaskO : lTaskExist)
            {
                sVehicleExistIds.add(TaskO.WhatId);
            }
        }
        /* 
            Remove the Vehicle Id where the Task has already been created
        */
        sVehicleIds.removeall(sVehicleExistIds);
        List<Messaging.SingleEmailMessage> lSingleEmail = new List<Messaging.SingleEmailMessage>();
        List<Task> lTask = new List<Task>();
        if(sVehicleIds.size() > 0)
        {
            /* 
                Query the Email Tempalte
            */
            List<EmailTemplate> lEmailTemplate = [Select e.Subject, e.Id, e.Body from EmailTemplate e 
                                                    where DeveloperName = 'FR084_Units_Ordered_or_reporting_without_a_Contract'];
            if(lEmailTemplate.size() > 0)
            {
                List<Vehicle__c> lVehicle = [Select v.Unit__c, v.Id, v.Account__r.Owner.Email, 
                                                v.Account__c  From Vehicle__c v where Id in : sVehicleIds and 
                                                Account__r.OwnerId != null and 
                                                Account__r.Owner.IsActive = true];              
                /* 
                    Iterate the Vehicle List and Send Emails also capture the Activity History
                */
                for(Vehicle__c Vehicle : lVehicle)
                {
                    String sMSG = lEmailTemplate[0].Body;
                    String sSubject = lEmailTemplate[0].Subject;
                    sSubject = sSubject.replaceFirst('#VehicleNumber#', Matcher.quoteReplacement(Vehicle.Unit__c));
                    sMSG = sMSG.replaceFirst('#VehicleNumber#', Matcher.quoteReplacement(Vehicle.Unit__c));
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{Vehicle.Account__r.Owner.Email});                 
                    mail.setPlainTextBody(sMSG);
                    mail.setSubject(sSubject);
                    mail.setSaveAsActivity(false);
                    lSingleEmail.add(mail);
                    if(lSingleEmail.size() == 100)
                    {
                        Messaging.sendEmail(lSingleEmail);
                        lSingleEmail = new List<Messaging.SingleEmailMessage>();
                    }
                    Task TaskObj = new Task(WhatId = Vehicle.Id, RecordTypeId = sTaskRecordTypeId, OwnerId = Vehicle.Account__r.OwnerId);
                    TaskObj.Subject = sSubject;
                    TaskObj.Priority = 'Normal';
                    TaskObj.Status = 'Not Started';
                    TaskObj.ActivityDate = System.today().addDays(1);
                    TaskObj.Description = sMSG;
                    lTask.add(TaskObj);
                }
            }
        }
        System.debug('------------>'+lSingleEmail);
        if(lSingleEmail.size() > 0)
            Messaging.sendEmail(lSingleEmail);
        System.debug('------------>'+lTask);
        if(lTask.size() > 0)
            insert lTask;
        System.debug('------------>'+lTask);
    }
    global void finish(Database.BatchableContext BC){
   }
}