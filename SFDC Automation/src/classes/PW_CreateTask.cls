global class PW_CreateTask implements Database.Batchable<sObject>
{
    global Database.Querylocator start(Database.BatchableContext bc) 
    {   
        //Get the opportunities in the Partial Win object to create tasks that have not been created for TODAY.
        /* -- Daily Schedule -- */
        String sQuery = 'SELECT Opportunity__c FROM PartialWinRateSheet__c WHERE CreatedDate >= LAST_N_DAYS:15 AND IsTaskCreated__c = false';
        
        /* Temporary (Creates tasks for all records) 
        String sQuery = 'SELECT Opportunity__c FROM PartialWinRateSheet__c';
        */
        
        return Database.getQueryLocator(sQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<PartialWinRateSheet__c> scope) 
    {   
        Set<ID> sAccIds = new Set<ID>();
        Set<ID> sUserIds = new Set<ID>();
        //List<ID> lOppIds = new List<ID>();
        Set<ID> sPartialWinIds = new Set<ID>();
        
        for(PartialWinRateSheet__c pw : scope)
        {
            sPartialWinIds.add(pw.Opportunity__c);
        } 
        
        if(sPartialWinIds.size() > 0)
        {
            //Get opportunity data
            List<Opportunity> oppResult = [Select Id, Name, AccountId, OwnerId From Opportunity where Id in :sPartialWinIds];
            
            for(Opportunity Opp : oppResult)
            {
                sAccIds.add(Opp.AccountId);
                sUserIds.add(Opp.OwnerId);
            }
            
            //Check if opportunity owner is active. If inactive then get owner's manager.
            Map<Id,User> mRecOwner = new Map<Id,User>([Select isActive, ManagerId, Id 
                                                            From User Where 
                                                            ID in : sUserIds]);
            
            //Get NCA user from Account.
            Map<Id,Account> mNCAuser = new Map<Id,Account>([Select NCA__c, Account_Classification__c 
                                                            From Account Where ID in : sAccIds]);
            
            List<Task> lTask = new List<Task>();
            for(Opportunity Opp : oppResult)
            {
                User recOwner = mRecOwner.get(Opp.OwnerId);
                Account NCAuser = mNCAuser.get(Opp.AccountId);
                //Declare Date
                date myDate = System.Today();
                
                //Create a new Task
                Task T = new Task();
                T.OwnerId = (recOwner.IsActive == true ? Opp.OwnerId : recOwner.ManagerId); //Assigned To
                T.WhatId = Opp.Id; //Related To
                T.Orignal_Task_Date__c = System.Today();
                T.Subject = 'Update Status of the opportunity with un-booked rate sheets';
                T.Description = 'Un-booked rate sheets link: ' + LABEL.HostURL +'/apex/PWRateSheet?id=' + Opp.Id;
                T.ActivityDate = myDate.addDays(5); //Due Date
                T.Status = 'Not Started';
                T.Priority = 'High';
                T.Type = 'Partial Win';
                T.Call_Attempts__c = 0;
                lTask.add(T);
                system.debug('task owner/manager : ' + T); 
        
                if(NCAuser != null && NCAuser.NCA__c != null && NCAuser.Account_Classification__c == 'National'){
                    //Create a new Task for the NCA
                    Task ncaT = new Task();
                    ncaT.OwnerId = NCAuser.NCA__c; //Assigned To
                    ncaT.WhatId = Opp.Id; //Related To
                    ncaT.Orignal_Task_Date__c = System.Today();
                    ncaT.Subject = 'Update Status of the opportunity with un-booked rate sheets';
                    ncaT.Description = 'Un-booked rate sheets link: ' + LABEL.HostURL +'/apex/PWRateSheet?id=' + Opp.Id;
                    ncaT.ActivityDate = myDate.addDays(5); //Due Date
                    ncaT.Status = 'Not Started';
                    ncaT.Priority = 'High';
                    ncaT.Type = 'Partial Win';
                    ncaT.Call_Attempts__c = 0;
                    lTask.add(ncaT);
                    system.debug('task NCA : ' + ncaT); 
                }
            }
            if(lTask.size() > 0){
                insert lTask;
            	
            	//Update partial win records as task has been created
    	        List<PartialWinRateSheet__c> currentPW = [SELECT Id FROM PartialWinRateSheet__c WHERE Opportunity__c in :sPartialWinIds];
		        List<PartialWinRateSheet__c> lUpdatePW = new List<PartialWinRateSheet__c>();
		        for(PartialWinRateSheet__c pw : currentPW){
		            PartialWinRateSheet__c P = new PartialWinRateSheet__c();
		            P.Id = pw.Id;
		            P.IsTaskCreated__c = true;
		            lUpdatePW.add(P);
		        }
		        if(lUpdatePW.size() > 0)
		            update lUpdatePW;
            }
        }
    }
    
    global void finish (Database.Batchablecontext BC) 
    {
        
    }
    
}