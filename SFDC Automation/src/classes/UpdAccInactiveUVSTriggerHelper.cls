/*
* 
*   Helper class for the UpdAccInactiveUVSTrigger that assigns SalesAdmin as the owner of 
*   the Account, deletes the AccountTeamMember when a UVS user marks the Account as Inactive
*
*   Author           |Author-Email                      |Date       |Comment
*   -----------------|----------------------------------|-----------|--------------------------------------------------
*   Saad Wali Jaan   |                                  |01.13.2015 |First draft
*
*/

public class UpdAccInactiveUVSTriggerHelper {

    public static void UpdateAccount(List<Account> lAccount, Map<Id, Account> mapAccountOld){
        
        List<Id> lstChangedAccountIds = new List<Id>();
        
        List<AccountTeamMember> lstAccountTeamMembers = new List<AccountTeamMember>();
        List<AccountTeamMember> lstAccountTeamMembersTBD = new List<AccountTeamMember>();
        
        List<Contact> lstAccountContact = new List<Contact>();
        List<Contact> lstAccountContactTBU = new List<Contact>();        
        
        List<Opportunity> lstAccountOpp = new List<Opportunity>();
        List<Opportunity> lstAccountOppTBU = new List<Opportunity>();        

        List<Account> lstAccounts = new List<Account>();
        list<Account> lstAccountsToUpdate = new list<Account>();

        List<User> lstSalesAdmin = [Select id from User where name = 'Sales Admin' limit 1];
        
        system.debug('@@@@1 - lAccount = ' + lAccount);
        system.debug('@@@@2 - mapAccountOld = ' + mapAccountOld);
        
        //Traverse through all the accounts that were marked inactive and the user was a UVS user
        for (Account acct : lAccount)
        {
            // Check if the Account is marked Inactive by a UVS user and the owner of the Account is a UVS user.
            if (acct.Status_Active__c == 'No' && mapAccountOld.get(acct.Id).Status_Active__c == 'Yes' 
                && UVS_Util.isUVSProfile(acct.OwnerId) && UVS_Util.isUVSProfile(UserInfo.getUserId()))
            {
                lstChangedAccountIds.add(acct.Id);
            }
        }
        system.debug('@@@@3 - lstChangedAccountIds = ' + lstChangedAccountIds);
        
        //Get the list of Accounts, AccountTeamMembers, Contacts and Opportunities which are related to Account Id in lstChangedAccountIds
        if (lstChangedAccountIds.size() > 0){ 
        
            //Get the id's, OwnerId's of the Account for the changed Accounts
            lstAccounts = [select id, OwnerId from account where id in :lstChangedAccountIds];
        
            //Get the id's of the AccountTeamMember for the changed Accounts
            lstAccountTeamMembers = [select id from AccountTeamMember where AccountId in :lstChangedAccountIds];
        
            //Get the id's of the Contact for the changed Accounts
            lstAccountContact = [select id from Contact where AccountId in :lstChangedAccountIds];
        
            //Get the id's of the Opportunities for the changed Accounts
            lstAccountOpp = [select id from Opportunity where AccountId in :lstChangedAccountIds];
        }
        
        system.debug('@@@@4.1 - lstAccounts = ' + lstAccounts);
        system.debug('@@@@4.2 - lstAccountTeamMembers = ' + lstAccountTeamMembers);
        system.debug('@@@@4.3 - lstAccountContact = ' + lstAccountContact);
        system.debug('@@@@4.4 - lstAccountOpp = ' + lstAccountOpp); 
        
        //Creating the list of accounts to be updated
        if (lstAccounts.size() > 0){ 
            for (Account acc : lstAccounts){
                lstAccountsToUpdate.add(new Account(id=acc.id, ownerId=lstSalesAdmin[0].id));
            }
        }
        system.debug('@@@@5 - lstAccountsToUpdate = ' + lstAccountsToUpdate);
        
        //Creating the list of AccountTeamMembers to be deleted
        if (lstAccountTeamMembers.size() > 0){
            for (AccountTeamMember atm : lstAccountTeamMembers){
                lstAccountTeamMembersTBD.add(new AccountTeamMember(id=atm.id));
            }
        }
        system.debug('@@@@6 - lstAccountTeamMembersTBD = ' + lstAccountTeamMembersTBD);
        
        //Creating the list of Contacts to be updated
        if (lstAccountContact.size() > 0){
            for (Contact acnt : lstAccountContact){
                lstAccountContactTBU.add(new Contact(id=acnt.id, OwnerId=lstSalesAdmin[0].id));
            }
        }
        system.debug('@@@@7 - lstAccountContactTBU = ' + lstAccountContactTBU);

        //Creating the list of Opportunities to be updated
        if (lstAccountOpp.size() > 0){
            for (Opportunity aopp : lstAccountOpp){
                lstAccountOppTBU.add(new Opportunity(id=aopp.id, OwnerId=lstSalesAdmin[0].id));
            }
        }
        system.debug('@@@@8 - lstAccountOppTBU = ' + lstAccountOppTBU);        
        
        //Updating the Account Owner to Sales Admin
        if (lstAccountsToUpdate.size() > 0) update lstAccountsToUpdate;
        //Deleting the AccountTeamMembers
        if (lstAccountTeamMembersTBD.size() > 0) delete lstAccountTeamMembersTBD;
        //Updating the Contact Owner to Sales Admin
        if (lstAccountContactTBU.size() > 0) update lstAccountContactTBU;
        //Updating the Opportunity Owner to Sales Admin
        if (lstAccountOppTBU.size() > 0) update lstAccountOppTBU;
    }
}