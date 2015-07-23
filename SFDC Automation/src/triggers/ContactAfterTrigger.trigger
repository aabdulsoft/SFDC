trigger ContactAfterTrigger on Contact (after insert) {
    List<AccountTeamMember> accTMList = new List<AccountTeamMember>();
    Set<Id> conOwnerIdSet = new Set<Id>();

    for(Contact con: Trigger.new) {

        if(con.Contact_Source__c != 'Lead Conversion') {
            conOwnerIdSet.add(con.ownerId);
        }
    }
    
    if(!conOwnerIdSet.isEmpty()) {

        Map<Id, User> userMap = new Map<Id, User>([Select Id, Name, profileId From User where id IN: conOwnerIdSet]);
        Map<Id, String> profRoleMap = new Map<Id, String>();
        List<Profile> profList = [select id, name from profile where id in (Select profileId From User where id IN: conOwnerIdSet)];

        for(Profile p: profList) {
            System.debug('*********** userProfileName**************' + p.Name);
            Ryder_Account_Team_Role_Map__c accountRole = Ryder_Account_Team_Role_Map__c.getValues(p.Name);
            System.debug('*********** accountRole1**************' + accountRole);
            if (accountRole == null) {
                accountRole = Ryder_Account_Team_Role_Map__c.getValues(RyderGlobalVariables.DEFAULT_ACCOUNT_ROLE_MAP);
                 System.debug('*********** accountRole2**************' + accountRole);
            }
            profRoleMap.put(p.Id,accountRole.Account_Team_Role__c); 
        }
    
        for(Contact con: Trigger.new) {
            if(con.Contact_Source__c != 'Lead Conversion' && con.Original_Account__c != null) {
                
                AccountTeamMember temp = new AccountTeamMember();
                temp.UserId = con.OwnerId;
                temp.TeamMemberRole = profRoleMap.get(userMap.get(con.ownerId).profileId); 
                temp.AccountId = con.Original_Account__c;
                accTMList.add(temp);
            }
        }
        if(!accTMList.isEmpty()) {
            insert accTMList;
        }
    
    }
}