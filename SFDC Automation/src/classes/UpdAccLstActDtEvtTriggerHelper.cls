/*
* 
*   Helper class for the trigger UpdAccLstActDtEvtTriggerHelper that updates the values of Last Sales Interaction field on the Account
*   when an event passes it's due date or is updated to a future date.
*
*   Author                     |Date               |Comment
*   -------------------------|------------------|--------------------------------------------------
*   Saad Wali Jaan    |12.15.2014   |First draft
*
*/

public class UpdAccLstActDtEvtTriggerHelper {

    public static void UpdateAccount(List<Event> lEvent, Map<Id, Event> mapEventOld, Map<Id, Event> mapEventNew) {
    
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
        
        //List of Activity types for which the Face To Face field needs to be updated  
        List<string> lActivityType = new List<string>(LABEL.Activity_Type.split(','));    
        
        system.debug('Code0.3 - lActivityType = ' + lActivityType);   
        
        //Getting the recordTypeId of the 'Ryder Event' and 'Ryder Task'
        eventRecordTypeId = LABEL.Ryder_Event_Record_ID;
        taskRecordTypeId = LABEL.Ryder_Task_Record_ID;
        
        system.debug('Code0.4 - eventRecordTypeId = ' + eventRecordTypeId);
        system.debug('Code0.5 - taskRecordTypeId = ' + taskRecordTypeId);
        
        //Getting a map of all Events which are in the specified list of Sales Profile
        Map<Id,Event> mapEventType=new Map<id,Event>([Select t.Id from Event t where Id in :lEvent and Recordtypeid=:eventRecordTypeId and Type in :lActivityType]);
        
        system.debug('Code0.6 - mapEventType = ' + mapEventType);
        
        //Get the list of all Event which satisfies the following condition
        List<Event> ryderEvents = [Select Id, WhatId, WhoId, Type, ActivityDate, StartDateTime, EndDateTime 
                                  from Event where Id in :lEvent and Recordtypeid=:eventRecordTypeId
                                  and Owner.ProfileId in :mapsalesProfiles.keyset()]; 
        
        //List to hold id of the Accounts for Event that are Completed
        List<id> lstEventAcc = new List<Id>();
        //List to hold id of the Accounts for Event that are Not Completed
        List<id> lstEventAccNotCom = new List<Id>();
        
        //List to hold id of the Opportunities for Event that are Completed
        List<id> lstEventOpp = new List<Id>();
        //List to hold id of the Opportunities for Event that are Not Completed
        List<id> lstEventOppNotCom = new List<Id>();
        
        //List to hold AccountId of the Opportunities in lstEventOpp 
        List<Opportunity> lstOppAcc = new List<Opportunity>();
        //List to hold AccountId of the Opportunities in lstEventOppNotCom 
        List<Opportunity> lstOppAccNotCom = new List<Opportunity>();        

        //Map to hold the id of Opp & Acc for Event that are Completed
        Map<id, id> mapOppAcc = new Map<id, id>();
        //Map to hold the id of Opp & Acc for Event that are Not Completed
        Map<id, id> mapOppAccNotCom = new Map<id, id>();

        //List to hold data of the Accounts in lstEventAcc 
        List<Account> lstAccount = new List<Account>();
        //List to hold data of the Accounts in lstEventAccNotCom  
        List<Account> lstAccountNotCom = new List<Account>();
        
        //List to hold the Events for Accounts for which the Event was marked Not Completed
        List<Event> lstAccComEvents = new List<Event>();
        
        //List to hold the Tasks for Accounts for which the Event was marked Not Completed
        List<Task> lstAccComTasks = new List<Task>();
        
        //Map to hold the AccountId and Max Date of Passed Event/Completed Task
        Map<id, Date> mapAccLstComActDt = New Map<id, Date>();
        //Map to hold the AccountId and Last completed date of Face to Face Activity        
        Map<id, Date> mapAccLstComActDtF2F = New Map<id, Date>();
        
        //Map to hold data of the Accounts to be updated for task that are Completed
        Map<id, Account> mapAccToUpdate = New Map<id, Account>();
        //Map to hold data of the Accounts to be updated for task that are Not Completed        
        Map<id, Account> mapAccToUpdateNotCom = New Map<id, Account>();
        
        system.debug('Code1 - lEvent = ' + lEvent);
        system.debug('Code2 - mapEventOld = ' + mapEventOld);
        system.debug('Code3 - mapEventNew = ' + mapEventNew);
        system.debug('Code4 - ryderEvents = ' + ryderEvents);
        
        //traverse through the list of Events
        for (Event e1: ryderEvents)
        {                   
            string relatedToId = (string) e1.WhatId;
            string contactId = (string) e1.WhoId;
            string EventType = (string) e1.Type;
            datetime EventDueDateTime = e1.ActivityDate;
            datetime EventStartDateTime = e1.StartDateTime;
            datetime EventEndDateTime = e1.EndDateTime;                        
                        
            system.debug('Code3.1 - e1.ActivityDate = ' + e1.ActivityDate + ' mapEventOld.get(e1.Id).ActivityDate = ' + mapEventOld.get(e1.Id).ActivityDate);
                        
            if (e1.ActivityDate <= System.today())
            {
                system.debug('Code3.2');
                if (relatedToId != null) 
                {  
                    system.debug('Code3.3');
                    //If object specified in "Related To" is Account
                    if (relatedToId.substring(0,3)=='001') 
                    {
                        system.debug('Code3.4');
                        lstEventAcc.Add(relatedToId);
                    }
                    //If object specified in "Related To" is Opportunity
                    else if (relatedToId.substring(0,3)=='006')
                    {
                        system.debug('Code3.5');
                        lstEventOpp.add(relatedToId);
                    }
                }
            }
            else if ((e1.ActivityDate > System.today()) && (mapEventOld.get(e1.Id).ActivityDate <= System.today()))
            {
                system.debug('Code3.6');
                if (relatedToId != null) 
                {  
                    system.debug('Code3.7');
                    //If object specified in "Related To" is Account
                    if (relatedToId.substring(0,3)=='001') 
                    {
                        system.debug('Code3.8');
                        lstEventAccNotCom.Add(relatedToId);
                    }
                    //If object specified in "Related To" is Opportunity
                    else if (relatedToId.substring(0,3)=='006')
                    {
                        system.debug('Code3.9');
                        lstEventOppNotCom.add(relatedToId);
                    }
                }
            }
        }

        system.debug('Code5 - lstEventAcc = ' + lstEventAcc);
        system.debug('Code6 - lstEventOpp = ' + lstEventOpp);
        system.debug('Code7 - lstEventAccNotCom = ' + lstEventAccNotCom);
        system.debug('Code8 - lstEventOppNotCom = ' + lstEventOppNotCom);
        
        //Get the AccountId of the Opprtunities in lstEventOpp
        if (lstEventOpp.size()>0) lstOppAcc = [select Id, AccountId from Opportunity where id =:lstEventOpp];
        system.debug('Code9 - lstOppAcc = ' + lstOppAcc);
        
        //Get the AccountId of the Opprtunities in lstEventOppNotCom
        if (lstEventOppNotCom.size()>0) lstOppAccNotCom = [select Id, AccountId from Opportunity where id =:lstEventOppNotCom];
        system.debug('Code10 - lstOppAccNotCom = ' + lstOppAccNotCom);
        
        //Traverse through the lstOppAcc and add the accountId to the lstEventAcc and add opp & acc id to the mapOppAcc
        for (Opportunity opp1: lstOppAcc)
        {
            lstEventAcc.Add(opp1.AccountId);
            if(!mapOppAcc.containskey(opp1.id)) mapOppAcc.put(opp1.id, opp1.AccountId);
        }
        
        //Traverse through the lstOppAccNotComand add the accountId to the lstEventAccNotCom and add opp & acc id to the mapOppAccNotCom
        for (Opportunity opp2: lstOppAccNotCom)
        {
            lstEventAccNotCom.Add(opp2.AccountId);
            if(!mapOppAccNotCom.containskey(opp2.id)) mapOppAccNotCom.put(opp2.id, opp2.AccountId);
        }
        
        system.debug('Code11 - lstEventAcc = ' + lstEventAcc);
        system.debug('Code12 - lstEventAccNotCom = ' + lstEventAccNotCom);
        system.debug('Code13 - mapOppAcc = ' + mapOppAcc);
        system.debug('Code14 - mapOppAccNotCom = ' + mapOppAccNotCom);
        
        //Get the value of Last_Sales_Interaction__c & Last_Face_to_Face_Activity_Date__c for accounts in lstEventAcc
        if (lstEventAcc.size()>0) lstAccount = [select Id, Last_Sales_Interaction__c, Last_Face_to_Face_Activity_Date__c from Account where id =:lstEventAcc];
        system.debug('Code15 - lstAccount = ' + lstAccount);
        
        //Get the value of Last_Sales_Interaction__c & Last_Face_to_Face_Activity_Date__c for accounts in lstEventAccNotCom
        if (lstEventAccNotCom.size()>0)
        {
            lstAccountNotCom = [Select Id, Last_Sales_Interaction__c, Last_Face_to_Face_Activity_Date__c from Account where id =:lstEventAccNotCom];
            system.debug('Code16.1 - lstAccountNotCom = ' + lstAccountNotCom);
            
            lstAccComEvents = [Select Id, AccountId, WhatId, WhoId, Type, ActivityDate, StartDateTime, EndDateTime 
                              from Event where AccountId in :lstEventAccNotCom and Recordtypeid=:eventRecordTypeId and
                              Owner.ProfileId in :mapsalesProfiles.keyset() and ActivityDate <= Today];
            system.debug('Code16.2 - lstAccComEvents = ' + lstAccComEvents);
            
            lstAccComTasks =  [Select Id, AccountId, WhatId, WhoId, Type, Status, ActivityDate from Task 
                              where Recordtypeid=:taskRecordTypeId and Status = 'Completed'  
                              and Owner.ProfileId in :mapsalesProfiles.keyset() and AccountId in :lstEventAccNotCom];
            system.debug('Code16.3 - lstAccComTasks = ' + lstAccComTasks);
        
        }    
                
        if (lstAccComEvents.size() > 0)
        {
            system.debug('Code17');
            for (Event e2: lstAccComEvents)
            {
                system.debug('Code18');
                date eventDueDate = date.valueof(e2.ActivityDate);
                //if((e2.Type == 'Cold Call Face to Face') || (e2.type == 'Deliver Proposal') || (e2.type == 'Face to Face') || (e2.type == 'Face to Face with Decision Maker') || (e2.type == 'Get Signed Deal'))
                if(e2.Type != null && LABEL.Activity_Type.Contains(e2.Type))
                {
                    system.debug('Code19');
                    if(!mapAccLstComActDtF2F.containskey(e2.AccountId)) 
                    {
                        system.debug('Code20.1');
                        mapAccLstComActDtF2F.put(e2.AccountId, eventDueDate);
                    }
                    else
                    {
                        system.debug('Code20.2');
                        if (e2.ActivityDate > mapAccLstComActDtF2F.get(e2.AccountId)) 
                        {
                            system.debug('Code20.3');
                            mapAccLstComActDtF2F.remove(e2.AccountId);
                            mapAccLstComActDtF2F.put(e2.AccountId, eventDueDate);
                        }
                    }
                }
                else
                {
                    system.debug('Code21');
                    if(!mapAccLstComActDt.containskey(e2.AccountId)) 
                    {
                        system.debug('Code22.1');
                        mapAccLstComActDt.put(e2.AccountId, eventDueDate);
                    }
                    else
                    {
                        system.debug('Code22.2');
                        if (e2.ActivityDate > mapAccLstComActDt.get(e2.AccountId)) 
                        {
                            system.debug('Code22.3');
                            mapAccLstComActDt.remove(e2.AccountId);
                            mapAccLstComActDt.put(e2.AccountId, eventDueDate);
                        }
                    }
                }   
            }
        }
        
        system.debug('Code23.1 - mapAccLstComActDt = ' + mapAccLstComActDt);
        system.debug('Code23.2 - mapAccLstComActDtF2F = ' + mapAccLstComActDtF2F);
        
        if (lstAccComTasks.size() > 0)
        {
            system.debug('Code24');
            for (Task t1: lstAccComTasks)
            {
                system.debug('Code25');
                date taskDueDate = date.valueof(t1.ActivityDate);
                //if((t1.Type == 'Cold Call Face to Face') || (t1.type == 'Deliver Proposal') || (t1.type == 'Face to Face') || (t1.type == 'Face to Face with Decision Maker') || (t1.type == 'Get Signed Deal'))
                if(t1.Type != null && LABEL.Activity_Type.Contains(t1.Type))
                {
                    system.debug('Code26');
                    if(!mapAccLstComActDtF2F.containskey(t1.AccountId)) 
                    {
                        system.debug('Code27');
                        mapAccLstComActDtF2F.put(t1.AccountId, taskDueDate);
                    }
                    else
                    {
                        system.debug('Code28');
                        if (t1.ActivityDate > mapAccLstComActDtF2F.get(t1.AccountId)) 
                        {
                            system.debug('Code29');
                            mapAccLstComActDtF2F.remove(t1.AccountId);
                            mapAccLstComActDtF2F.put(t1.AccountId, taskDueDate);
                        }
                    }
                }
                else
                {
                    system.debug('Code30');
                    if(!mapAccLstComActDt.containskey(t1.AccountId)) 
                    {
                        system.debug('Code31');
                        mapAccLstComActDt.put(t1.AccountId, taskDueDate);
                    }
                    else
                    {
                        system.debug('Code32');
                        if (t1.ActivityDate > mapAccLstComActDt.get(t1.AccountId)) 
                        {
                            system.debug('Code33');
                            mapAccLstComActDt.remove(t1.AccountId);
                            mapAccLstComActDt.put(t1.AccountId, taskDueDate);
                        }
                    }
                }
            }
        }
        
        system.debug('Code34.1 - mapAccLstComActDt = ' + mapAccLstComActDt);
        system.debug('Code34.2 - mapAccLstComActDtF2F = ' + mapAccLstComActDtF2F);
                
        //Traverse again through the list of Events
        for (Event e3: ryderEvents)
        {                   
            string relatedToId = (string) e3.WhatId;
            string contactId = (string) e3.WhoId;
            string EventType = (string) e3.Type;
            datetime EventDueDateTime = e3.ActivityDate;
            datetime EventStartDateTime = e3.StartDateTime;
            datetime EventEndDateTime = e3.EndDateTime;
            date EventDueDate = date.valueof(e3.ActivityDate);
                        
            updLSI = false;
            updLF2FAD = false;
            updLSIF2F = false;
            
            system.debug('Code 35 - EventDueDate = ' + EventDueDate);
            
            if ((e3.ActivityDate <= System.today()))// && (mapEventOld.get(e3.Id).ActivityDate == e3.ActivityDate))
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
                                if(mapEventType.get(e3.id) != null)
                                {
                                    system.debug('Code 40 - acc1.Last_Sales_Interaction__c = ' + acc1.Last_Sales_Interaction__c + ', acc1.Last_Face_to_Face_Activity_Date__c = ' + acc1.Last_Face_to_Face_Activity_Date__c + ', EventDueDate = ' + EventDueDate );
                                    if((acc1.Last_Sales_Interaction__c == null) || (acc1.Last_Sales_Interaction__c < EventDueDate))
                                    {
                                        system.debug('Code 41');
                                        updLSI = true;
                                    }
                                    if((acc1.Last_Face_to_Face_Activity_Date__c == null) || (acc1.Last_Face_to_Face_Activity_Date__c < EventDueDate)) 
                                    {
                                        system.debug('Code 42');
                                        updLF2FAD = true;
                                    }
                                }   
                                else //If the task is not of type "Face to Face" 
                                {
                                    system.debug('Code 43 - acc1.Last_Sales_Interaction__c = ' + acc1.Last_Sales_Interaction__c + ', EventDueDate = ' + EventDueDate);
                                    if((acc1.Last_Sales_Interaction__c == null) || (acc1.Last_Sales_Interaction__c < EventDueDate))
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
                            if(!mapAccToUpdate.containskey(e3.Whatid))
                            {
                                mapAccToUpdate.put(e3.Whatid,new Account(id=e3.Whatid,Last_Sales_Interaction__c=EventDueDate,Last_Face_to_Face_Activity_Date__c=EventDueDate));
                                system.debug('Code 45.2 - mapAccToUpdate = ' + mapAccToUpdate);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdate.get(e3.Whatid);
                                if(accToCompare.Last_Sales_Interaction__c > EventDueDate)
                                {
                                    dtLSI = accToCompare.Last_Sales_Interaction__c;
                                }
                                else
                                {
                                    dtLSI = EventDueDate;
                                }
                                if(accToCompare.Last_Face_to_Face_Activity_Date__c > EventDueDate)
                                {
                                    dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                }
                                else
                                {
                                    dtF2F = EventDueDate;
                                }
                                system.debug('Code 45.3 - mapAccToUpdate = ' + mapAccToUpdate);
                                mapAccToUpdate.remove(e3.Whatid);
                                mapAccToUpdate.put(e3.Whatid,new Account(id=e3.Whatid,Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 45.4 - mapAccToUpdate = ' + mapAccToUpdate);
                            }
                        }
                        else if(updLSI == true && updLF2FAD == false)
                        {
                            system.debug('Code 46.1 - mapAccToUpdate = ' + mapAccToUpdate);
                            if(!mapAccToUpdate.containskey(e3.Whatid))
                            {
                                mapAccToUpdate.put(e3.Whatid,new Account(id=e3.Whatid,Last_Sales_Interaction__c=EventDueDate));
                                system.debug('Code 46.2 - mapAccToUpdate = ' + mapAccToUpdate);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdate.get(e3.Whatid);
                                if(accToCompare.Last_Sales_Interaction__c > EventDueDate)
                                {
                                    dtLSI = accToCompare.Last_Sales_Interaction__c;
                                }
                                else
                                {
                                    dtLSI = EventDueDate;
                                }
                                dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                
                                system.debug('Code 46.3 - mapAccToUpdate = ' + mapAccToUpdate);
                                mapAccToUpdate.remove(e3.Whatid);
                                mapAccToUpdate.put(e3.Whatid,new Account(id=e3.Whatid,Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 46.4 - mapAccToUpdate = ' + mapAccToUpdate);
                            }                      
                        }
                        else if(updLSI == false && updLF2FAD == true)
                        {
                            system.debug('Code 47.1 - mapAccToUpdate = ' + mapAccToUpdate);
                            if(!mapAccToUpdate.containskey(e3.Whatid))
                            {
                                mapAccToUpdate.put(e3.Whatid,new Account(id=e3.Whatid,Last_Face_to_Face_Activity_Date__c=EventDueDate));
                                system.debug('Code 47.2 - mapAccToUpdate = ' + mapAccToUpdate);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdate.get(e3.Whatid);
                                dtLSI = accToCompare.Last_Sales_Interaction__c;
                                if(accToCompare.Last_Face_to_Face_Activity_Date__c > EventDueDate)
                                {
                                    dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                }
                                else
                                {
                                    dtF2F = EventDueDate;
                                }
                                system.debug('Code 47.3 - mapAccToUpdate = ' + mapAccToUpdate);
                                mapAccToUpdate.remove(e3.Whatid);
                                mapAccToUpdate.put(e3.Whatid,new Account(id=e3.Whatid,Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
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
                                if(mapEventType.get(e3.id) != null)
                                {
                                    system.debug('Code 52 - acc2.Last_Sales_Interaction__c = ' + acc2.Last_Sales_Interaction__c + ', acc2.Last_Face_to_Face_Activity_Date__c = ' + acc2.Last_Face_to_Face_Activity_Date__c + ', EventDueDate = ' + EventDueDate);
                                    if((acc2.Last_Sales_Interaction__c == null) || (acc2.Last_Sales_Interaction__c < EventDueDate))
                                    {
                                        system.debug('Code 53');
                                        updLSI = true;
                                    }
                                    if((acc2.Last_Face_to_Face_Activity_Date__c == null) || (acc2.Last_Face_to_Face_Activity_Date__c < EventDueDate)) 
                                    {
                                        system.debug('Code 54');
                                        updLF2FAD = true;
                                    }
                                }
                                //If the task is not of type "Face to Face"
                                else
                                {
                                    system.debug('Code 55 - acc2.Last_Sales_Interaction__c = ' + acc2.Last_Sales_Interaction__c + ', EventDueDate = ' + EventDueDate);
                                    if((acc2.Last_Sales_Interaction__c == null) || (acc2.Last_Sales_Interaction__c < EventDueDate))
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
                                mapAccToUpdate.put(mapOppAcc.get(relatedToId),new Account(id=mapOppAcc.get(relatedToId),Last_Sales_Interaction__c=EventDueDate,Last_Face_to_Face_Activity_Date__c=EventDueDate));
                                system.debug('Code 58.2 - mapAccToUpdate = ' + mapAccToUpdate);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdate.get(mapOppAcc.get(relatedToId));
                                if(accToCompare.Last_Sales_Interaction__c > EventDueDate)
                                {
                                    dtLSI = accToCompare.Last_Sales_Interaction__c;
                                }
                                else
                                {
                                    dtLSI = EventDueDate;
                                }
                                if(accToCompare.Last_Face_to_Face_Activity_Date__c > EventDueDate)
                                {
                                    dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                }
                                else
                                {
                                    dtF2F = EventDueDate;
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
                                mapAccToUpdate.put(mapOppAcc.get(relatedToId),new Account(id=mapOppAcc.get(relatedToId),Last_Sales_Interaction__c=EventDueDate));
                                system.debug('Code 59.2 - mapAccToUpdate = ' + mapAccToUpdate);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdate.get(mapOppAcc.get(relatedToId));
                                if(accToCompare.Last_Sales_Interaction__c > EventDueDate)
                                {
                                    dtLSI = accToCompare.Last_Sales_Interaction__c;
                                }
                                else
                                {
                                    dtLSI = EventDueDate;
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
                                mapAccToUpdate.put(mapOppAcc.get(relatedToId),new Account(id=mapOppAcc.get(relatedToId),Last_Face_to_Face_Activity_Date__c=EventDueDate));
                                system.debug('Code 60.2 - mapAccToUpdate = ' + mapAccToUpdate);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdate.get(mapOppAcc.get(relatedToId));
                                dtLSI = accToCompare.Last_Sales_Interaction__c;
                                if(accToCompare.Last_Face_to_Face_Activity_Date__c > EventDueDate)
                                {
                                    dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                }
                                else
                                {
                                    dtF2F = EventDueDate;
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
            else if ((e3.ActivityDate > System.today()) && (mapEventOld.get(e3.Id).ActivityDate <= System.today()))
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
                            if(!mapAccToUpdateNotCom.containskey(e3.WhatId))
                            {
                                mapAccToUpdateNotCom.put(e3.WhatId,new Account(id=e3.WhatId,Last_Sales_Interaction__c=mapAccLstComActDtF2F.get(e3.WhatId),Last_Face_to_Face_Activity_Date__c=mapAccLstComActDtF2F.get(e3.WhatId)));
                                system.debug('Code 72.2 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdateNotCom.get(e3.WhatId);
                                if(accToCompare.Last_Sales_Interaction__c > mapAccLstComActDtF2F.get(e3.WhatId))
                                {
                                    dtLSI = accToCompare.Last_Sales_Interaction__c;
                                }
                                else
                                {
                                    dtLSI = mapAccLstComActDtF2F.get(e3.WhatId);
                                }
                                if(accToCompare.Last_Face_to_Face_Activity_Date__c > mapAccLstComActDtF2F.get(e3.WhatId))
                                {
                                    dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                }
                                else
                                {
                                    dtF2F = mapAccLstComActDtF2F.get(e3.WhatId);
                                }
                                system.debug('Code 72.3 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                                mapAccToUpdateNotCom.remove(e3.WhatId);
                                mapAccToUpdateNotCom.put(e3.WhatId,new Account(id=e3.WhatId,Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 72.4 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                        }
                        else if(updLF2FAD == true && updLSI == true)
                        {
                            system.debug('Code 72.5 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            if(!mapAccToUpdateNotCom.containskey(e3.WhatId))
                            {
                                mapAccToUpdateNotCom.put(e3.WhatId,new Account(id=e3.WhatId,Last_Sales_Interaction__c=mapAccLstComActDt.get(e3.WhatId),Last_Face_to_Face_Activity_Date__c=mapAccLstComActDtF2F.get(e3.WhatId)));
                                system.debug('Code 72.6 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdateNotCom.get(e3.WhatId);
                                if(accToCompare.Last_Sales_Interaction__c > mapAccLstComActDt.get(e3.WhatId))
                                {
                                    dtLSI = accToCompare.Last_Sales_Interaction__c;
                                }
                                else
                                {
                                    dtLSI = mapAccLstComActDt.get(e3.WhatId);
                                }
                                if(accToCompare.Last_Face_to_Face_Activity_Date__c > mapAccLstComActDtF2F.get(e3.WhatId))
                                {
                                    dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                }
                                else
                                {
                                    dtF2F = mapAccLstComActDtF2F.get(e3.WhatId);
                                }
                                system.debug('Code 72.7 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                                mapAccToUpdateNotCom.remove(e3.WhatId);
                                mapAccToUpdateNotCom.put(e3.WhatId,new Account(id=e3.WhatId,Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 72.8 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                        }
                        else if(updLF2FAD == false && updLSIF2F == true)
                        {
                            system.debug('Code 72.9 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            if(!mapAccToUpdateNotCom.containskey(e3.WhatId))
                            {
                                mapAccToUpdateNotCom.put(e3.WhatId,new Account(id=e3.WhatId,Last_Sales_Interaction__c=mapAccLstComActDtF2F.get(e3.WhatId)));
                                system.debug('Code 72.10 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdateNotCom.get(e3.WhatId);
                                if(accToCompare.Last_Sales_Interaction__c > mapAccLstComActDtF2F.get(e3.WhatId))
                                {
                                    dtLSI = accToCompare.Last_Sales_Interaction__c;
                                }
                                else
                                {
                                    dtLSI = mapAccLstComActDt.get(e3.WhatId);
                                }
                                dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                system.debug('Code 72.11 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                                mapAccToUpdateNotCom.remove(e3.WhatId);
                                mapAccToUpdateNotCom.put(e3.WhatId,new Account(id=e3.WhatId,Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 72.12 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                        }
                        else if(updLF2FAD == false && updLSI == true)
                        {
                            system.debug('Code 72.13 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            if(!mapAccToUpdateNotCom.containskey(e3.WhatId))
                            {
                                mapAccToUpdateNotCom.put(e3.WhatId,new Account(id=e3.WhatId,Last_Sales_Interaction__c=mapAccLstComActDt.get(e3.WhatId)));
                                system.debug('Code 72.14 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdateNotCom.get(e3.WhatId);
                                if(accToCompare.Last_Sales_Interaction__c > mapAccLstComActDt.get(e3.WhatId))
                                {
                                    dtLSI = accToCompare.Last_Sales_Interaction__c;
                                }
                                else
                                {
                                    dtLSI = mapAccLstComActDtF2F.get(e3.WhatId);
                                }
                                dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                system.debug('Code 72.15 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                                mapAccToUpdateNotCom.remove(e3.WhatId);
                                mapAccToUpdateNotCom.put(e3.WhatId,new Account(id=e3.WhatId,Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                                system.debug('Code 72.16 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                        }
                        else if(updLF2FAD == true && updLSI == false && updLSIF2F == false)
                        {
                            system.debug('Code 72.17 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            if(!mapAccToUpdateNotCom.containskey(e3.WhatId))
                            {
                                mapAccToUpdateNotCom.put(e3.WhatId,new Account(id=e3.WhatId,Last_Face_to_Face_Activity_Date__c=mapAccLstComActDtF2F.get(e3.WhatId)));
                                system.debug('Code 72.18 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                            }
                            else
                            {
                                Account accToCompare = mapAccToUpdateNotCom.get(e3.WhatId);
                                dtLSI = accToCompare.Last_Sales_Interaction__c;
                                if(accToCompare.Last_Face_to_Face_Activity_Date__c > mapAccLstComActDtF2F.get(e3.WhatId))
                                {
                                    dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                                }
                                else
                                {
                                    dtF2F = mapAccLstComActDtF2F.get(e3.WhatId);
                                }
                                system.debug('Code 72.19 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                                mapAccToUpdateNotCom.remove(e3.WhatId);
                                mapAccToUpdateNotCom.put(e3.WhatId,new Account(id=e3.WhatId,Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
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
                                    system.debug('Code 80.');
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
                        system.debug('Code 82 - mapAccToUpdateNotCom = ' + mapAccToUpdateNotCom);
                    }
                }
            }
        }
        system.debug('Code 83 - mapAccToUpdate.values() = ' + mapAccToUpdate.values());
        if (mapAccToUpdate.size() > 0) update mapAccToUpdate.values(); 
        system.debug('Code 83 - mapAccToUpdate.KeySet() = ' + mapAccToUpdateNotCom.values());
        if (mapAccToUpdateNotCom.size() > 0) update mapAccToUpdateNotCom.values(); 
        system.debug('Code 85');
    }
}