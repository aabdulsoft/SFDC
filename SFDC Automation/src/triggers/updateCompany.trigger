/**
* 
*   Account Update trigger checks if the values for the update company has changed and notifies and updates accounts using webservice
*
*   Author           |Author-Email                      |Date       |Comment
*   ----------------------|----------------------------------|-----------|--------------------------------------------------
*   Vishal Patel          |vishal@comitydesigns.com          |12.13.2010 |First draft
*   Abdul Aziz Khatri(AAK)|abdulaziz_khatri@ryder.com        |04.15.2014 |Added condition bypassing data.com clean auto update user
*
*/
trigger updateCompany on Account (after update) 
{
    // ADDED Logic to bypass ETL user from calling updatecompany
    // AAK 04/15/2014 - ADDED Logic to bypass Data.com clean autoupdate user
    if ((!UserInfo.getUserName().contains(RyderConfig__c.getOrgDefaults().ETL_Username__c)) && (!UserInfo.getUserName().contains(RyderConfig__c.getOrgDefaults().Data_comcleanuser__c))) {
        if (RyderGlobalVariables.UPDATE_ACCOUNT_TRIGGER == true)
        {
            // Set of all accounts
            Set<Id> acctSet = new Set<Id>();
            
            //mph 2/1/11 - additional functionality to update child accounts if parent accounts classification changes
            List<Id> changedAccountIds = new List<Id>();
            List<Account> childAccounts = new List<Account>();
            Map<String, Id> accountRecordTypeMap = CommonFunctions.getRecordTypeMap('Account');
            // Go through the account and check if something has changed
            for (Account acct : trigger.new)
            {
                //mph 2/1/11 - removed checks for nulls: e.g. :acct.CompanyTypeID__c != null && acct.CompanyTypeID__c != trigger.oldMap.get(acct.Id).CompanyTypeID__c ||
                // Check if any of the below information has changed
                if (acct.RecordTypeId == accountRecordTypeMap.get(RyderGlobalVariables.AccountRecordTypeName.Ryder_Parent_Account.name()) &&
                           ( acct.Name != trigger.oldMap.get(acct.Id).Name ||
                            acct.CompanyTypeID__c != trigger.oldMap.get(acct.Id).CompanyTypeID__c ||
                            acct.CO_SEGMENT__c != trigger.oldMap.get(acct.Id).CO_SEGMENT__c ||
                            // acct.Sic != trigger.oldMap.get(acct.Id).Sic ||
                           // 03/29 Neelima- replace sic with sic_code__c
                            acct.SIC_Code__c != trigger.oldMap.get(acct.Id).SIC_Code__c||
                            acct.LesseeNo__c != trigger.oldMap.get(acct.Id).LesseeNo__c ||
                            acct.Industry != trigger.oldMap.get(acct.Id).Industry ||
                            acct.CustomerTypeID__c != trigger.oldMap.get(acct.Id).CustomerTypeID__c ||
                            acct.Site_Duns__c != trigger.oldMap.get(acct.Id).Site_Duns__c ||
                            acct.DUNS_HQ__c != trigger.oldMap.get(acct.Id).DUNS_HQ__c ||
                            acct.Domestic_Ultimate_DUNS__c != trigger.oldMap.get(acct.Id).Domestic_Ultimate_DUNS__c ||
                           // acct.NationalCustFlag__c != trigger.oldMap.get(acct.Id).NationalCustFlag__c ||
                            acct.Legal_Site_Duns__c != trigger.oldMap.get(acct.Id).Legal_Site_Duns__c ||
                            //03/28 Neelima --- replaced nationalCustFlag with account classification
                           // 11/14/2012 commenting out classification field as we don not need to make radar call if classification changes
                           // acct.Account_Classification__c != trigger.oldMap.get(acct.Id).Account_Classification__c ||
                            //08/28/2012 Saad - added fields for Equifax 
                            acct.Equifax_No__c != trigger.oldMap.get(acct.Id).Equifax_No__c || 
                            acct.Legal_Equifax_No__c != trigger.oldMap.get(acct.Id).Legal_Equifax_No__c ||
                            acct.Equifax_Street1__c != trigger.oldMap.get(acct.Id).Equifax_Street1__c ||
                            acct.Equifax_Street2__c != trigger.oldMap.get(acct.Id).Equifax_Street2__c ||
                            acct.Equifax_City__c != trigger.oldMap.get(acct.Id).Equifax_City__c ||
                            acct.Equifax_State__c != trigger.oldMap.get(acct.Id).Equifax_State__c ||
                            acct.Equifax_Country__c != trigger.oldMap.get(acct.Id).Equifax_Country__c ||
                            acct.Equifax_Zip_Postal_Code__c != trigger.oldMap.get(acct.Id).Equifax_Zip_Postal_Code__c ||
                            acct.Equifax_Phone__c != trigger.oldMap.get(acct.Id).Equifax_Phone__c ||
                            acct.Equifax_Fax__c != trigger.oldMap.get(acct.Id).Equifax_Fax__c ||
                            acct.Equifax_Email__c != trigger.oldMap.get(acct.Id).Equifax_Email__c ||
                            acct.Equifax_Company_Name__c != trigger.oldMap.get(acct.Id).Equifax_Company_Name__c)
                    )
                 
                {
                     acctSet.add(acct.Id);
                }
                
                //MPH 2/1/11 update child accounts classification when parent changes - populate list of accounts whose account_classification__c have changed
                if (acct.Account_Classification__c != trigger.oldmap.get(acct.Id).Account_Classification__c){
                    changedAccountIds.add(acct.id);
                }  
            }
            
            //mph 2/1/11 - grab the accounts that have a parent account that was changed.  Update 
            if (changedAccountIds.size() > 0){
                list<Account> childAccountsToUpdate = new list<Account>();
                childAccounts = [select id, parentid, Account_Classification__c from account where parentid in :changedAccountIds];
                for (Account act : childAccounts ){
                    if (trigger.newmap.containsKey(act.parentid)){
                        act.Account_Classification__c = trigger.newmap.get(act.Parentid).Account_Classification__c;
                        childAccountsToUpdate.add(act);
                    }
                }
                update childAccountsToUpdate;
            }
            
            System.debug('Acct Set - ' + acctSet);
                
            // Account Set that needs to be updated
            if (acctSet.size()>0)
            {
                if (RyderGlobalVariables.IS_TEST == false)
                    updateCompanyFuture.updateCompanyOnRyder_future(acctSet);
            }
        }   
    }
}