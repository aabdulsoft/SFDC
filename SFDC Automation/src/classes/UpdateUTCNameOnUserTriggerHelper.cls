/*
* 
*   Helper class for the trigger UpdateUTCNameOnUserTrigger that updates the UTC_Name__c field when the UTC__c field is updated on the User.
*
*   Author                     |Date               |Comment
*   ---------------------------|-------------------|-------------------------------------------------
*   Saad Wali Jaan             |06.07.2015         |First draft
*
*/
public class UpdateUTCNameOnUserTriggerHelper {

    public static void UpdateUser(List<User> listUsers, Map<Id, User> mapOldUsers, Map<Id, User> mapNewUsers) {
        
        Set<String> setUTCCodes = new Set<String>();
        //Set<String> setBranchCodes = new Set<String>();
        Map<id, User> mapUserToUpdate = new Map<id, User>();
        Map<string, string> mapBranchCodeName = new Map<string, string>();
        
        system.debug('UTC1 - listUsers = ' + listUsers);
        system.debug('UTC2 - mapOldUsers = ' + mapOldUsers);
        
        //UVSProfileForUTC;
        
        //Populate the UTC codes only when the UTC code is either updated or during the user record getting created
        for(User U : listUsers) 
        {
            system.debug('UTC3-U.Profile.Name = ' + U.ProfileId + ' LABEL.UVSProfileForUTC = ' + LABEL.UVSProfileForUTC);
            if(UVS_Util.isUVSProfile(u.id))
            {            
                if(U.ProfileId == LABEL.UVSProfileForUTC)
                {                
                    system.debug('UTC4');
                    //For the insert case (where the UTC is filled) and update case            
                    if((mapOldUsers == null && u.UTC__c != null) || (mapOldUsers != null && u.UTC__c != null && u.UTC__c != mapOldUsers.get(u.Id).UTC__c)) 
                    {
                        setUTCCodes.add(u.UTC__c);                
                        system.debug('UTC5 - setUTCCodes = ' + setUTCCodes);
                    }
                }
                else
                {                
                    //For UVS users exect VSM_VSR where UTC is updated to be blank
                    //if(mapOldUsers != null && u.UTC__c == null && u.UTC__c != mapOldUsers.get(u.Id).UTC__c) { 
                    mapUserToUpdate.put(u.id, new User(id=u.id, UTC_Name__c='No UTC Assigned'));
                    system.debug('UTC6 - mapUserToUpdate = ' + mapUserToUpdate);
                }
            }
            else
            {
                //For all other users the UTC_Name__c should be blank            
                mapUserToUpdate.put(u.id, new User(id=u.id, UTC_Name__c=null));
                system.debug('UTC7 - mapUserToUpdate = ' + mapUserToUpdate);          
            }          
        }

        // if there is any records eligible, then perform the validation.
        if(setUTCCodes.size() > 0) 
        {
            system.debug('UTC8');        
            // Get the branch code from Ryder Branch object.
            for(Ryder_Branch__c ryderBranch : [SELECT Branch_Code__c, Name FROM Ryder_Branch__c WHERE Branch_Code__c IN :setUTCCodes]) 
            {

                mapBranchCodeName.put(ryderBranch.Branch_Code__c, ryderBranch.Name);
                system.debug('UTC9 - mapBranchCodeName = ' + mapBranchCodeName);                
                
                //setBranchCodes.add(ryderBranch.Branch_Code__c);
                //system.debug('UTC6 - setBranchCodes = ' + setBranchCodes);              
            }

            // Check if the UTC code matches the branch code in Ryder Branch.
            for(User u : listUsers) 
            {
                mapUserToUpdate.put(u.id, new User(id=u.id, UTC_Name__c=mapBranchCodeName.get(u.UTC__c)));
                system.debug('UTC10 - mapUserToUpdate = ' + mapUserToUpdate);
            }
        }
                    
        system.debug('UTC11 - mapUserToUpdate = ' + mapUserToUpdate);
        if (mapUserToUpdate.size() > 0) update mapUserToUpdate.values();
    }
}