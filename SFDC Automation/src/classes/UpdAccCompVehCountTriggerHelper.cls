/*
* 
*   Helper class for the UpdAccCompVehCountTriggerHelper that updates the count of competitive 391vehicles on account
*
*   Author           |Author-Email                      |Date       |Comment
*   -----------------|----------------------------------|-----------|--------------------------------------------------
*   Saad Wali Jaan   |                                  |05.01.2015 |First draft
*
*/

public with sharing class UpdAccCompVehCountTriggerHelper {
    
    public static void UpdateAccount(List<Competitor_Vehicle__c> lCompVehAll, Map<Id, Competitor_Vehicle__c> mapOld){

        string accId;    
        id parentAccId;
        integer vehCount;
        integer parentVehCount;

        system.debug('UpdAcc - lCompVehAll = ' + lCompVehAll + ' mapOld = ' + mapOld);

        //Getting the list of all Truck Types that are not to be included in the count
        List<string> lTrucks = RyderConfig__c.getOrgDefaults().TruckTypes__c.split(',');
         
        //Getting the id's of account for which Competitor Vehicle data has been added/updated
        List<id> lstChangedId = new List<id>();
        for(Competitor_Vehicle__c comVeh: lCompVehAll)
        {
            lstChangedId.add(comVeh.Account__c);
        }
        system.debug('UpdAcc0 - lstChangedId = ' + lstChangedId);
        
        //List for storing id's of all account for which Competitor Vehicles have been added/updated
        List<Account> lstChangedAccId = New List<Account>();
        if(lstChangedId.size() > 0)
        {
            lstChangedAccId = [Select id from Account where id in: lstChangedId];
        }
        
        //Getting the Parent Id's of the accounts in the lstChangedAccId and store it in lstParentAccId 
        List<Account> lstParentAccId = New List<Account>();
        if(lstChangedAccId.size() > 0)
        {
            lstParentAccId = [Select ParentId from Account where id in: lstChangedAccId];
        }
        system.debug('UpdAcc1 - lstParentAccId = ' + lstParentAccId);
        
        Set<id> setParentId = New Set<id>();
        if(lstParentAccId.size() > 0)
        {        
            for(Account lPA: lstParentAccId)
            {
                if (lPA.ParentId <> null)
                {
                      setParentId.Add(lPA.ParentId);    
                }
            }
        }
        system.debug('UpdAcc2 - setParentId = ' + setParentId);
                
        //Getting the Id's of all the Child Id's of the Account in the lstParentAccId and storing in lstParentChildAccId 
        List<Account> lstChildAccId = New List<Account>();
        if(lstParentAccId.size() > 0)
        {
            system.debug('UpdAcc3.1 - Select id from Account where ParentId in: ' + setParentId);
            lstChildAccId = [Select id from Account where ParentId in: setParentId];
        }
        system.debug('UpdAcc3 - lstChildAccId = ' + lstChildAccId);
        
        //List for storing id's of all accounts which exists in the above lists (lstChangedAccId, lstParentAccId, lstChildAccId) 
        Set<id> setAccId = new Set<id>();
        
        if (lstChangedAccId.size() > 0)
        {
            for(Account acc1: lstChangedAccId)
            {
                setAccId.add(acc1.id);
            }
        }
        system.debug('UpdAcc4 - setAccId  = ' + setAccId );
        
        if (lstChildAccId.size() > 0)
        {
            for(Account acc2: lstChildAccId )
            {
                setAccId .add(acc2.id);
            }
        }
        system.debug('UpdAcc5 - setAccId  = ' + setAccId );
        
        if (lstParentAccId.size() > 0)
        {        
            for(Account acc3: lstParentAccId)
            {
                if (acc3.ParentId <> null)
                {
                    setAccId .add(acc3.ParentId);
                }
            }
        }
        system.debug('UpdAcc6 - setAccId  = ' + setAccId );
        
        //List to store the Id's and Parent Id's of all the accounts in setAccId 
        List<Account> lstParentChildAccId = [Select id, ParentId from Account where id in: setAccId ]; 

        system.debug('UpdAcc7 - lstParentChildAccId = ' + lstParentChildAccId );
        
        //Map to store the id & parent id's of the account
        Map<id, id> mapAccPrnt = new Map<id, id>();
        
        //Adding the accountid and Parentid to the map
        if(lstParentChildAccId.size()>0)
        {
            for (Account acc: lstParentChildAccId)
            {
                //Adding account and 
                if(!mapAccPrnt.containskey(acc.id) && acc.id<>null) mapAccPrnt.put(acc.id, acc.ParentId);
                if(!mapAccPrnt.containskey(acc.ParentId) && acc.ParentId<>null) mapAccPrnt.put(acc.ParentId, null);
            }
        }
        system.debug('UpdAcc8 - mapAccPrnt = ' + mapAccPrnt);
         
        //Creating a list to store the id's and count of the account for which Competitor vehicles are added/updated
        List<AggregateResult> lstAccVehCnt = [Select Account__c, SUM(Vehicle_Count__c) VehCount from Competitor_Vehicle__c 
                                            where Account__c in :mapAccPrnt.keySet() and Class__c not in :lTrucks group by Account__c]; 
       
        system.debug('UpdAcc9 - lstAccVehCnt = ' + lstAccVehCnt);
        
        //Creating a map to store the id's and count of the account for which Competitor vehicles are added/updated
        Map<Id,Integer> mapChangedAccountIds = new Map<Id,Integer>();
        
        if (lstAccVehCnt.size() > 0)
        {
            system.debug('UpdAcc10');
            //Iterating through the list
            for(AggregateResult accCnt: lstAccVehCnt)
            {
                accId = String.valueOf(accCnt.get('Account__c'));
                vehCount = Integer.valueOf(accCnt.get('VehCount'));
                system.debug('UpdAcc11 - mapChangedAccountIds = ' + mapChangedAccountIds);
                system.debug('UpdAcc12 - accId = ' + accId + ' vehCount = ' + vehCount);
                
                //Checking if the AccountId already exists in the map
                if(!mapChangedAccountIds.containskey(accId))
                {
                    system.debug('UpdAcc13');
                    //Checking if the account is a parent account
                    if(mapAccPrnt.get(accId) == null)
                    {
                        system.debug('UpdAcc14 - accId = ' + accId + ' vehCount = ' + vehCount);
                        //Adding the parent account to the map to be updated
                        mapChangedAccountIds.put(accId, vehCount);
                        system.debug('UpdAcc15 - mapChangedAccountIds = ' + mapChangedAccountIds);
                    }
                    else //If account is a child account
                    {
                        system.debug('UpdAcc16 - accId = ' + accId + ' vehCount = ' + vehCount);
                        //Adding the child account to the map to be updated
                        mapChangedAccountIds.put(accId, vehCount);
                        system.debug('UpdAcc17 - mapChangedAccountIds = ' + mapChangedAccountIds);
                        
                        //Checking if the Parent Account of the child account already exists in the map to be updated
                        if(!mapChangedAccountIds.containskey(mapAccPrnt.get(accId)))
                        {
                            system.debug('UpdAcc18 - mapAccPrnt.get(accId) = ' + mapAccPrnt.get(accId) + ' vehCount = ' + vehCount);
                            //Adding the Parent account and count of veh of child account in the map to be updated
                            mapChangedAccountIds.put(mapAccPrnt.get(accId), vehCount);
                            system.debug('UpdAcc19 - mapChangedAccountIds = ' + mapChangedAccountIds);
                        
                        }
                        else //if the Parent Account of the child account already exists in the map to be updated
                        {
                            //Getting the count of Vehicles at Parent Account
                            parentAccId = mapAccPrnt.get(accId);
                            
                            //Getting the count of Vehicles at Parent Account
                            parentVehCount = mapChangedAccountIds.get(parentAccId);
                            
                            //Updating the count of Vehicles at Parent Account with the count of vehicles of Child Account
                            parentVehCount = parentVehCount + vehCount;
                            
                            system.debug('UpdAcc20 - parentAccId = ' + parentAccId  + ' parentVehCount = ' + parentVehCount);
                            
                            //Updating the map
                            mapChangedAccountIds.remove(parentAccId);
                            mapChangedAccountIds.put(parentAccId, parentVehCount);
                            system.debug('UpdAcc21 - mapChangedAccountIds = ' + mapChangedAccountIds);
                        
                        }
                    }
                } 
                else
                {
                    //Getting the count of Vehicles at Parent Account
                    parentVehCount = mapChangedAccountIds.get(accId);
                    
                    //Updating the count of Vehicles at Parent Account with the count of vehicles of Parent Account
                    parentVehCount = parentVehCount + vehCount;
                    
                    system.debug('UpdAcc22 - accId = ' + accId + ' parentVehCount = ' + parentVehCount);
                    
                    //Updating the map
                    mapChangedAccountIds.remove(accId);
                    mapChangedAccountIds.put(accId, parentVehCount);
                    system.debug('UpdAcc23 - mapChangedAccountIds = ' + mapChangedAccountIds);
                        
                }
            }
        }
        system.debug('UpdAcc24 - mapChangedAccountIds = ' + mapChangedAccountIds);
        
        //Set for storing id's of all account to be updated
        Set<Account> setAccToUpdate = new Set<Account>();
        
        //Again traverse through the entire list
        if (lstAccVehCnt.size() > 0)
        {
            for(AggregateResult ar: lstAccVehCnt)
            {
                accId = String.valueOf(ar.get('Account__c'));
                vehCount = Integer.valueOf(ar.get('VehCount'));
                
                system.debug('UpdAcc25 - ar = ' + ar+ ' accId  = ' + accId  + ' VehicleCount = ' + vehCount);
                if(accId <> null)
                {
                    setAccToUpdate.add(new Account(id=accId,Total_Competitive_Units__c=mapChangedAccountIds.get(accId)));
                }
                system.debug('UpdAcc26 - setAccToUpdate = ' + setAccToUpdate);
                if(mapAccPrnt.get(accId) <> null)
                {
                    setAccToUpdate.add(new Account(id=mapAccPrnt.get(accId),Total_Competitive_Units__c=mapChangedAccountIds.get(mapAccPrnt.get(accId))));
                }
                system.debug('UpdAcc27 - setAccToUpdate = ' + setAccToUpdate);
            }
        }
        system.debug('UpdAcc28 - setAccToUpdate = ' + setAccToUpdate);
        
        //List for storing id's of all account to be updated
        List<Account> lstAccToUpdate = new List<Account>(setAccToUpdate);
        system.debug('UpdAcc29 - lstAccToUpdate = ' + lstAccToUpdate);
        
        if (lstAccToUpdate.size()>0) update lstAccToUpdate;
    }
    
    
    //Function to update the count of Competitive Vehicles when the Competitve Vehicle data is deleted
    public static void UpdateAccountAfterDelete(List<Competitor_Vehicle__c> lCompVehAll, Map<Id, Competitor_Vehicle__c> mapOld){
        
        string accId;    
        id parentAccId;
        integer vehCount;
        integer parentVehCount;
        
        system.debug('UpdAcc30.1 - lCompVehAll = ' + lCompVehAll + ' mapOld = ' + mapOld);
        
        //Getting the list of all Truck Types that are not to be included in the count
        List<string> lTrucks = RyderConfig__c.getOrgDefaults().TruckTypes__c.split(',');
        
        //Map to store the AccountId and count of Competitive Vehices deleted
        Map<Id,Integer> mapDeletedAccountIds = new Map<Id,Integer>();
        
        //Getting the id's of account for which Competitor Vehicle data has been deleted    
        set<id> setChangedId = new set<id>();        
        for(Competitor_Vehicle__c comVeh: mapOld.values())
        {
            setChangedId.add(comVeh.Account__c);
            system.debug('UpdAcc30.2 - setChangedId = ' + setChangedId);
            
            if(!mapDeletedAccountIds.containskey(comVeh.Account__c)) 
            {
                mapDeletedAccountIds.put(comVeh.Account__c, Integer.valueOf(comVeh.Vehicle_Count__c));
                system.debug('UpdAcc30.3 - mapDeletedAccountIds = ' + mapDeletedAccountIds);
            }
            else
            {
                vehCount = Integer.valueOf(mapDeletedAccountIds.get(comVeh.Account__c));
                vehCount = vehCount + Integer.valueOf(comVeh.Vehicle_Count__c); 
                
                system.debug('UpdAcc30.4 - comVeh.Account__c = ' + comVeh.Account__c + ' mapDeletedAccountIds.get(comVeh.Account__c) = ' +  mapDeletedAccountIds.get(comVeh.Account__c) + ' vehCount = ' + vehCount);
                system.debug('UpdAcc30.5 - mapDeletedAccountIds = ' + mapDeletedAccountIds);
                
                mapDeletedAccountIds.remove(comVeh.Account__c);
                mapDeletedAccountIds.put(comVeh.Account__c, vehCount);
                
                system.debug('UpdAcc30.6 - mapDeletedAccountIds = ' + mapDeletedAccountIds);
                vehCount = 0;
            }
        }
        system.debug('UpdAcc30.7 - setChangedId = ' + setChangedId);
        system.debug('UpdAcc30.8 - mapDeletedAccountIds = ' + mapDeletedAccountIds);
        
        //List for storing id's of all account for which Competitor Vehicles have been added/updated
        List<Account> lstChangedAccId = New List<Account>();
        if(setChangedId.size() > 0)
        {
            lstChangedAccId = [Select id, Total_Competitive_Units__c from Account where id in: setChangedId];
        }
        system.debug('UpdAcc31 - lstChangedAccId = ' + lstChangedAccId);
        
        //Getting the Parent Id's of the accounts in the lstChangedAccId and store it in lstParentAccId 
        List<Account> lstParentAccId = New List<Account>();
        if(lstChangedAccId.size() > 0)
        {
            lstParentAccId = [Select ParentId from Account where id in: lstChangedAccId];
        }
        system.debug('UpdAcc32 - lstParentAccId = ' + lstParentAccId);
        
        Set<id> setParentId = New Set<id>();
        if(lstParentAccId.size() > 0)
        {        
            for(Account lPA: lstParentAccId)
            {
                if (lPA.ParentId <> null)
                {
                      setParentId.Add(lPA.ParentId);    
                }
            }
        }
        system.debug('UpdAcc33 - setParentId = ' + setParentId);
                
        //Getting the Id's of all the Child Id's of the Account in the lstParentAccId and storing in lstParentChildAccId 
        List<Account> lstChildAccId = New List<Account>();
        if(lstParentAccId.size() > 0)
        {
            lstChildAccId = [Select id from Account where ParentId in: setParentId];
        }
        system.debug('UpdAcc34 - lstChildAccId = ' + lstChildAccId);
        
        //Set for storing id's of all accounts which exists in the above lists (lstChangedAccId, lstParentAccId, lstChildAccId) 
        Set<id> setAccId = new Set<id>();
        
        if (lstChangedAccId.size() > 0)
        {
            for(Account acc1: lstChangedAccId)
            {
                setAccId.add(acc1.id);
            }
        }
        system.debug('UpdAcc35 - setAccId  = ' + setAccId );
        
        if (lstChildAccId.size() > 0)
        {
            for(Account acc2: lstChildAccId )
            {
                setAccId .add(acc2.id);
            }
        }
        system.debug('UpdAcc36 - setAccId  = ' + setAccId );
        
        if (lstParentAccId.size() > 0)
        {        
            for(Account acc3: lstParentAccId)
            {
                if (acc3.ParentId <> null)
                {
                    setAccId .add(acc3.ParentId);
                }
            }
        }
        system.debug('UpdAcc37 - setAccId  = ' + setAccId );
        
        //List to store the Id's and Parent Id's of all the accounts in setAccId 
        List<Account> lstParentChildAccId = [Select id, ParentId from Account where id in: setAccId ]; 
        system.debug('UpdAcc38.1 - lstParentChildAccId = ' + lstParentChildAccId );
        
        List<Account> lAccount = [Select id, Total_Competitive_Units__c from Account where id in: setAccId];
        system.debug('UpdAcc38.2 - lAccount = ' + lAccount);
        
        //Map to store the id & parent id's of the account
        Map<id, id> mapAccPrnt = new Map<id, id>();
        
        //Adding the accountid and Parentid to the map
        if(lstParentChildAccId.size()>0)
        {
            for (Account acc: lstParentChildAccId)
            {
                //Adding account and 
                if(!mapAccPrnt.containskey(acc.id) && acc.id<>null) mapAccPrnt.put(acc.id, acc.ParentId);
                if(!mapAccPrnt.containskey(acc.ParentId) && acc.ParentId<>null) mapAccPrnt.put(acc.ParentId, null);
            }
        }
        system.debug('UpdAcc39 - mapAccPrnt = ' + mapAccPrnt);
     
        for(Account acc: lAccount)
        {
            //Check If the account exists in the mapAccPrnt
            system.debug('UpdAcc39.1 - acc.id = ' + acc.id + ' Total_Competitive_Units__c = ' + acc.Total_Competitive_Units__c);
            if(mapAccPrnt.containskey(acc.id))
            {
                system.debug('UpdAcc39.2');
                //Check if it is a parent Account
                if(mapAccPrnt.get(acc.id) == null)
                {
                    system.debug('UpdAcc39.3');
                    //Check if the account exists in the mapDeletedAccountIds
                    if(!mapDeletedAccountIds.containskey(acc.id))
                    {
                        //Adding the Parent Account to the Map
                        system.debug('UpdAcc39.4 - mapDeletedAccountIds = ' + mapDeletedAccountIds);
                        mapDeletedAccountIds.put(acc.id, Integer.valueOf(acc.Total_Competitive_Units__c));   
                        system.debug('UpdAcc39.5 - mapDeletedAccountIds = ' + mapDeletedAccountIds);
                    }
                    else
                    {
                        vehCount = Integer.valueOf(acc.Total_Competitive_Units__c) - Integer.valueOf(mapDeletedAccountIds.get(acc.id));
                        system.debug('UpdAcc39.6 - mapDeletedAccountIds = ' + mapDeletedAccountIds);
                        system.debug('UpdAcc39.7 - vehCount = ' + vehCount + ' acc.Total_Competitive_Units__c = ' + acc.Total_Competitive_Units__c + ' mapDeletedAccountIds.get(acc.id) = ' + mapDeletedAccountIds.get(acc.id));
                        mapDeletedAccountIds.remove(acc.id);
                        mapDeletedAccountIds.put(acc.id, vehCount);
                        system.debug('UpdAcc39.8 - mapDeletedAccountIds = ' + mapDeletedAccountIds);
                    }
                }    
                else
                {
                    system.debug('UpdAcc39.9');
                    if(mapDeletedAccountIds.containskey(acc.id))
                    {
                        vehCount = Integer.valueOf(acc.Total_Competitive_Units__c) - Integer.valueOf(mapDeletedAccountIds.get(acc.id));
                        system.debug('UpdAcc39.10 - mapDeletedAccountIds = ' + mapDeletedAccountIds);
                        system.debug('UpdAcc39.11 - vehCount = ' + vehCount + ' acc.Total_Competitive_Units__c = ' + acc.Total_Competitive_Units__c + ' mapDeletedAccountIds.get(acc.id) = ' + mapDeletedAccountIds.get(acc.id));
                        mapDeletedAccountIds.remove(acc.id);
                        mapDeletedAccountIds.put(acc.id, vehCount);
                        system.debug('UpdAcc39.12 - mapDeletedAccountIds = ' + mapDeletedAccountIds);
                        
                        //Write the logic to subtract the data from parent account
                        if(!mapDeletedAccountIds.containskey(mapAccPrnt.get(acc.id)))
                        {
                            vehCount = 0 - Integer.valueOf(acc.Total_Competitive_Units__c);
                            system.debug('UpdAcc39.13 - acc.Total_Competitive_Units__c = ' + acc.Total_Competitive_Units__c + ' vehCount = ' + vehCount);
                            system.debug('UpdAcc39.14 - mapDeletedAccountIds = ' + mapDeletedAccountIds);
                            mapDeletedAccountIds.put(mapAccPrnt.get(acc.id), vehCount);
                            system.debug('UpdAcc39.15 - mapDeletedAccountIds = ' + mapDeletedAccountIds);
                        }        
                        else
                        {
                            vehCount = Integer.valueOf(mapDeletedAccountIds.get(mapAccPrnt.get(acc.id))) - Integer.valueOf(acc.Total_Competitive_Units__c);
                            system.debug('UpdAcc39.16 - acc.Total_Competitive_Units__c = ' + acc.Total_Competitive_Units__c);
                            system.debug('UpdAcc39.17 - mapDeletedAccountIds.get(mapAccPrnt.get(acc.id)) = ' + mapDeletedAccountIds.get(mapAccPrnt.get(acc.id)) + ' vehCount = ' + vehCount);
                            system.debug('UpdAcc39.18 - mapDeletedAccountIds = ' + mapDeletedAccountIds);
                            mapDeletedAccountIds.remove(mapAccPrnt.get(acc.id));
                            mapDeletedAccountIds.put(mapAccPrnt.get(acc.id), vehCount);
                            system.debug('UpdAcc39.19 - mapDeletedAccountIds = ' + mapDeletedAccountIds);
                        }
                    }
                    else
                    {
                        system.debug('UpdAcc39.20');
                    }
                }
            }
        }
        
        //Creating a list to store the id's and count of the account for which Competitor vehicles are added/updated
        List<AggregateResult> lstAccVehCnt = [Select Account__c, SUM(Vehicle_Count__c) VehCount from Competitor_Vehicle__c 
                                            where Account__c in :mapAccPrnt.keySet() and Class__c not in :lTrucks group by Account__c]; 
        
        system.debug('UpdAcc40.3 - lstAccVehCnt = ' + lstAccVehCnt);
        
        //Creating a map to store the id's and count of the account for which Competitor vehicles are added/updated
        Map<Id,Integer> mapChangedAccountIds = new Map<Id,Integer>();
        
 /*       if (lstAccVehCnt.size() > 0)
        {
            system.debug('UpdAcc41');
            //Iterating through the list
            for(AggregateResult accCnt: lstAccVehCnt)
            {
                accId = String.valueOf(accCnt.get('Account__c'));
                vehCount = Integer.valueOf(accCnt.get('VehCount'));
                system.debug('UpdAcc42 - mapChangedAccountIds = ' + mapChangedAccountIds);
                system.debug('UpdAcc43 - accId = ' + accId + ' vehCount = ' + vehCount);
                
                //Checking if the AccountId already exists in the map
                if(!mapChangedAccountIds.containskey(accId))
                {
                    system.debug('UpdAcc44');
                    //Checking if the account is a parent account
                    if(mapAccPrnt.get(accId) == null)
                    {
                        system.debug('UpdAcc45 - accId = ' + accId + ' vehCount = ' + vehCount);
                        //Adding the parent account to the map to be updated
                        mapChangedAccountIds.put(accId, vehCount);
                        system.debug('UpdAcc46 - mapChangedAccountIds = ' + mapChangedAccountIds);
                    }
                    else //If account is a child account
                    {
                        system.debug('UpdAcc47 - accId = ' + accId + ' vehCount = ' + vehCount);
                        //Adding the child account to the map to be updated
                        mapChangedAccountIds.put(accId, vehCount);
                        system.debug('UpdAcc48 - mapChangedAccountIds = ' + mapChangedAccountIds);
                        
                        //Checking if the Parent Account of the child account already exists in the map to be updated
                        if(!mapChangedAccountIds.containskey(mapAccPrnt.get(accId)))
                        {
                            system.debug('UpdAcc49 - mapAccPrnt.get(accId) = ' + mapAccPrnt.get(accId) + ' vehCount = ' + vehCount);
                            //Adding the Parent account and count of veh of child account in the map to be updated
                            mapChangedAccountIds.put(mapAccPrnt.get(accId), vehCount);
                            system.debug('UpdAcc50 - mapChangedAccountIds = ' + mapChangedAccountIds);
                        
                        }
                        else //if the Parent Account of the child account already exists in the map to be updated
                        {
                            //Getting the count of Vehicles at Parent Account
                            parentAccId = mapAccPrnt.get(accId);
                            
                            //Getting the count of Vehicles at Parent Account
                            parentVehCount = mapChangedAccountIds.get(parentAccId);
                            
                            //Updating the count of Vehicles at Parent Account with the count of vehicles of Child Account
                            parentVehCount = parentVehCount + vehCount;
                            
                            system.debug('UpdAcc51 - parentAccId = ' + parentAccId  + ' parentVehCount = ' + parentVehCount);
                            
                            //Updating the map
                            mapChangedAccountIds.remove(parentAccId);
                            mapChangedAccountIds.put(parentAccId, parentVehCount);
                            system.debug('UpdAcc52 - mapChangedAccountIds = ' + mapChangedAccountIds);
                        }
                    }
                } 
                else
                {
                    //Getting the count of Vehicles at Parent Account
                    parentVehCount = mapChangedAccountIds.get(accId);
                    
                    //Updating the count of Vehicles at Parent Account with the count of vehicles of Parent Account
                    parentVehCount = parentVehCount + vehCount;
                    
                    system.debug('UpdAcc53 - accId = ' + accId + ' parentVehCount = ' + parentVehCount);
                    
                    //Updating the map
                    mapChangedAccountIds.remove(accId);
                    mapChangedAccountIds.put(accId, parentVehCount);
                    system.debug('UpdAcc54 - mapChangedAccountIds = ' + mapChangedAccountIds);
                        
                }
            }
        }
        system.debug('UpdAcc55 - mapChangedAccountIds = ' + mapChangedAccountIds);
        
        
        //Again traverse through the entire list
        if (lstAccVehCnt.size() > 0)
        {
            for(AggregateResult ar: lstAccVehCnt)
            {
                accId = String.valueOf(ar.get('Account__c'));
                vehCount = Integer.valueOf(ar.get('VehCount'));
                
                system.debug('UpdAcc56 - ar = ' + ar+ ' accId  = ' + accId  + ' VehicleCount = ' + vehCount);
                if(accId <> null)
                {
                    setAccToUpdate.add(new Account(id=accId,Total_Competitive_Units__c=mapChangedAccountIds.get(accId)));
                }
                system.debug('UpdAcc57 - setAccToUpdate = ' + setAccToUpdate);
                if(mapAccPrnt.get(accId) <> null)
                {
                    setAccToUpdate.add(new Account(id=mapAccPrnt.get(accId),Total_Competitive_Units__c=mapChangedAccountIds.get(mapAccPrnt.get(accId))));
                }
                system.debug('UpdAcc58 - setAccToUpdate = ' + setAccToUpdate);
            }
        }
        system.debug('UpdAcc59 - setAccToUpdate = ' + setAccToUpdate);
*/      
        //Set for storing id's of all account to be updated
        Set<Account> setAccToUpdate = new Set<Account>();
        
  
        for (Account ac: lAccount)
        {
            system.debug('UpdAcc60 - setAccToUpdate = ' + setAccToUpdate);
            if(mapDeletedAccountIds.get(ac.id) <> null)
            {
                setAccToUpdate.add(new Account(id=ac.id,Total_Competitive_Units__c=mapDeletedAccountIds.get(ac.id)));
            }
            system.debug('UpdAcc61 - setAccToUpdate = ' + setAccToUpdate);
        }
        
        //List for storing id's of all account to be updated
        List<Account> lstAccToUpdate = new List<Account>(setAccToUpdate);
        system.debug('UpdAcc62 - lstAccToUpdate = ' + lstAccToUpdate);
        
        if (lstAccToUpdate.size()>0) update lstAccToUpdate;
    }
}