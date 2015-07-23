/*
* 
*   Helper class for the trigger UpdLatestUpdateTskTrigger that updates the values of Latest Update 
*   field on the Account/Opportunity when a new Task of Type = 'Account/Opportunity Update' is created 
*   on Account/Opportunity by the Account/Opportunity owner respectively or NCA or SAC.
*
*   Author                     |Date               |Comment
*   --------------------------|-------------------|--------------------------------------------------
*   Saad Wali Jaan      |06.18.2015     |First draft
*
*/

public class UpdLatestUpdateTskTriggerHelper {

    public static void UpdateAccOpp(List<Task> lTask) {
    
        system.debug('UALUTH1.0');
              
        //List of Profiles for which the field needs to be updated  
        List<string> lProfiles = new List<string>(LABEL.LatestUpdateProfiles.split(','));
        system.debug('UALUTH1.1 - lProfiles = ' + lProfiles);
        
        //Getting a map of all users who are in the specified list of Sales Profile
        Map<Id,Profile> mapProfiles=new Map<id,profile>([Select p.Id from Profile p where Name in :lProfiles]);
        system.debug('UALUTH1.2 - mapProfiles = ' + mapProfiles);      
        
        //Map to store the id and Account of the Task
        Map<id, id> mapTskAcc = New Map<id, id>();
        //Map to store the id and Opportunity of the Task
        Map<id, id> mapTskOpp = New Map<id, id>();

        //List to store the AccountId and Account Owner of the account related to the task
        List<Account> lstAcc = New List<Account>();
        //List to store the OpportunityId and OpportunityOwner of the opportunity related to the task
        List<Opportunity> lstOpp = New List<Opportunity>();

        //Set to store the Id's of the Tasks for which the task owner is same as Account owner
        Set<id> setTskAcc = New Set<id>();
        //Set to store the Id's of the Tasks for which the task owner is same as Opportunity owner 
        Set<id> setTskOpp = New Set<id>();
        
        //Map to hold data of the Accounts to be updated
        Map<id, Account> mapAccToUpdate = New Map<id, Account>();
        //Map to hold data of the Opportunites to be updated
        Map<id, Opportunity> mapOppToUpdate = New Map<id, Opportunity>();
        
        system.debug('UALUTH1.3 - lTask = ' + lTask);
        
        //Traverse through the list of the task so as to get the Acc & Opp related to the task
        if (lTask.size() > 0)
        {  
            system.debug('UALUTH1.3.1');
            for (Task tsk1: lTask)
            {               
                system.debug('UALUTH1.3.2');
                string relatedToId = (string) tsk1.WhatId; 
                if (relatedToId.substring(0,3)=='001')
                {
                    system.debug('UALUTH1.3.3');
                    mapTskAcc.put(tsk1.id, tsk1.AccountId);
                }
                else if (relatedToId.substring(0,3)=='006')
                {
                    system.debug('UALUTH1.3.4');
                    //mapTskAcc.put(tsk1.id, tsk1.AccountId);
                    mapTskOpp.put(tsk1.id, relatedToId);
                }
            }
        }
        system.debug('UALUTH1.4.1 - mapTskAcc = ' + mapTskAcc);
        system.debug('UALUTH1.4.2 - mapTskOpp = ' + mapTskOpp);
        
        //Getting the ownerid of the account associated with the task
        if(mapTskAcc.size() > 0) lstAcc = [select id, OwnerId, RecordTypeId from Account where id in :mapTskAcc.values()];
        system.debug('UALUTH1.5.1 - lstAcc = ' + lstAcc);
        //Getting the ownerid of the opportunity associated with the task
        if(mapTskOpp.size() > 0) lstOpp = [select id, OwnerId, Account.OwnerId, RecordTypeId from Opportunity where id in :mapTskOpp.values()];
        system.debug('UALUTH1.5.2 - lstOpp = ' + lstOpp);
        
        //Traverse through the list to check which task
        if (lTask.size() > 0)
        {  
            system.debug('UALUTH1.6');
            for (Task tsk2: lTask)
            {
                system.debug('UALUTH1.7');
                for (Account acc: lstAcc)
                {
                    system.debug('UALUTH1.7.1-acc.RecordTypeId = ' + acc.RecordTypeId + ', LABEL.PureRentalAccRecType = ' + LABEL.PureRentalAccRecType);
                    system.debug('UALUTH1.7.2-acc.OwnerId = ' + acc.OwnerId);
                    if(acc.OwnerId == tsk2.OwnerId && acc.RecordTypeId != LABEL.PureRentalAccRecType && !(UVS_Util.isUVSProfile(acc.OwnerId)))
                    {
                        system.debug('UALUTH1.7.3');
                        setTskAcc.add(tsk2.id);
                    }
                }
                system.debug('UALUTH1.8');
                for (Opportunity opp: lstOpp)
                {
                    system.debug('UALUTH1.8.1-opp.RecordTypeId = ' + opp.RecordTypeId + ', LABEL.OppRecordTypeUVS = ' + LABEL.OppRecordTypeUVS);
                    system.debug('UALUTH1.8.2-opp.OwnerId = ' + opp.OwnerId + ', opp.Account.OwnerId = ' + opp.Account.OwnerId);
                    
                    if(((opp.OwnerId == tsk2.OwnerId) || (opp.Account.OwnerId == tsk2.OwnerId)) && opp.RecordTypeId != LABEL.OppRecordTypeUVS)
                    {
                        system.debug('UALUTH1.8.3');
                        setTskOpp.add(tsk2.id);
                    }
                }
            }
        }
        system.debug('UALUTH1.9.1 - setTskAcc = ' + setTskAcc);
        system.debug('UALUTH1.9.2 - setTskOpp = ' + setTskOpp);
        
        //Get the list of all Task which satisfies the following condition
        List<Task> lstTasks = [Select Id, AccountId, WhatId, Description, OwnerId from Task where Id in :lTask and (Owner.ProfileId in :mapProfiles.keyset() or id in :setTskAcc or id in :setTskOpp)];
        
        system.debug('UALUTH1.10 - lstTasks = ' + lstTasks);
        
        //traverse through the list of Tasks
        if (lstTasks.size()> 0)
        {
            for (Task tsk: lstTasks)
            {                   
                system.debug('UALUTH1.11');
                string relatedToId = (string) tsk.WhatId; 
                if (relatedToId.substring(0,3)=='001')
                {  
                    system.debug('UALUTH1.12.1');
                    if(!mapAccToUpdate.containskey(relatedToId))
                    {
                        system.debug('UALUTH1.12.2');
                        mapAccToUpdate.put(relatedToId, new Account(id=relatedToId, Latest_Update__c=tsk.Description));
                    }
                    else
                    {
                        system.debug('UALUTH1.12.3');
                        mapAccToUpdate.remove(relatedToId);
                        mapAccToUpdate.put(relatedToId, new Account(id=relatedToId, Latest_Update__c=tsk.Description));
                    }
                }
                if (relatedToId.substring(0,3)=='006')
                {  
                    system.debug('UALUTH1.13.1');
                    if(!mapOppToUpdate.containskey(relatedToId))
                    {
                        system.debug('UALUTH1.13.1');
                        mapOppToUpdate.put(relatedToId, new Opportunity(id=relatedToId, Latest_Update__c=tsk.Description));
                    }
                    else
                    {
                        system.debug('UALUTH1.13.2');
                        mapOppToUpdate.remove(relatedToId);
                        mapOppToUpdate.put(relatedToId, new Opportunity(id=relatedToId, Latest_Update__c=tsk.Description));
                    }
                }    
            }
        }
        system.debug('UALUTH1.14.1 - mapAccToUpdate = ' + mapAccToUpdate);
        if (mapAccToUpdate.size() > 0) update mapAccToUpdate.values(); 
        system.debug('UALUTH1.14.2 - mapOppToUpdate = ' + mapOppToUpdate);
        if (mapOppToUpdate.size() > 0) update mapOppToUpdate.values();
        system.debug('UALUTH1.14.3');
    }
}