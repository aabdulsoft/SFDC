/*
Author          : Abdul Aziz Khatri
Date Created    : 06/02/2015
Description     : Account update trigger to check for Enterprise Accounts with Additional Classification either "Enterprise Account" or
"Enterprise Subsidiary" and add the Enterprise Account Manager into the Account Team Member.

Changes History :
06/02/2015  Created for QC 901 Trigger for Enterprise Accounts
*/
trigger EnterpriseAccountTeamTrigger on Account (after update) {
    
    //internal variables 
    List<Account> lsteligibleAccountToAdd = new List<Account>();    //to hold the only accounts for processing

    //loop for selection of eligible enterprise accounts for add to Account Team Member    
    if(!LABEL.UVS_Profile_Ids.contains(UserInfo.getProfileId()))
    {
        for(Account account : Trigger.new){
            if((account.Additional_Classifications__c != null &&
            	(String.ValueOf(account.Additional_Classifications__c).contains('Enterprise Account') || 
				String.ValueOf(account.Additional_Classifications__c).contains('Enterprise Subsidiary'))) &&
				((Trigger.oldMap.get(account.Id).Enterprise_Account_Manager__c == null && account.Enterprise_Account_Manager__c != null)
                    || (Trigger.oldMap.get(account.Id).Enterprise_Account_Manager__c != null   
                        && Trigger.oldMap.get(account.Id).Enterprise_Account_Manager__c != account.Enterprise_Account_Manager__c)))
			{
                lsteligibleAccountToAdd.add(account);
            }
        }
    }
       
        if(lsteligibleAccountToAdd != null && lsteligibleAccountToAdd.size()>0)
            EnterpriseAccountTeamTriggerHandler.updateAccountTeamMember(lsteligibleAccountToAdd);
}