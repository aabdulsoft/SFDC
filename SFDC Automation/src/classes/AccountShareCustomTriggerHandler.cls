/*
Author: Abdul Aziz Khatri
Project: UVS RCE
Description: This trigger created to handle the account sharing among the UVS rep based on the group of a particular Rep.
            The trigger will automatically add the group of the UVS rep converting the lead to an Account. The trigger also
            initialize the AccountShare Standard Object by removing all Manual enteries and adding them back using AccountShareCustom
            Custom Object.
*/


public class AccountShareCustomTriggerHandler {

    //The method will add the Record to AccountShareCustom Custom Object and AcccountShare SObject
    //when Account gets created or updated. 
    public static void insertRecord(List<Account> lstNewAccount, Map<Id, Account> mapNewAccount)
    {
        
        //Setting up the Ids        
        Set<Id> setAccIds = mapNewAccount.keySet();
        system.debug('Account Ids : ' + setAccIds);

        //Retreving information related to the Accounts
        List<AccountShareCustom__c> lstAcctShareCustom = new List<AccountShareCustom__c>([SELECT AccountId__c, GroupId__c FROM AccountShareCustom__c WHERE AccountId__c IN :setAccIds]);
        
        //air
        if(lstAcctShareCustom!= null && lstAcctShareCustom.size() > 0){
            
            //air
            Map<Id, List<AccountShareCustom__c>> mapExistingAcctShareCustom = new Map<Id, List<AccountShareCustom__c>>();
            //List<String> lstAcctShareCustGroupIds = new List<String>();
            for (AccountShareCustom__c accsharecust : lstAcctShareCustom){
                if(!mapExistingAcctShareCustom.containsKey(accsharecust.AccountId__c))
                    mapExistingAcctShareCustom.put(accsharecust.AccountId__c, new List<AccountShareCustom__c>());
                mapExistingAcctShareCustom.get(accsharecust.AccountId__c).add(accsharecust);
            }
             
            //Pulling Manual Account Share for delete
            //List<AccountShare> lstAcctShare = new List<AccountShare>([SELECT Id, AccountId FROM AccountShare WHERE AccountId IN :setAccIds AND RowCause = 'Manual']);
            List<AccountShare> lstAcctShare = new List<AccountShare>();
            for(AccountShare acctshare : [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :setAccIds AND RowCause = 'Manual']){
                if(mapExistingAcctShareCustom.get(acctshare.AccountId) != null && mapExistingAcctShareCustom.get(acctshare.AccountId).size()>0){
                    List<AccountShareCustom__c> lstacctsharecust = mapExistingAcctShareCustom.get(acctshare.AccountId);
                    if(lstacctsharecust != null && lstacctsharecust.size()>0){
                        Boolean bFound = false;
                        for(AccountShareCustom__c acctsharecust : lstacctsharecust){
                            if(acctsharecust.GroupId__c == acctshare.UserOrGroupId){
                                bFound = true;
                                break;
                            }
                        }
                        if(bFound)
                            lstAcctShare.add(acctshare);
                    }
                    
                }
            }
            if(lstAcctShare != null && lstAcctShare.size() > 0)
                delete lstAcctShare;
    
            //creating instance to add based on the AccountShareCustom
            List<AccountShare> lstAcctShareToAdd = new List<AccountShare>();        
            for(AccountShareCustom__c acctShareCust : lstAcctShareCustom)
            {
                AccountShare accShare = new AccountShare();
                accShare.AccountId = acctShareCust.AccountId__c;
                accShare.AccountAccessLevel=RyderGlobalVariables.WRITE_ACCESS;
                accShare.OpportunityAccessLevel = 'None'; //RyderGlobalVariables.PRIVATE_ACCESS;
                accShare.CaseAccessLevel = RyderGlobalVariables.READ_ACCESS;
                accShare.UserOrGroupId = acctShareCust.GroupId__c;
                lstAcctShareToAdd.add(accShare);
        }
        
        if(lstAcctShareToAdd.size() > 0)
            insert lstAcctShareToAdd;       
        }
    }
    
    //The method will delete the Record from the AcccountShareCustom object when the Account gets deleted.
    public static void deleteRecord(Map<Id, Account> mapAccounts) {
 
        //Setting up the Ids 
        Set<Id> setAccIds = mapAccounts.keySet();
        system.debug('Account Ids : ' + setAccIds);
       
       
        //Retereiving the AccountShareCustom based on the Ids for delete.
        List<AccountShareCustom__c> lstAcctShareCustom = new List<AccountShareCustom__c>([SELECT AccountId__c, GroupId__c FROM AccountShareCustom__c WHERE AccountId__c IN :setAccIds]);
        system.debug('lstAcctShareCustom : ' + lstAcctShareCustom);
        
        if(lstAcctShareCustom.size() > 0)
            delete lstAcctShareCustom;
        
    }
    
}