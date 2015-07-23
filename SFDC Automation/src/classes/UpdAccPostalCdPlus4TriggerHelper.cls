/*
* 
*   Helper class for the trigger that updates the values of PostalCode_No_Plus_4__c field 
*   when a new account is created or the Physical Zip Code (ShippingPostalCode) is updated
*
*   Author                  |Date             |Comment
*   -----------------------|----------------|--------------------------------------------------
*   Saad Wali Jaan |12.10.2014 |First draft
*
*/
public class UpdAccPostalCdPlus4TriggerHelper {

    public static void UpdateAccount(List<Account> lAccount, Map<Id, Account> mapAccountOld){
        // Set of all accounts
        List<Id> lstChangedAccountIds = new List<Id>();
        List<Account> lstAccounts = new List<Account>();
        list<Account> lstAccountsToUpdate = new list<Account>();
        List<String> lstPostalCodes = new List<String>();
        Map<String, id> mapPostalCodes = new Map<String, id>();
        List<Postal_Code__c> lstPostalCodesObj = new List<Postal_Code__c>();
        
        system.debug('@@@1 - lAccount = ' + lAccount);
        system.debug('@@@2 - mapAccountOld = ' + mapAccountOld);
         
        //Traverse through all the accounts that were created/updated
        for (Account acct : lAccount)
        {
            // Check if the PostalCodePlus is null or ShippingPostalCode has changed
            if ((acct.ShippingPostalCode != mapAccountOld.get(acct.Id).ShippingPostalCode) ||
                (mapAccountOld.get(acct.Id).PostalCode_No_Plus_4__c == null) || (acct.ShippingPostalCode == null && acct.PostalCode_No_Plus_4__c != null))              
            {
                lstChangedAccountIds.add(acct.Id);
            }
        }
        
        system.debug('@@@3 - lstChangedAccountIds = ' + lstChangedAccountIds);
        
        //Traverse through all the accounts that were created/updated and has PostalCodePlus as null or ShippingPostalCode has changed
        if (lstChangedAccountIds.size() > 0){    
            //Get the id, ShippingPostalCode and ShippingCountry for the accounts
            lstAccounts = [select id, ShippingPostalCode, ShippingCountry from account where id in :lstChangedAccountIds];
            
            system.debug('@@@4 - lstAccounts = ' + lstAccounts); 
            
            for (Account act : lstAccounts ){
                if (act.ShippingCountry == 'US'){
                    //system.debug('@@@4.1 -  act.ShippingPostalCode.length() = ' +  act.ShippingPostalCode.length());
                    If(act.ShippingPostalCode != null && act.ShippingPostalCode.length() >= 5) lstPostalCodes.add(act.ShippingPostalCode.substring(0,5));
                }
                else if (act.ShippingCountry == 'CA'){
                    //system.debug('@@@4.2 - act.ShippingPostalCode.substring(0,5) = ' + act.ShippingPostalCode.substring(0,3));                    
                    If(act.ShippingPostalCode != null && act.ShippingPostalCode.length() >= 3) lstPostalCodes.add(act.ShippingPostalCode.substring(0,3));
                }
            }
            
            system.debug('@@@5 - lstPostalCodes = ' + lstPostalCodes);
            
            //Get the ID of the Postal_Code object
            lstPostalCodesObj = [select id, Name, Postal_Code__c from Postal_Code__c where Postal_Code__c in :lstPostalCodes];
            
            system.debug('@@@6 - lstPostalCodesObj = ' + lstPostalCodesObj);
            
            for (Postal_Code__c pc : lstPostalCodesObj){
                if(!mapPostalCodes.containskey(pc.Name)) mapPostalCodes.put(pc.Name, pc.id);
            }
            
            system.debug('@@@7 - mapPostalCodes = ' + mapPostalCodes); 
            
            for (Account acc : lstAccounts ){
                if (acc.ShippingPostalCode!= null)
                {
                    system.debug('@@@7.1');
                    if (acc.ShippingCountry == 'US' && acc.ShippingPostalCode.length() >= 5){
                        system.debug('@@@7.2');
                        if (mapPostalCodes.containsKey(acc.ShippingPostalCode.substring(0,5))){
                            system.debug('@@@7.3');
                            //Assign the id of the Postal Code to the PostalCode_No_Plus_4__c
                            lstAccountsToUpdate.add(new Account(id=acc.id,PostalCode_No_Plus_4__c=mapPostalCodes.get(acc.ShippingPostalCode.substring(0,5)))); 
                        }
                        else
                        {
                            system.debug('@@@7.4');
                            lstAccountsToUpdate.add(new Account(id=acc.id,PostalCode_No_Plus_4__c=null)); 
                        }
                    }
                    else if (acc.ShippingCountry == 'CA' && acc.ShippingPostalCode.length() >= 3){
                        system.debug('@@@7.5');
                        if (mapPostalCodes.containsKey(acc.ShippingPostalCode.substring(0,3))){
                            system.debug('@@@7.6');
                            //Assign the id of the Postal Code to the PostalCode_No_Plus_4__c
                            lstAccountsToUpdate.add(new Account(id=acc.id,PostalCode_No_Plus_4__c=mapPostalCodes.get(acc.ShippingPostalCode.substring(0,3)))); 
                        }
                        else
                        {
                            system.debug('@@@7.7');
                            lstAccountsToUpdate.add(new Account(id=acc.id,PostalCode_No_Plus_4__c=null)); 
                        }
                    }
                }
                else if (acc.ShippingPostalCode == null)
                {
                    system.debug('@@@7.8');
                    lstAccountsToUpdate.add(new Account(id=acc.id,PostalCode_No_Plus_4__c=null)); 
                }
            }
            
            system.debug('@@@8 - lstAccountsToUpdate = ' + lstAccountsToUpdate);
            //Update the Accounts
            update lstAccountsToUpdate;
        }
    }
}