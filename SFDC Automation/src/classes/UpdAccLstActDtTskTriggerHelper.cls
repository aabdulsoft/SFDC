/*
* 
*   Helper class for the trigger UpdAccLstActDtTskTrigger that updates the values ofLast Sales Interaction field on the Account
*   when a task is marked completed or due date is updated to a future date.
*
*   Author                     |Date               |Comment
*   -------------------------|------------------|--------------------------------------------------
*   Saad Wali Jaan    |12.15.2014   |First draft
*
*/

public class UpdAccLstActDtTskTriggerHelper {

    public static void UpdateAccount(List<Task> lTask, Map<Id, Task> mapTaskOld, Map<Id, Task> mapTaskNew) {
    
        system.debug('Code0');
        
        date dtLSI;
        date dtF2F;

        Id taskRecordTypeId;
        Id eventRecordTypeId;

        Boolean updLSI;
        Boolean updLF2FAD;
        Boolean updLSIF2F;
        
        //List of Profiles for which the field needs to be updated  
        List<string> lSalesProfiles = new List<string>(LABEL.Ryder_Sales_Profiles.split(','));
        
        system.debug('Code0.1 - lSalesProfiles = ' + lSalesProfiles);
        
        //Getting a map of all users who are in the specified list of Sales Profile
        Map<Id,Profile> mapsalesProfiles=new Map<id,profile>([Select p.Id from Profile p where Name in :lSalesProfiles]);
        
        system.debug('Code0.2 - mapsalesProfiles = ' + mapsalesProfiles);      
        
        //List of Task types for which the Face To Face field needs to be updated  
        List<string> lActivityType = new List<string>(LABEL.Activity_Type.split(','));    
        
        system.debug('Code0.3 - lActivityType = ' + lActivityType);   
        
        //Getting the recordTypeId of the 'Ryder Event' and 'Ryder Task'
        eventRecordTypeId = LABEL.Ryder_Event_Record_ID;
        taskRecordTypeId = LABEL.Ryder_Task_Record_ID;
        
        system.debug('Code0.4 - eventRecordTypeId = ' + eventRecordTypeId);
        system.debug('Code0.5 - taskRecordTypeId = ' + taskRecordTypeId);
        
        //Getting a map of all tasks which are in the specified list of Sales Profile
        Map<Id,Task> mapTaskType=new Map<id,Task>([Select t.Id from Task t where Id in :lTask and Recordtypeid=:taskRecordTypeId and Type in :lActivityType]);
        
        system.debug('Code0.6 - mapTaskType = ' + mapTaskType);
        
        //Get the list of all Task which satisfies the following condition
        List<Task> ryderTasks = [Select Id, WhatId, WhoId, Type, Status, ActivityDate 
                      from Task where Id in :lTask and Recordtypeid=:taskRecordTypeId 
                      and Owner.ProfileId in :mapsalesProfiles.keyset()]; 

        //List to hold id of the Accounts for task that are Completed
        List<id> lstTskAcc = new List<Id>();
        //List to hold id of the Accounts for task that are Not Completed
        List<id> lstTskAccNotCom = new List<Id>();

        //List to hold id of the Opportunities for task that are Completed
        List<id> lstTskOpp = new List<Id>();
        //List to hold id of the Opportunities for task that are Not Completed
        List<id> lstTskOppNotCom = new List<Id>();
        
        //List to hold AccountId of the Opportunities in lstTskOpp 
        List<Opportunity> lstOppAcc = new List<Opportunity>();
        //List to hold AccountId of the Opportunities in lstTskOppNotCom
        List<Opportunity> lstOppAccNotCom = new List<Opportunity>();        
        
        //Map to hold the id of Opp & Acc for task that are Completed
        Map<id, id> mapOppAcc = new Map<id, id>();
        //Map to hold the id of Opp & Acc for task that are Not Completed
        Map<id, id> mapOppAccNotCom = new Map<id, id>();        
        
        //List to hold data of the Accounts in lstTskAcc 
        List<Account> lstAccount = new List<Account>();
        //List to hold data of the Accounts in lstTskAccNotCom 
        List<Account> lstAccountNotCom = new List<Account>();
        
        //List to hold the Events for Accounts for which the Event was marked Not Completed
        List<Event> lstAccComEvents = new List<Event>();
        
        //List to hold the tasks for Accounts for which the Task was marked Not Completed
        List<Task> lstAccComTasks = new List<Task>();
        
        //Map to hold the AccountId and Last completed date of non Face to Face Activity
        Map<id, Date> mapAccLstComActDt = New Map<id, Date>();
        //Map to hold the AccountId and Last completed date of Face to Face Activity
        Map<id, Date> mapAccLstComActDtF2F = New Map<id, Date>();
        
        //Map to hold data of the Accounts to be updated for task that are Completed
        Map<id, Account> mapAccToUpdate = New Map<id, Account>();
        //Map to hold data of the Accounts to be updated for task that are Not Completed        
        Map<id, Account> mapAccToUpdateNotCom = New Map<id, Account>();
                
        system.debug('Code1 - lTask = ' + lTask);
        system.debug('Code2 - mapTaskOld = ' + mapTaskOld);
        system.debug('Code3 - mapTaskNew = ' + mapTaskNew);
        system.debug('Code4 - ryderTasks = ' + ryderTasks);
        
        //traverse through the list of Tasks
        for (Task tsk1: ryderTasks)
        {                   
            string relatedToId = (string) tsk1.WhatId;
            string contactId = (string) tsk1.WhoId;
            string taskType = (string) tsk1.Type;
            string taskStatus = (string) tsk1.Status;
            datetime taskDueDateTime = tsk1.ActivityDate;
            
            system.debug('Code3.1 - taskStatus = ' + taskStatus + ', mapTaskOld.get(tsk1.Id).Status = ' + mapTaskOld.get(tsk1.Id).Status);
                
            if (taskStatus == 'Completed')
            {
                system.debug('Code3.2'); 
                if (relatedToId != null) 
                {  
                    system.debug('Code3.3');
                    //If object specified in "Related To" is Account
                    if (relatedToId.substring(0,3)=='001') 
                    {
                        system.debug('Code3.4');
                        lstTskAcc.Add(relatedToId);
                    }
                    //If object specified in "Related To" is Opportunity
                    else if (relatedToId.substring(0,3)=='006')
                    {
                        system.debug('Code3.5');
                        lstTskOpp.add(relatedToId);
                    }
                }
            }
            //Getting only the tasks which were previously marked completed and now updated as Not Completed
            else if ((taskStatus != 'Completed') && (mapTaskOld.get(tsk1.Id).Status == 'Completed'))
            {
                system.debug('Code3.6');
                if (relatedToId != null) 
                {  
                    system.debug('Code3.7');   
                    //If object specified in "Related To" is Account
                    if (relatedToId.substring(0,3)=='001') 
                    {
                        system.debug('Code3.8');
                        lstTskAccNotCom.Add(relatedToId);    
                    }
                    //If object specified in "Related To" is Opportunity
                    else if (relatedToId.substring(0,3)=='006')
                    {
                        system.debug('Code3.9');
                        lstTskOppNotCom.add(relatedToId);
                    }
                }
            }
        }

        system.debug('Code5 - lstTskAcc = ' + lstTskAcc);
        system.debug('Code6 - lstTskOpp = ' + lstTskOpp);
        system.debug('Code7 - lstTskAccNotCom = ' + lstTskAccNotCom);
        system.debug('Code8 - lstTskOppNotCom = ' + lstTskOppNotCom);
        
        //Get the AccountId of the Opprtunities in lstTskOpp
        if (lstTskOpp.size()>0) lstOppAcc = [select Id, AccountId from Opportunity where id =:lstTskOpp];
        system.debug('Code9 - lstOppAcc = ' + lstOppAcc);
        
        //Get the AccountId of the Opprtunities in lstTskOppNotCom
        if (lstTskOppNotCom.size()>0) lstOppAccNotCom = [select Id, AccountId from Opportunity where id =:lstTskOppNotCom];
        system.debug('Code10 - lstOppAccNotCom = ' + lstOppAccNotCom);

        //Traverse through the lstOppAcc and add the accountId to the lstTskAcc and add opp & acc id to the mapOppAcc
        for (Opportunity opp1: lstOppAcc)
        {
            lstTskAcc.Add(opp1.AccountId);
            if(!mapOppAcc.containskey(opp1.id)) mapOppAcc.put(opp1.id, opp1.AccountId);
        }
        
        //Traverse through the lstOppAcc and add the accountId to the lstTskAcc and add opp & acc id to the mapOppAccNotCom
        for (Opportunity opp2: lstOppAccNotCom)
        {
            lstTskAccNotCom.Add(opp2.AccountId);
            if(!mapOppAccNotCom.containskey(opp2.id)) mapOppAccNotCom.put(opp2.id, opp2.AccountId);
        }
        
        system.debug('Code11 - lstTskAcc = ' + lstTskAcc);
        system.debug('Code12 - lstTskAccNotCom = ' + lstTskAccNotCom);
        system.debug('Code13 - mapOppAcc = ' + mapOppAcc);
        system.debug('Code14 - mapOppAccNotCom = ' + mapOppAccNotCom);
        
        //Get the value of Last_Sales_Interaction__c & Last_Face_to_Face_Activity_Date__c for accounts in lstTskAcc
        if (lstTskAcc.size()>0) lstAccount = [select Id, Last_Sales_Interaction__c, Last_Face_to_Face_Activity_Date__c from Account where id =:lstTskAcc];
        system.debug('Code15 - lstAccount = ' + lstAccount);
        
        //Get the value of Last_Sales_Interaction__c & Last_Face_to_Face_Activity_Date__c for accounts in lstTskAcc
        if (lstTskAccNotCom.size()>0) 
        {
            lstAccountNotCom = [select Id, Last_Sales_Interaction__c, Last_Face_to_Face_Activity_Date__c from Account where id =:lstTskAccNotCom];
            system.debug('Code16.1 - lstAccountNotCom = ' + lstAccountNotCom);
            
            lstAccComEvents = [Select Id, AccountId, WhatId, WhoId, Type, ActivityDate, StartDateTime, EndDateTime 
                              from Event where AccountId in :lstTskAccNotCom and Recordtypeid=:eventRecordTypeId and
                              Owner.ProfileId in :mapsalesProfiles.keyset() and ActivityDate <= Today];
            system.debug('Code16.2 - lstAccComEvents = ' + lstAccComEvents);

            lstAccComTasks =  [Select Id, AccountId, WhatId, WhoId, Type, Status, ActivityDate from Task 
                              where Recordtypeid=:taskRecordTypeId and Status = 'Completed'  
                              and Owner.ProfileId in :mapsalesProfiles.keyset() and AccountId in :lstTskAccNotCom];
            system.debug('Code16.3 - lstAccComTasks = ' + lstAccComTasks);
            
        }
        
        if (lstAccComTasks.size() > 0)
        {
            system.debug('Code17');
            for (Task t: lstAccComTasks)
            {               
                system.debug('Code18');
                date taskDueDate = date.valueof(t.ActivityDate);
                //if((t.Type == 'Cold Call Face to Face') || (t.type == 'Deliver Proposal') || (t.type == 'Face to Face') || (t.type == 'Face to Face with Decision Maker') || (t.type == 'Get Signed Deal'))
                if(t.Type != null && LABEL.Activity_Type.Contains(t.Type))
                {
                    system.debug('Code19');
                    if(!mapAccLstComActDtF2F.containskey(t.AccountId)) 
                    {
                        system.debug('Code20.1');
                        mapAccLstComActDtF2F.put(t.AccountId, taskDueDate);
                    }
                    else
                    {
                        system.debug('Code20.2');
                        if (t.ActivityDate > mapAccLstComActDtF2F.get(t.AccountId)) 
                        {
                            system.debug('Code20.3');
                            mapAccLstComActDtF2F.remove(t.AccountId);
                            mapAccLstComActDtF2F.put(t.AccountId, taskDueDate);
                        }
                    }
                }
                else
                {
                    system.debug('Code21');
                    if(!mapAccLstComActDt.containskey(t.AccountId)) 
                    {
                        system.debug('Code22.1');
                        mapAccLstComActDt.put(t.AccountId, taskDueDate);
                    }
                    else
                    {
                        system.debug('Code22.2');
                        if (t.ActivityDate > mapAccLstComActDt.get(t.AccountId)) 
                        {
                            system.debug('Code22.3');
                            mapAccLstComActDt.remove(t.AccountId);
                            mapAccLstComActDt.put(t.AccountId, taskDueDate);
                        }
                    }
                }
            }
        }
        
        system.debug('Code23.1 - mapAccLstComActDt = ' + mapAccLstComActDt);
        system.debug('Code23.2 - mapAccLstComActDtF2F = ' + mapAccLstComActDtF2F);
        
        if (lstAccComEvents.size() > 0)
        {
            system.debug('Code24');
            for (Event e: lstAccComEvents)
            {
                system.debug('Code25');
                date eventDueDate = date.valueof(e.ActivityDate);
                //if((e2.Type == 'Cold Call Face to Face') || (e2.type == 'Deliver Proposal') || (e2.type == 'Face to Face') || (e2.type == 'Face to Face with Decision Maker') || (e2.type == 'Get Signed Deal'))
                if(e.Type != null && LABEL.Activity_Type.Contains(e.Type))
                {
                    system.debug('Code26');
                    if(!mapAccLstComActDtF2F.containskey(e.AccountId)) 
                    {
                        system.debug('Code27');
                        mapAccLstComActDtF2F.put(e.AccountId, eventDueDate);
                    }
                    else
                    {
                        system.debug('Code28');
                        if (e.ActivityDate > mapAccLstComActDtF2F.get(e.AccountId)) 
                        {
                            system.debug('Code29');
                            mapAccLstComActDtF2F.remove(e.AccountId);
                            mapAccLstComActDtF2F.put(e.AccountId, eventDueDate);
                        }
                    }
                }
                else
                {
                    system.debug('Code30');
                    if(!mapAccLstComActDt.containskey(e.AccountId)) 
                    {
                        system.debug('Code31');
                        mapAccLstComActDt.put(e.AccountId, eventDueDate);
                    }
                    else
                    {
                        system.debug('Code32');
                        if (e.ActivityDate > mapAccLstComActDt.get(e.AccountId)) 
                        {
                            system.debug('Code33');
                            mapAccLstComActDt.remove(e.AccountId);
                            mapAccLstComActDt.put(e.AccountId, eventDueDate);
                        }
                    }
                }   
            }
        }
        
        system.debug('Code34.1 - mapAccLstComActDt = ' + mapAccLstComActDt);
        system.debug('Code34.2 - mapAccLstComActDtF2F = ' + mapAccLstComActDtF2F);
                        
        //Traverse again through the list of task
        for (Task tsk2: ryderTasks)
        {                   
            string relatedToId = (string) tsk2.WhatId;
            string contactId = (string) tsk2.WhoId;
            string taskType = (string) tsk2.Type;
            string taskStatus = (string) tsk2.Status;
            datetime taskDueDateTime = tsk2.ActivityDate;
            date taskDueDate = date.valueof(tsk2.ActivityDate);

            updLSI = false;
            updLF2FAD = false;
            updLSIF2F = false;
            
            system.debug('Code 35 - taskDueDate = ' + taskDueDate);
            
            if (taskStatus == 'Completed')
            {
                system.debug('Code 36');
                if (relatedToId != null) 
                {  
                    system.debug('Code 37');
                    //If object specified in "Related To" is Account
                    if (relatedToId.substring(0,3)=='001') 
                    {
                        system.debug('Code 38');
                        //Traverse through the list of Accounts to check if WhatId = AccountId
                        for (Account acc1: lstAccount)
                        {
                            system.debug('Code 39');
                            if (acc1.id == relatedToId)
                            {
                                //Check if the task is of type "Face to Face"
                                if(mapTaskType.get(tsk2.id) != null)
                                {
                                    system.debug('Code 40 - acc1.Last_Sales_Interaction__c = ' + acc1.Last_Sales_Interaction__c + ', acc1.Last_Face_to_Face_Activity_Date__c = ' + acc1.Last_Face_to_Face_Activity_Date__c + ', taskDueDate = ' + taskDueDate);
                                    if((acc1.Last_Sales_Interaction__c == null) || (acc1.Last_Sales_Interaction__c < taskDueDate))
                                    {
                                        system.debug('Code 41');
                                        updLSI = true;
                                    }
                                    if((acc1.Last_Face_to_Face_Activity_Date__c == null) || (acc1.Last_Face_to_Face_Activity_Date__c < taskDueDate)) 
                                    {
                                        system.debug('Code 42');
                                        updLF2FAD = true;
                                    }
                                }
                                //If the task is not of type "Face to Face"
                                else
                                {
                                    system.debug('Code 43 - acc1.Last_Sales_Interaction__c = ' + acc1.Last_Sales_Interaction__c + ', taskDueDate = ' + taskDueDate);
                                    if((acc1.Last_Sales_Interaction__c == null) || (acc1.Last_Sales_Interaction__c < taskDueDate))
                                    {
                                        system.debug('Code 44');
                                        updLSI = true;
                                    }
                                }
                            }
                        }
                        if(updLSI == true && updLF2FAD == true)
                        {
                            system.debug('Code 45.1 - mapAccToUpdate = ' + mapAccToUpdate);
                            if(!mapAccToUpdate.containskey(tsk2.Whatid))
                            {
                                mapAccToUpdate.put(tsk2.Whatid,new Account(id=tsk2.Whatid,Last_Sales_Interaction__c=taskDueDate,Last_Face_to_Face_Activity_Date__c=taskDueDate));
                                system.debug('Code 45.2 - mapAccToUpdate = ' + mapAccToUpdate);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdate.get(tsk2.Whatid);
                                if(accToCompare.Last_Sales_Interaction__c > taskDueDate)
                                {
                                    dtLSI = accToCompare.Last_Sales_Interaction__c;
                                }
                                else
                                {
                                    dtLSI = taskDueDate;
                                }
                                if(accToCompare.Last_Face_to_Face_Activity_Date__c > taskDueDate)
                                {
                                    dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                }
                                else
                                {
                                    dtF2F = taskDueDate;
                                }
                                system.debug('Code 45.3 - mapAccToUpdate = ' + mapAccToUpdate);
                                mapAccToUpdate.remove(tsk2.Whatid);
                                mapAccToUpdate.put(tsk2.Whatid,new Account(id=tsk2.Whatid,Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 45.4 - mapAccToUpdate = ' + mapAccToUpdate);
                            }
                        }
                        else if(updLSI == true && updLF2FAD == false)
                        {
                            system.debug('Code 46.1 - mapAccToUpdate = ' + mapAccToUpdate);
                            if(!mapAccToUpdate.containskey(tsk2.Whatid))
                            {
                                mapAccToUpdate.put(tsk2.Whatid,new Account(id=tsk2.Whatid,Last_Sales_Interaction__c=taskDueDate));
                                system.debug('Code 46.2 - mapAccToUpdate = ' + mapAccToUpdate);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdate.get(tsk2.Whatid);
                                if(accToCompare.Last_Sales_Interaction__c > taskDueDate)
                                {
                                    dtLSI = accToCompare.Last_Sales_Interaction__c;
                                }
                                else
                                {
                                    dtLSI = taskDueDate;
                                }
                                dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                
                                system.debug('Code 46.3 - mapAccToUpdate = ' + mapAccToUpdate);
                                mapAccToUpdate.remove(tsk2.Whatid);
                                mapAccToUpdate.put(tsk2.Whatid,new Account(id=tsk2.Whatid,Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 46.4 - mapAccToUpdate = ' + mapAccToUpdate);
                            }                     
                        }
                        else if(updLSI == false && updLF2FAD == true)
                        {
                            system.debug('Code 47.1 - mapAccToUpdate = ' + mapAccToUpdate);
                            if(!mapAccToUpdate.containskey(tsk2.Whatid))
                            {
                                mapAccToUpdate.put(tsk2.Whatid,new Account(id=tsk2.Whatid,Last_Face_to_Face_Activity_Date__c=taskDueDate));
                                system.debug('Code 47.2 - mapAccToUpdate = ' + mapAccToUpdate);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdate.get(tsk2.Whatid);
                                dtLSI = accToCompare.Last_Sales_Interaction__c;
                                if(accToCompare.Last_Face_to_Face_Activity_Date__c > taskDueDate)
                                {
                                    dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                }
                                else
                                {
                                    dtF2F = taskDueDate;
                                }
                                system.debug('Code 47.3 - mapAccToUpdate = ' + mapAccToUpdate);
                                mapAccToUpdate.remove(tsk2.Whatid);
                                mapAccToUpdate.put(tsk2.Whatid,new Account(id=tsk2.Whatid,Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 47.4 - mapAccToUpdate = ' + mapAccToUpdate);
                            }              
                        }
                        system.debug('Code 48.1 - updLSI = ' + updLSI + ' updLF2FAD = ' + updLF2FAD);
                        updLSI = false;
                        updLF2FAD = false;
                        system.debug('Code 48.2 - mapAccToUpdate = ' + mapAccToUpdate);
                    }
                    //If object specified in "Related To" is Opportunity
                    else if (relatedToId.substring(0,3)=='006')
                    {
                        system.debug('Code 49');
                        //Traverse through the list of Accounts to check if WhatId = AccountId
                        for (Account acc2: lstAccount)
                        {
                            system.debug('Code 50');
                            if ((mapOppAcc.containsKey(relatedToId)) && (acc2.id == mapOppAcc.get(relatedToId)))
                            {
                                system.debug('Code 51');
                                //Check if the task is of type "Face to Face"
                                if(mapTaskType.get(tsk2.id) != null)
                                {
                                    system.debug('Code 52 - acc2.Last_Sales_Interaction__c = ' + acc2.Last_Sales_Interaction__c + ', acc2.Last_Face_to_Face_Activity_Date__c = ' + acc2.Last_Face_to_Face_Activity_Date__c + ', taskDueDate = ' + taskDueDate);
                                    if((acc2.Last_Sales_Interaction__c == null) || (acc2.Last_Sales_Interaction__c < taskDueDate))
                                    {
                                        system.debug('Code 53');
                                        updLSI = true;
                                    }
                                    if((acc2.Last_Face_to_Face_Activity_Date__c == null) || (acc2.Last_Face_to_Face_Activity_Date__c < taskDueDate)) 
                                    {
                                        system.debug('Code 54');
                                        updLF2FAD = true;
                                    }
                                }
                                //If the task is not of type "Face to Face"
                                else
                                {
                                    system.debug('Code 55 - acc2.Last_Sales_Interaction__c = ' + acc2.Last_Sales_Interaction__c + ', taskDueDate = ' + taskDueDate);
                                    if((acc2.Last_Sales_Interaction__c == null) || (acc2.Last_Sales_Interaction__c < taskDueDate))
                                    {
                                        system.debug('Code 56');
                                        updLSI = true;
                                    }
                                }
                            }
                        }
                        system.debug('Code 57');
                        if(updLSI == true && updLF2FAD == true)
                        {
                            system.debug('Code 58.1 - mapAccToUpdate = ' + mapAccToUpdate);
                            if(!mapAccToUpdate.containskey(mapOppAcc.get(relatedToId)))
                            {
                                mapAccToUpdate.put(mapOppAcc.get(relatedToId),new Account(id=mapOppAcc.get(relatedToId),Last_Sales_Interaction__c=taskDueDate,Last_Face_to_Face_Activity_Date__c=taskDueDate));
                                system.debug('Code 58.2 - mapAccToUpdate = ' + mapAccToUpdate);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdate.get(mapOppAcc.get(relatedToId));
                                if(accToCompare.Last_Sales_Interaction__c > taskDueDate)
                                {
                                    dtLSI = accToCompare.Last_Sales_Interaction__c;
                                }
                                else
                                {
                                    dtLSI = taskDueDate;
                                }
                                if(accToCompare.Last_Face_to_Face_Activity_Date__c > taskDueDate)
                                {
                                    dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                }
                                else
                                {
                                    dtF2F = taskDueDate;
                                }
                                system.debug('Code 58.3 - mapAccToUpdate = ' + mapAccToUpdate);
                                mapAccToUpdate.remove(mapOppAcc.get(relatedToId));
                                mapAccToUpdate.put(mapOppAcc.get(relatedToId),new Account(id=mapOppAcc.get(relatedToId),Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 58.3 - mapAccToUpdate = ' + mapAccToUpdate);
                            }
                        }
                        else if(updLSI == true && updLF2FAD == false)
                        {
                            system.debug('Code 59.1 - mapAccToUpdate = ' + mapAccToUpdate);
                            if(!mapAccToUpdate.containskey(mapOppAcc.get(relatedToId)))
                            {
                                mapAccToUpdate.put(mapOppAcc.get(relatedToId),new Account(id=mapOppAcc.get(relatedToId),Last_Sales_Interaction__c=taskDueDate));
                                system.debug('Code 59.2 - mapAccToUpdate = ' + mapAccToUpdate);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdate.get(mapOppAcc.get(relatedToId));
                                if(accToCompare.Last_Sales_Interaction__c > taskDueDate)
                                {
                                    dtLSI = accToCompare.Last_Sales_Interaction__c;
                                }
                                else
                                {
                                    dtLSI = taskDueDate;
                                }
                                dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                system.debug('Code 59.3 - mapAccToUpdate = ' + mapAccToUpdate);
                                mapAccToUpdate.remove(mapOppAcc.get(relatedToId));
                                mapAccToUpdate.put(mapOppAcc.get(relatedToId),new Account(id=mapOppAcc.get(relatedToId),Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 59.4 - mapAccToUpdate = ' + mapAccToUpdate);
                            }             
                        }
                        else if(updLSI == false && updLF2FAD == true)
                        {
                            system.debug('Code 60.1 - mapAccToUpdate = ' + mapAccToUpdate);
                            if(!mapAccToUpdate.containskey(mapOppAcc.get(relatedToId)))
                            {
                                mapAccToUpdate.put(mapOppAcc.get(relatedToId),new Account(id=mapOppAcc.get(relatedToId),Last_Face_to_Face_Activity_Date__c=taskDueDate));
                                system.debug('Code 60.2 - mapAccToUpdate = ' + mapAccToUpdate);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdate.get(mapOppAcc.get(relatedToId));
                                dtLSI = accToCompare.Last_Sales_Interaction__c;
                                if(accToCompare.Last_Face_to_Face_Activity_Date__c > taskDueDate)
                                {
                                    dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                }
                                else
                                {
                                    dtF2F = taskDueDate;
                                }
                                
                                system.debug('Code 60.3 - mapAccToUpdate = ' + mapAccToUpdate);
                                mapAccToUpdate.remove(mapOppAcc.get(relatedToId));
                                mapAccToUpdate.put(mapOppAcc.get(relatedToId),new Account(id=mapOppAcc.get(relatedToId),Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 60.4 - mapAccToUpdate = ' + mapAccToUpdate);
                            } 
                        }
                        system.debug('Code 61.1 - updLSI = ' + updLSI + ' updLF2FAD = ' + updLF2FAD);
                        updLSI = false;
                        updLF2FAD = false;
                        system.debug('Code 61.2 - mapAccToUpdate = ' + mapAccToUpdate);
                    }
                }
            }
            else if (taskStatus != 'Completed')
            {
                system.debug('Code 62 - updLSIF2F = ' + updLSIF2F);
                if (relatedToId != null) 
                {  
                    system.debug('Code 63');    
                    //If object specified in "Related To" is Account
                    if (relatedToId.substring(0,3)=='001') 
                    {
                        system.debug('Code 64');
                        //Traverse through the list of Accounts to check if WhatId = AccountId
                        for (Account acc3: lstAccountNotCom)
                        {
                            system.debug('Code 65');
                            if (acc3.id == relatedToId)
                            {
                                system.debug('Code 66.1 - acc3.Last_Face_to_Face_Activity_Date__c = ' + acc3.Last_Face_to_Face_Activity_Date__c + ', mapAccLstComActDtF2F.get(acc3.id) = ' + mapAccLstComActDtF2F.get(acc3.id));
                                system.debug('Code 66.2 - acc3.Last_Sales_Interaction__c = ' + acc3.Last_Sales_Interaction__c + ', mapAccLstComActDt.get(acc3.id) = ' + mapAccLstComActDt.get(acc3.id));
                                
                                if((mapAccLstComActDtF2F.get(acc3.id) == null) || (acc3.Last_Face_to_Face_Activity_Date__c > mapAccLstComActDtF2F.get(acc3.id)))
                                {
                                    system.debug('Code 67.1 - mapAccLstComActDtF2F.get(acc3.id) = ' + mapAccLstComActDtF2F.get(acc3.id));
                                    system.debug('Code 67.2 - acc3.Last_Face_to_Face_Activity_Date__c = ' + acc3.Last_Face_to_Face_Activity_Date__c);
                                    updLF2FAD = true;
                                }
                                if((mapAccLstComActDt.get(acc3.id) == null) || (acc3.Last_Sales_Interaction__c > mapAccLstComActDt.get(acc3.id)))
                                {
                                    system.debug('Code 68.1 - mapAccLstComActDt.get(acc3.id) = ' + mapAccLstComActDt.get(acc3.id));
                                    system.debug('Code 68.2 - acc3.Last_Sales_Interaction__c = ' + acc3.Last_Sales_Interaction__c);
                                    updLSI = true;
                                }
                                //if(((mapAccLstComActDtF2F.get(acc3.id) == null) || (acc3.Last_Sales_Interaction__c > mapAccLstComActDtF2F.get(acc3.id))) && (mapAccLstComActDt.get(acc3.id) == null))
                                if(((mapAccLstComActDtF2F.get(acc3.id) == null) || (acc3.Last_Sales_Interaction__c > mapAccLstComActDtF2F.get(acc3.id))) && (mapAccLstComActDt.get(acc3.id) == null) || ((acc3.Last_Sales_Interaction__c >= mapAccLstComActDtF2F.get(acc3.id)) && (mapAccLstComActDtF2F.get(acc3.id) >= mapAccLstComActDt.get(acc3.id))))                                 
                                {
                                    system.debug('Code 69.1 - mapAccLstComActDtF2F.get(acc3.id) = ' + mapAccLstComActDtF2F.get(acc3.id));
                                    system.debug('Code 69.2 - acc3.Last_Sales_Interaction__c = ' + acc3.Last_Sales_Interaction__c);
                                    updLSIF2F = true;
                                }
                                if (updLSI == true && updLSIF2F == true)
                                {
                                    system.debug('Code 70');
                                    If(mapAccLstComActDtF2F.get(acc3.id) == null && mapAccLstComActDt.get(acc3.id) == null)
                                    {
                                        system.debug('Code 70.1');
                                        updLSIF2F = false;
                                    }
                                    else If(mapAccLstComActDtF2F.get(acc3.id) == null && mapAccLstComActDt.get(acc3.id) != null)
                                    {
                                        system.debug('Code 70.2');
                                        updLSIF2F = false;
                                    } 
                                    else If(mapAccLstComActDtF2F.get(acc3.id) != null && mapAccLstComActDt.get(acc3.id) == null)
                                    {
                                        system.debug('Code 70.3');
                                        updLSI = false;
                                    }
                                    else if(mapAccLstComActDtF2F.get(acc3.id) >= mapAccLstComActDt.get(acc3.id))
                                    {
                                        system.debug('Code 70.4');
                                        updLSI = false;
                                    }
                                    else if(mapAccLstComActDtF2F.get(acc3.id) < mapAccLstComActDt.get(acc3.id))
                                    {
                                        system.debug('Code 70.5');
                                        updLSIF2F = false;
                                    }
                                }
                            }
                        }
                        
                        system.debug('Code 71 - updLSI = ' + updLSI + ', updLF2FAD = ' + updLF2FAD + ', updLSIF2F = ' + updLSIF2F);
                        
                        if(updLF2FAD == true && updLSIF2F == true)
                        {
                            system.debug('Code 72.1 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            if(!mapAccToUpdateNotCom.containskey(tsk2.WhatId))
                            {
                                mapAccToUpdateNotCom.put(tsk2.WhatId,new Account(id=tsk2.WhatId,Last_Sales_Interaction__c=mapAccLstComActDtF2F.get(tsk2.WhatId),Last_Face_to_Face_Activity_Date__c=mapAccLstComActDtF2F.get(tsk2.WhatId)));
                                system.debug('Code 72.2 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdateNotCom.get(tsk2.WhatId);
                                if(accToCompare.Last_Sales_Interaction__c > mapAccLstComActDtF2F.get(tsk2.WhatId))
                                {
                                    dtLSI = accToCompare.Last_Sales_Interaction__c;
                                }
                                else
                                {
                                    dtLSI = mapAccLstComActDtF2F.get(tsk2.WhatId);
                                }
                                if(accToCompare.Last_Face_to_Face_Activity_Date__c > mapAccLstComActDtF2F.get(tsk2.WhatId))
                                {
                                    dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                }
                                else
                                {
                                    dtF2F = mapAccLstComActDtF2F.get(tsk2.WhatId);
                                }
                                system.debug('Code 72.3 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                                mapAccToUpdateNotCom.remove(tsk2.WhatId);
                                mapAccToUpdateNotCom.put(tsk2.WhatId,new Account(id=tsk2.WhatId,Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 72.4 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }                            
                        }
                        else if(updLF2FAD == true && updLSI == true)
                        {
                            system.debug('Code 72.5 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            if(!mapAccToUpdateNotCom.containskey(tsk2.WhatId))
                            {
                                mapAccToUpdateNotCom.put(tsk2.WhatId,new Account(id=tsk2.WhatId,Last_Sales_Interaction__c=mapAccLstComActDt.get(tsk2.WhatId),Last_Face_to_Face_Activity_Date__c=mapAccLstComActDtF2F.get(tsk2.WhatId)));
                                system.debug('Code 72.6 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdateNotCom.get(tsk2.WhatId);
                                if(accToCompare.Last_Sales_Interaction__c > mapAccLstComActDt.get(tsk2.WhatId))
                                {
                                    dtLSI = accToCompare.Last_Sales_Interaction__c;
                                }
                                else
                                {
                                    dtLSI = mapAccLstComActDt.get(tsk2.WhatId);
                                }
                                if(accToCompare.Last_Face_to_Face_Activity_Date__c > mapAccLstComActDtF2F.get(tsk2.WhatId))
                                {
                                    dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                }
                                else
                                {
                                    dtF2F = mapAccLstComActDtF2F.get(tsk2.WhatId);
                                }
                                system.debug('Code 72.7 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                                mapAccToUpdateNotCom.remove(tsk2.WhatId);
                                mapAccToUpdateNotCom.put(tsk2.WhatId,new Account(id=tsk2.WhatId,Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 72.8 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                        }
                        else if(updLF2FAD == false && updLSIF2F == true)
                        {
                            system.debug('Code 72.9 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            if(!mapAccToUpdateNotCom.containskey(tsk2.WhatId))
                            {
                                mapAccToUpdateNotCom.put(tsk2.WhatId,new Account(id=tsk2.WhatId,Last_Sales_Interaction__c=mapAccLstComActDtF2F.get(tsk2.WhatId)));
                                system.debug('Code 72.10 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdateNotCom.get(tsk2.WhatId);
                                if(accToCompare.Last_Sales_Interaction__c > mapAccLstComActDtF2F.get(tsk2.WhatId))
                                {
                                    dtLSI = accToCompare.Last_Sales_Interaction__c;
                                }
                                else
                                {
                                    dtLSI = mapAccLstComActDtF2F.get(tsk2.WhatId);
                                }
                                dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                
                                system.debug('Code 72.11 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                                mapAccToUpdateNotCom.remove(tsk2.WhatId);
                                mapAccToUpdateNotCom.put(tsk2.WhatId,new Account(id=tsk2.WhatId,Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 72.12 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                        }
                        else if(updLF2FAD == false && updLSI == true)
                        {
                            system.debug('Code 72.13 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            if(!mapAccToUpdateNotCom.containskey(tsk2.WhatId))
                            {
                                mapAccToUpdateNotCom.put(tsk2.WhatId,new Account(id=tsk2.WhatId,Last_Sales_Interaction__c=mapAccLstComActDt.get(tsk2.WhatId)));
                                system.debug('Code 72.14 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdateNotCom.get(tsk2.WhatId);
                                if(accToCompare.Last_Sales_Interaction__c > mapAccLstComActDt.get(tsk2.WhatId))
                                {
                                    dtLSI = accToCompare.Last_Sales_Interaction__c;
                                }
                                else
                                {
                                    dtLSI = mapAccLstComActDt.get(tsk2.WhatId);
                                }
                                dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                
                                system.debug('Code 72.15 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                                mapAccToUpdateNotCom.remove(tsk2.WhatId);
                                mapAccToUpdateNotCom.put(tsk2.WhatId,new Account(id=tsk2.WhatId,Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 72.16 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                        }
                        else if(updLF2FAD == true && updLSI == false && updLSIF2F == false)
                        {
                            system.debug('Code 72.17 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            if(!mapAccToUpdateNotCom.containskey(tsk2.WhatId))
                            {
                                mapAccToUpdateNotCom.put(tsk2.WhatId,new Account(id=tsk2.WhatId,Last_Face_to_Face_Activity_Date__c=mapAccLstComActDtF2F.get(tsk2.WhatId)));
                                system.debug('Code 72.18 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdateNotCom.get(tsk2.WhatId);
                                dtLSI = accToCompare.Last_Sales_Interaction__c;
                                if(accToCompare.Last_Face_to_Face_Activity_Date__c > mapAccLstComActDtF2F.get(tsk2.WhatId))
                                {
                                    dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                }
                                else
                                {
                                    dtF2F = mapAccLstComActDt.get(tsk2.WhatId);
                                }
                                system.debug('Code 72.19 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                                mapAccToUpdateNotCom.remove(tsk2.WhatId);
                                mapAccToUpdateNotCom.put(tsk2.WhatId,new Account(id=tsk2.WhatId,Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 72.20 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                        }                         
                        
                        updLSI = false;
                        updLF2FAD = false;
                        updLSIF2F = false;
                    }
                    //If object specified in "Related To" is Opportunity
                    else if (relatedToId.substring(0,3)=='006')
                    {
                        system.debug('Code 74');
                        //Traverse through the list of Accounts to check if WhatId = AccountId
                        for (Account acc4: lstAccountNotCom)
                        {
                            system.debug('Code 75');
                            if ((mapOppAccNotCom.containsKey(relatedToId)) && (acc4.id == mapOppAccNotCom.get(relatedToId)))
                            {
                                system.debug('Code 76.1 - acc4.Last_Face_to_Face_Activity_Date__c = ' + acc4.Last_Face_to_Face_Activity_Date__c);
                                system.debug('Code 76.2 - acc4.Last_Sales_Interaction__c = ' + acc4.Last_Sales_Interaction__c);
                                system.debug('Code 76.3 - mapAccLstComActDt.get(relatedToId) = ' + mapAccLstComActDt.get(relatedToId));
                                system.debug('Code 76.4 - mapAccLstComActDtF2F.get(relatedToId) = ' + mapAccLstComActDtF2F.get(relatedToId));
                                system.debug('Code 76.5 - mapAccLstComActDt.get(mapOppAccNotCom.get(relatedToId)) = ' + mapAccLstComActDt.get(mapOppAccNotCom.get(relatedToId)));
                                system.debug('Code 76.6 - mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId)) = ' + mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId)));
                                
                                if((mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId)) == null) || (acc4.Last_Face_to_Face_Activity_Date__c > mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId))))
                                {
                                    system.debug('Code 77');
                                    updLF2FAD = true;
                                }
                                
                                if((mapAccLstComActDt.get(mapOppAccNotCom.get(relatedToId)) == null) || (acc4.Last_Sales_Interaction__c > mapAccLstComActDt.get(mapOppAccNotCom.get(relatedToId))))
                                {
                                    system.debug('Code 78');
                                    updLSI = true;
                                }
                                //if(((mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId)) == null) || (acc4.Last_Sales_Interaction__c > mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId)))) && (mapAccLstComActDt.get(acc4.id) == null))
                                if(((mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId)) == null) || (acc4.Last_Sales_Interaction__c > mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId)))) && (mapAccLstComActDt.get(acc4.id) == null) || ((acc4.Last_Sales_Interaction__c >= mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId))) && (mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId)) >= mapAccLstComActDt.get(mapOppAccNotCom.get(relatedToId)))))                                                               
                                {
                                    system.debug('Code 79');
                                    updLSIF2F = true;
                                }
                                
                                if (updLSI == true && updLSIF2F == true)
                                {
                                    system.debug('Code 80');
                                    If(mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId)) == null && mapAccLstComActDt.get(mapOppAccNotCom.get(relatedToId)) == null)
                                    {
                                        system.debug('Code 80.1');
                                        updLSIF2F = false;
                                    }
                                    else If(mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId)) == null && mapAccLstComActDt.get(mapOppAccNotCom.get(relatedToId)) != null)
                                    {
                                        system.debug('Code 80.2');
                                        updLSIF2F = false;
                                    } 
                                    else If(mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId)) != null && mapAccLstComActDt.get(mapOppAccNotCom.get(relatedToId)) == null)
                                    {
                                        system.debug('Code 80.3');
                                        updLSI = false;
                                    }
                                    else if(mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId)) >= mapAccLstComActDt.get(mapOppAccNotCom.get(relatedToId)))
                                    {
                                        system.debug('Code 80.4');
                                        updLSI = false;
                                    }
                                    else if(mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId)) < mapAccLstComActDt.get(mapOppAccNotCom.get(relatedToId)))
                                    {
                                        system.debug('Code 80.5');
                                        updLSIF2F = false;
                                    }
                                }
                            }
                        }
                        
                        system.debug('Code 81 - updLSI = ' + updLSI + ', updLF2FAD = ' + updLF2FAD + ', updLSIF2F = ' + updLSIF2F);
                        
                        if(updLF2FAD == true && updLSIF2F == true)
                        {
                            system.debug('Code 81.1 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            if(!mapAccToUpdateNotCom.containskey(mapOppAccNotCom.get(relatedToId)))
                            {
                                mapAccToUpdateNotCom.put(mapOppAccNotCom.get(relatedToId),new Account(id=mapOppAccNotCom.get(relatedToId),Last_Sales_Interaction__c=mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId)),Last_Face_to_Face_Activity_Date__c=mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId))));
                                system.debug('Code 81.2 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdateNotCom.get(mapOppAccNotCom.get(relatedToId));
                                if(accToCompare.Last_Sales_Interaction__c > mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId)))
                                {
                                    dtLSI = accToCompare.Last_Sales_Interaction__c;
                                }
                                else
                                {
                                    dtLSI = mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId));
                                }
                                if(accToCompare.Last_Face_to_Face_Activity_Date__c > mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId)))
                                {
                                    dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                }
                                else
                                {
                                    dtF2F = mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId));
                                }
                                system.debug('Code 81.3 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                                mapAccToUpdateNotCom.remove(mapOppAccNotCom.get(relatedToId));
                                mapAccToUpdateNotCom.put(mapOppAccNotCom.get(relatedToId),new Account(id=mapOppAccNotCom.get(relatedToId),Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 81.4 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }   
                        }
                        else if(updLF2FAD == true && updLSI == true)
                        {
                            system.debug('Code 81.5 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            if(!mapAccToUpdateNotCom.containskey(mapOppAccNotCom.get(relatedToId)))
                            {
                                mapAccToUpdateNotCom.put(mapOppAccNotCom.get(relatedToId),new Account(id=mapOppAccNotCom.get(relatedToId),Last_Sales_Interaction__c=mapAccLstComActDt.get(mapOppAccNotCom.get(relatedToId)),Last_Face_to_Face_Activity_Date__c=mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId))));
                                system.debug('Code 81.6 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdateNotCom.get(mapOppAccNotCom.get(relatedToId));
                                if(accToCompare.Last_Sales_Interaction__c > mapAccLstComActDt.get(mapOppAccNotCom.get(relatedToId)))
                                {
                                    dtLSI = accToCompare.Last_Sales_Interaction__c;
                                }
                                else
                                {
                                    dtLSI = mapAccLstComActDt.get(mapOppAccNotCom.get(relatedToId));
                                }
                                if(accToCompare.Last_Face_to_Face_Activity_Date__c > mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId)))
                                {
                                    dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                }
                                else
                                {
                                    dtF2F = mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId));
                                }
                                system.debug('Code 81.7 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                                mapAccToUpdateNotCom.remove(mapOppAccNotCom.get(relatedToId));
                                mapAccToUpdateNotCom.put(mapOppAccNotCom.get(relatedToId),new Account(id=mapOppAccNotCom.get(relatedToId),Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 81.8 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            } 
                        }
                        else if(updLF2FAD == false && updLSIF2F == true)
                        {
                            system.debug('Code 81.9 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);                        
                            if(!mapAccToUpdateNotCom.containskey(mapOppAccNotCom.get(relatedToId)))
                            {
                                mapAccToUpdateNotCom.put(mapOppAccNotCom.get(relatedToId),new Account(id=mapOppAccNotCom.get(relatedToId),Last_Sales_Interaction__c=mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId))));
                                system.debug('Code 81.10 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdateNotCom.get(mapOppAccNotCom.get(relatedToId));
                                if(accToCompare.Last_Sales_Interaction__c > mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId)))
                                {
                                    dtLSI = accToCompare.Last_Sales_Interaction__c;
                                }
                                else
                                {
                                    dtLSI = mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId));
                                }
                                dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                
                                system.debug('Code 81.11 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                                mapAccToUpdateNotCom.remove(mapOppAccNotCom.get(relatedToId));
                                mapAccToUpdateNotCom.put(mapOppAccNotCom.get(relatedToId),new Account(id=mapOppAccNotCom.get(relatedToId),Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 81.12 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            } 
                        }
                        else if(updLF2FAD == false && updLSI == true)
                        {
                            system.debug('Code 81.13 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);                        
                            if(!mapAccToUpdateNotCom.containskey(mapOppAccNotCom.get(relatedToId)))
                            {
                                mapAccToUpdateNotCom.put(mapOppAccNotCom.get(relatedToId),new Account(id=mapOppAccNotCom.get(relatedToId),Last_Sales_Interaction__c=mapAccLstComActDt.get(mapOppAccNotCom.get(relatedToId))));
                                system.debug('Code 81.4 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdateNotCom.get(mapOppAccNotCom.get(relatedToId));
                                if(accToCompare.Last_Sales_Interaction__c > mapAccLstComActDt.get(mapOppAccNotCom.get(relatedToId)))
                                {
                                    dtLSI = accToCompare.Last_Sales_Interaction__c;
                                }
                                else
                                {
                                    dtLSI = mapAccLstComActDt.get(mapOppAccNotCom.get(relatedToId));
                                }
                                dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                
                                system.debug('Code 81.15 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                                mapAccToUpdateNotCom.remove(mapOppAccNotCom.get(relatedToId));
                                mapAccToUpdateNotCom.put(mapOppAccNotCom.get(relatedToId),new Account(id=mapOppAccNotCom.get(relatedToId),Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 81.16 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            } 
                        }
                        else if(updLF2FAD == true && updLSI == false && updLSIF2F == false)
                        {
                            system.debug('Code 81.17 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            if(!mapAccToUpdateNotCom.containskey(mapOppAccNotCom.get(relatedToId)))
                            {
                                mapAccToUpdateNotCom.put(mapOppAccNotCom.get(relatedToId),new Account(id=mapOppAccNotCom.get(relatedToId),Last_Face_to_Face_Activity_Date__c=mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId))));
                                system.debug('Code 81.18 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdateNotCom.get(mapOppAccNotCom.get(relatedToId));
                                dtLSI = accToCompare.Last_Sales_Interaction__c;
                                if(accToCompare.Last_Face_to_Face_Activity_Date__c > mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId)))
                                {
                                    dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                }
                                else
                                {
                                    dtF2F = mapAccLstComActDtF2F.get(mapOppAccNotCom.get(relatedToId));
                                }
                                system.debug('Code 81.7 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                                mapAccToUpdateNotCom.remove(mapOppAccNotCom.get(relatedToId));
                                mapAccToUpdateNotCom.put(mapOppAccNotCom.get(relatedToId),new Account(id=mapOppAccNotCom.get(relatedToId),Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 81.8 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            } 
                        }             
                        updLSI = false;
                        updLF2FAD = false;
                        updLSIF2F = false;
                    }
                }
            }
        }
        system.debug('Code 83 - mapAccToUpdate.KeySet() = ' + mapAccToUpdate.values());
        if (mapAccToUpdate.size() > 0) update mapAccToUpdate.values(); 
        system.debug('Code 83 - mapAccToUpdate.KeySet() = ' + mapAccToUpdateNotCom.values());
        if (mapAccToUpdateNotCom.size() > 0) update mapAccToUpdateNotCom.values(); 
        system.debug('Code 85');
    }
}