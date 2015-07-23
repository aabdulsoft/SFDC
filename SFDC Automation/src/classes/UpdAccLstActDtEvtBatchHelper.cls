//Batch Class to update fields Last Sales Interaction, Last Face To Face Activity on Account page
global class UpdAccLstActDtEvtBatchHelper implements Database.Batchable<SObject>{

  public String query;
  global Database.QueryLocator start(Database.BatchableContext BC){
  
      system.debug('@123 - query = ' + query);
      return Database.getQueryLocator(query);
   }
   
    global void execute(Database.BatchableContext BC, List<Event> scope){
        
        date dtLSI;
        date dtF2F;

        Id recordTypeId; 
        Boolean updLSI;
        Boolean updLF2FAD;

        //List of Profiles for which the field needs to be updated  
        List<string> lSalesProfiles = new List<string>(LABEL.Ryder_Sales_Profiles.split(','));
        system.debug('UALADEBH.1 - lSalesProfiles = ' + lSalesProfiles);
        
        //Getting a map of all users who are in the specified list of Sales Profile
        Map<Id,Profile> mapsalesProfiles=new Map<id,profile>([Select p.Id from Profile p where Name in :lSalesProfiles]);
        system.debug('UALADEBH.2 - mapsalesProfiles = ' + mapsalesProfiles);      
         
        //List of Event types for which the Face To Face field needs to be updated  
        List<string> lEventType = new List<string>(LABEL.Activity_Type.split(','));
        system.debug('UALADEBH.3 - lEventType = ' + lEventType);   
        
        //Getting the recordTypeId of the 'Ryder Event'
        recordTypeId=LABEL.Ryder_Event_Record_ID; 
        system.debug('UALADEBH.4 - recordTypeId = ' + recordTypeId);        
        
        //Getting a map of all Events which are in the specified list of Sales Profile
        Map<Id,Event> mapEventType=new Map<id,Event>([Select Id from Event where Id in :Scope and Recordtypeid=:recordTypeId and Type in :lEventType]);
        system.debug('UALADEBH.5 - mapEventType = ' + mapEventType);        
        
        //Get the list of all Event which satisfies the following condition
        List<Event> ryderEvents = [Select Id, WhatId, WhoId, Type, ActivityDate, StartDateTime, EndDateTime from Event 
                                  where Id in :Scope and Recordtypeid=:recordTypeId 
                                  and Owner.ProfileId in :mapsalesProfiles.keyset()]; 
       system.debug('UALADEBH.6 - ryderEvents = ' + ryderEvents);
       
        //List to hold id of the Accounts for Event that are Passed
        List<id> lstEventAcc = new List<Id>();
        //List to hold id of the Opportunity for Event that are Passed
        List<id> lstEventOpp = new List<Id>();
        
        //List to hold AccountId of the Opportunities in lstEventOpp 
        List<Opportunity> lstOppAcc = new List<Opportunity>();
        //Map to hold the id of Opp & Acc for Event that are Passed
        Map<id, id> mapOppAcc = new Map<id, id>();
       
        //List to hold data of the Accounts in lstEventAcc 
        List<Account> lstAccount = new List<Account>();
        
        //Map to hold data of the Accounts to be updated for Event that are passed
        Map<id, Account> mapAccToUpdate = New Map<id, Account>();        
         
        for (Event evt1: ryderEvents)
        {
            string relatedToId = (string) evt1.WhatId;
            string contactId = (string) evt1.WhoId;
            string EventType = (string) evt1.Type;
            datetime EventDueDateTime = evt1.ActivityDate;
            datetime EventStartDateTime = evt1.StartDateTime;
            datetime EventEndDateTime = evt1.EndDateTime;
            
            if (relatedToId != null) 
            {  
                //If object specified in "Related To" is Account
                if (relatedToId.substring(0,3)=='001') 
                {
                    lstEventAcc.Add(relatedToId);
                }
                //If object specified in "Related To" is Opportunity
                else if (relatedToId.substring(0,3)=='006')
                {
                    lstEventOpp.add(relatedToId);
                }
            }
        }
        
        system.debug('UALADEBH.7 - lstEventAcc = ' + lstEventAcc);
        system.debug('UALADEBH.8 - lstEventOpp = ' + lstEventOpp);
        
        //Get the AccountId of the Opprtunities in lstTskOpp
        if (lstEventOpp.size()>0) lstOppAcc = [select Id, AccountId from Opportunity where id =:lstEventOpp];
        system.debug('UALADEBH.9 - lstOppAcc = ' + lstOppAcc);
        
        //Traverse through the lstOppAcc and add the accountId to the lstEventAcc and add opp & acc id to the mapOppAcc
        for (Opportunity opp: lstOppAcc)
        {
            lstEventAcc.Add(opp.AccountId);
            if(!mapOppAcc.containskey(opp.id)) mapOppAcc.put(opp.id, opp.AccountId);
        }
        
        system.debug('UALADEBH.10 - lstEventAcc = ' + lstEventAcc);
        system.debug('UALADEBH.11 - mapOppAcc = ' + mapOppAcc);
        
        //Get the value of Last_Sales_Interaction__c & Last_Face_to_Face_Activity_Date__c for accounts in lstTskAcc
        if (lstEventAcc.size()>0) lstAccount = [select Id, Last_Sales_Interaction__c, Last_Face_to_Face_Activity_Date__c from Account where id =:lstEventAcc];
        system.debug('UALADEBH.12 - lstAccount = ' + lstAccount);
        
        //Traverse again through the list of Events
        for (Event evt2: ryderEvents)
        {                   
            string relatedToId = (string) evt2.WhatId;
            string contactId = (string) evt2.WhoId;
            string EventType = (string) evt2.Type;
            datetime EventDueDateTime = evt2.ActivityDate;
            datetime EventStartDateTime = evt2.StartDateTime;
            datetime EventEndDateTime = evt2.EndDateTime;
            date EventDueDate = date.valueof(evt2.ActivityDate);
            updLSI = false;
            updLF2FAD = false;
            system.debug('UALADEBH.13 - relatedToId = ' + relatedToId + ', EventId = ' + evt2.id);
            if (relatedToId != null) 
            {  
                system.debug('UALADEBH.14');
                //If object specified in "Related To" is Account
                if (relatedToId.substring(0,3)=='001') 
                {
                    system.debug('UALADEBH.15');
                    //Traverse through the list of Accounts to check if WhatId = AccountId
                    for (Account acc1: lstAccount)
                    {
                        system.debug('UALADEBH.16 - acc1.id = ' + acc1.id + ', relatedToId = ' + relatedToId);
                        if (acc1.id == relatedToId)
                        {
                            system.debug('UALADEBH.17');
                            //Check if the Event is of type "Face to Face"
                            if(mapEventType.get(evt2.id) != null)
                            {
                                system.debug('UALADEBH.18');
                                if((acc1.Last_Sales_Interaction__c == null) || (acc1.Last_Sales_Interaction__c < EventDueDate))
                                {
                                    system.debug('UALADEBH.19');
                                    updLSI = true;
                                }
                                if((acc1.Last_Face_to_Face_Activity_Date__c == null) || (acc1.Last_Face_to_Face_Activity_Date__c < EventDueDate)) 
                                {
                                    system.debug('UALADEBH.20');
                                    updLF2FAD = true;
                                }
                            }
                            //If the Event is not of type "Face to Face"
                            else
                            {
                                system.debug('UALADEBH.21');
                                if((acc1.Last_Sales_Interaction__c == null) || (acc1.Last_Sales_Interaction__c < EventDueDate))
                                {
                                    system.debug('UALADEBH.22');
                                    updLSI = true;
                                }
                            }
                        }
                    }
                    if(updLSI == true && updLF2FAD == true)
                    {
                        system.debug('UALADEBH.23.1');
                        if(!mapAccToUpdate.containskey(evt2.Whatid))                            
                        {
                            mapAccToUpdate.put(evt2.Whatid,new Account(id=evt2.Whatid,Last_Sales_Interaction__c=EventDueDate,Last_Face_to_Face_Activity_Date__c=EventDueDate));
                            system.debug('UALADEBH.23.2 - mapAccToUpdate = ' + mapAccToUpdate);
                        }
                        else
                        {
                            Account accToCompare = mapAccToUpdate.get(evt2.Whatid);
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
                            system.debug('UALADEBH.23.3 - mapAccToUpdate = ' + mapAccToUpdate);
                            mapAccToUpdate.remove(evt2.Whatid);
                            mapAccToUpdate.put(evt2.Whatid,new Account(id=evt2.Whatid,Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                            system.debug('UALADEBH.23.4 - mapAccToUpdate = ' + mapAccToUpdate);
                        }
                    }
                    else if(updLSI == true && updLF2FAD == false)
                    {
                        system.debug('UALADEBH.24');
                        if(!mapAccToUpdate.containskey(evt2.Whatid))
                        {
                            mapAccToUpdate.put(evt2.Whatid,new Account(id=evt2.Whatid,Last_Sales_Interaction__c=EventDueDate));
                            system.debug('UALADEBH.24.2 - mapAccToUpdate = ' + mapAccToUpdate);
                        }
                        else
                        {
                            Account accToCompare = mapAccToUpdate.get(evt2.Whatid);
                            if(accToCompare.Last_Sales_Interaction__c > EventDueDate)
                            {
                                dtLSI = accToCompare.Last_Sales_Interaction__c;
                            }
                            else
                            {
                                dtLSI = EventDueDate;
                            }
                            dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                            
                            system.debug('UALADEBH.24.3 - mapAccToUpdate = ' + mapAccToUpdate);
                            mapAccToUpdate.remove(evt2.Whatid);
                            mapAccToUpdate.put(evt2.Whatid,new Account(id=evt2.Whatid,Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                            system.debug('UALADEBH.24.4 - mapAccToUpdate = ' + mapAccToUpdate);
                        }                        
                    }
                    else if(updLSI == false && updLF2FAD == true)
                    {
                        system.debug('UALADEBH.25');
                        if(!mapAccToUpdate.containskey(evt2.Whatid))
                        {
                            mapAccToUpdate.put(evt2.Whatid,new Account(id=evt2.Whatid,Last_Face_to_Face_Activity_Date__c=EventDueDate));
                            system.debug('UALADEBH.25.2 - mapAccToUpdate = ' + mapAccToUpdate);
                        }
                        else
                        {
                            Account accToCompare = mapAccToUpdate.get(evt2.Whatid);
                            dtLSI = accToCompare.Last_Sales_Interaction__c;
                            if(accToCompare.Last_Face_to_Face_Activity_Date__c > EventDueDate)
                            {
                                dtF2F = accToCompare.Last_Face_to_Face_Activity_Date__c;
                            }
                            else
                            {
                                dtF2F = EventDueDate;
                            }
                            system.debug('UALADEBH.25.3 - mapAccToUpdate = ' + mapAccToUpdate);
                            mapAccToUpdate.remove(evt2.Whatid);
                            mapAccToUpdate.put(evt2.Whatid,new Account(id=evt2.Whatid,Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                            system.debug('Code 25.4 - mapAccToUpdate = ' + mapAccToUpdate);
                        }                        
                    }
                    system.debug('UALADEBH.26 - updLSI = ' + updLSI + ', updLF2FAD = ' + updLF2FAD);                    
                    updLSI = false;
                    updLF2FAD = false;
                }
                //If object specified in "Related To" is Opportunity
                else if (relatedToId.substring(0,3)=='006')
                {
                    system.debug('UALADEBH.27');
                    //Traverse through the list of Accounts to check if WhatId = AccountId
                    for (Account acc2: lstAccount)
                    {
                        system.debug('UALADEBH.28');
                        if ((mapOppAcc.containsKey(relatedToId)) && (acc2.id == mapOppAcc.get(relatedToId)))
                        {
                            system.debug('UALADEBH.29');
                            //Check if the Event is of type "Face to Face"
                            if(mapEventType.get(evt2.id) != null)
                            {
                                system.debug('UALADEBH.30');
                                if((acc2.Last_Sales_Interaction__c == null) || (acc2.Last_Sales_Interaction__c < EventDueDate))
                                {
                                    system.debug('UALADEBH.31');
                                    updLSI = true;
                                }
                                if((acc2.Last_Face_to_Face_Activity_Date__c == null) || (acc2.Last_Face_to_Face_Activity_Date__c < EventDueDate)) 
                                {
                                    system.debug('UALADEBH.32');
                                    updLF2FAD = true;
                                }
                            }
                            //If the Event is not of type "Face to Face"
                            else
                            {
                                system.debug('UALADEBH.33');
                                if((acc2.Last_Sales_Interaction__c == null) || (acc2.Last_Sales_Interaction__c < EventDueDate))
                                {
                                    system.debug('UALADEBH.34');
                                    updLSI = true;
                                }
                            }
                        }
                    }
                    system.debug('UALADEBH.35');
                    if(updLSI == true && updLF2FAD == true)
                    {
                        system.debug('UALADEBH.36.1');
                        if(!mapAccToUpdate.containskey(mapOppAcc.get(relatedToId)))
                        {
                            mapAccToUpdate.put(mapOppAcc.get(relatedToId),new Account(id=mapOppAcc.get(relatedToId),Last_Sales_Interaction__c=EventDueDate,Last_Face_to_Face_Activity_Date__c=EventDueDate));
                            system.debug('UALADEBH.36.2 - mapAccToUpdate = ' + mapAccToUpdate);
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
                            system.debug('UALADEBH.36.3 - mapAccToUpdate = ' + mapAccToUpdate);
                            mapAccToUpdate.remove(mapOppAcc.get(relatedToId));
                            mapAccToUpdate.put(mapOppAcc.get(relatedToId),new Account(id=mapOppAcc.get(relatedToId),Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                            system.debug('UALADEBH.36.4 - mapAccToUpdate = ' + mapAccToUpdate);
                        }
                        
                    }
                    else if(updLSI == true && updLF2FAD == false)
                    {
                        system.debug('UALADEBH.37.1');
                        if(!mapAccToUpdate.containskey(mapOppAcc.get(relatedToId)))
                        {
                            mapAccToUpdate.put(mapOppAcc.get(relatedToId),new Account(id=mapOppAcc.get(relatedToId),Last_Sales_Interaction__c=EventDueDate));
                            system.debug('UALADEBH.37.2 - mapAccToUpdate = ' + mapAccToUpdate);
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
                            system.debug('UALADEBH.37.3 - mapAccToUpdate = ' + mapAccToUpdate);
                            mapAccToUpdate.remove(mapOppAcc.get(relatedToId));
                            mapAccToUpdate.put(mapOppAcc.get(relatedToId),new Account(id=mapOppAcc.get(relatedToId),Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                            system.debug('UALADEBH.37.4 - mapAccToUpdate = ' + mapAccToUpdate);
                        }                        
                    }
                    else if(updLSI == false && updLF2FAD == true)
                    {
                        system.debug('UALADEBH.38.1');
                        if(!mapAccToUpdate.containskey(mapOppAcc.get(relatedToId)))
                        {
                            mapAccToUpdate.put(mapOppAcc.get(relatedToId),new Account(id=mapOppAcc.get(relatedToId),Last_Face_to_Face_Activity_Date__c=EventDueDate));
                            system.debug('UALADEBH.38.2 - mapAccToUpdate = ' + mapAccToUpdate);
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
                            system.debug('UALADEBH.38.3 - mapAccToUpdate = ' + mapAccToUpdate);
                            mapAccToUpdate.remove(mapOppAcc.get(relatedToId));
                            mapAccToUpdate.put(mapOppAcc.get(relatedToId),new Account(id=mapOppAcc.get(relatedToId),Last_Sales_Interaction__c=dtLSI,Last_Face_to_Face_Activity_Date__c=dtF2F));
                            system.debug('UALADEBH.38.4 - mapAccToUpdate = ' + mapAccToUpdate);
                        }
                    }
                    system.debug('UALADEBH.39 - updLSI = ' + updLSI + ', updLF2FAD = ' + updLF2FAD);                    
                    updLSI = false;
                    updLF2FAD = false;                    
                }
            }
        }    
        system.debug('UALADEBH.40.1 - mapAccToUpdate.values() = ' + mapAccToUpdate.values());
        if (mapAccToUpdate.size() > 0) update mapAccToUpdate.values(); 
        system.debug('UALADEBH.40.2'); 
    }
   
    global void finish(Database.BatchableContext BC){
    }
}