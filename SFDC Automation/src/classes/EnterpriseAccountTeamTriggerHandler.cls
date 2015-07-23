/*
Author 			: Abdul Aziz Khatri
Date Created 	: 06/02/2015
Description		: Account update trigger handler responsible for adding Enterprise Account Manager into the Account Team Member
for Enterprise Accounts with Additional Classification either "Enterprise Account" or "Enterprise Subsidiary" and add the .

Changes History	:
06/02/2015	Created for QC 901 Trigger for Enterprise Accounts
*/

public class EnterpriseAccountTeamTriggerHandler {
  
    public static void updateAccountTeamMember(List<Account> lstAccount) {
    	
        Map<Id, Id> mapAcctTeamMem = new Map<Id, Id>();
        List<AccountTeamMember> lstAccountTeamMemberNew = new List<AccountTeamMember>();
        List<AccountShare> lstAcctShareToUpdate = new List<AccountShare>();
        boolean bTeamMemberNotFound;
        
        for(Account Acc : lstAccount){
            mapAcctTeamMem.put(Acc.Id, Acc.Enterprise_Account_Manager__c);
        }    	
        
        /*
        	Retreiving Account and Team  for the given managers
        */
        List<Account> lstAccountTeam = [Select a.Id, Enterprise_Account_Manager__c, (Select Id, AccountId, UserId, TeamMemberRole 
                                                From AccountTeamMembers where UserId in :mapAcctTeamMem.values()) 
                                                From Account a where id in :mapAcctTeamMem.keyset()];

        boolean bTeamMemberFound;                                       
	    for(Account Acc : lstAccountTeam){
	        List<AccountTeamMember> lstMember = Acc.AccountTeamMembers;
	        bTeamMemberFound = false;
	        if(lstMember != null && lstMember.size() > 0){
	        	for(AccountTeamMember acctteammember : lstMember){
	        		if (mapAcctTeamMem.get(Acc.Id) == acctteammember.UserId){
	        			bTeamMemberFound = true;
	        		} 
	            }
	        }
	        if(!bTeamMemberFound) {
                AccountTeamMember acctTeamMemberNew = new AccountTeamMember();
                acctTeamMemberNew.AccountId = Acc.Id;
                acctTeamMemberNew.UserId = Acc.Enterprise_Account_Manager__c;
                acctTeamMemberNew.TeamMemberRole = Ryder_Account_Team_Role_Map__c.getValues('DNA').Account_Team_Role__c;
                lstAccountTeamMemberNew.add(acctTeamMemberNew);	        	
	        }
	     }
	     
	     if(lstAccountTeamMemberNew != null && lstAccountTeamMemberNew.size()>0)
        	insert lstAccountTeamMemberNew;

         List<Account> lstAccountShares = [Select  a.Id,
	     								(Select UserOrGroupId, RowCause, OpportunityAccessLevel, ContactAccessLevel, 
	     										CaseAccessLevel, AccountId, AccountAccessLevel
	     									From Shares 
	     									Where UserOrGroupId IN :mapAcctTeamMem.values() and RowCause = 'Team') 
               								From Account a 
               								Where a.Id IN :mapAcctTeamMem.keyset()]; 
         for(Account Acc : lstAccountShares){
         	List<AccountShare> lstShares = Acc.Shares;
         	//avoid null check on the list persuming user exisitance from the top process.
         	for(AccountShare share : lstShares){
         		if(mapAcctTeamMem.get(Acc.Id) == share.UserOrGroupId){
					share.AccountAccessLevel = RyderGlobalVariables.WRITE_ACCESS;
					share.OpportunityAccessLevel = RyderGlobalVariables.WRITE_ACCESS;                            
					share.CaseAccessLevel = RyderGlobalVariables.READ_ACCESS;
                    lstAcctShareToUpdate.add(share);
					break;                    
         		}	
         	}
         }

		if(lstAcctShareToUpdate != null && lstAcctShareToUpdate.size()>0)
        	update lstAcctShareToUpdate;
    }
}