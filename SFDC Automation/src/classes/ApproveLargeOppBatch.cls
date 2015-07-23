//Batch Class to update create Tasks 
global class ApproveLargeOppBatch implements Database.Batchable<SObject>{
    
    public String query;
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('OMT1 - query = ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        system.debug('OMT2 - scope = ' + scope);

        date myDate = System.Today();
        Id taskRecordTypeId = LABEL.Ryder_Task_Record_ID;
        Set<String> setManager=new Set<String>();
        List<Task> lstTaskToCreate = new List<Task>();
        List<User> lstManager = new List<User>();
        
        for(Opportunity opp:scope){    
            setManager.add(opp.Owner.ManagerId); 
        }    
        
        system.debug('OMT3 - setManager.size() = ' + setManager.size() + ' setManager= ' + setManager);
                
        if(setManager.size() > 0) 
        {
            lstManager = [Select id, Name from User where id in : setManager];
        }
        
        system.debug('OMT4 - lstManager .size() = ' + lstManager.size() + ' lstManager = ' + lstManager);
        
        if (lstManager.size() > 0)
        {
            for (User mgr:  lstManager)
            {
                if(mgr.id != null)
                {       
                    Task T = new Task();
                    T.OwnerId = mgr.id;//Assigned To
                    T.Type = 'Management Activity';
                    T.Subject = 'Review opportunity closed for more than 10 units';
                    T.ActivityDate = myDate.addDays(7);
                    T.Status = 'Not Started';
                    T.Priority = 'Normal';
                    T.RecordTypeId = taskRecordTypeId;
                    T.Description = 'Please click on the following link to review large opportunity for validation: ' + LABEL.HostURL +'/apex/ApproveLargeOppPage?id=' + mgr.Id;
                    lstTaskToCreate.add(T);
                }            
            }
        }
        system.debug('OMT5 - lstTaskToCreate = ' + lstTaskToCreate);       
        if (lstTaskToCreate.size() > 0) insert lstTaskToCreate;
    }
    
    global void finish(Database.BatchableContext BC){
    }    
}