/**
* 
*   updateCompanyFuture trigger class update if the values for the company has 
*   changed and notifies and updates accounts using webservice
*
*   Author           |Author-Email                      |Date       |Comment
*   -----------------|----------------------------------|-----------|--------------------------------------------------
*   Vishal Patel     |vishal@comitydesigns.com          |12.17.2010 |First draft
*
*/
public with sharing class updateCompanyFuture 
{
    // Update the companies using future method
    @Future(callout=true)
    public static void updateCompanyOnRyder_future(Set<Id> accountIds)
    {
        updateCompanyOnRyder(accountIds);
    }
    
    // Update Companies
    public static void updateCompanyOnRyder(Set<Id> accountIds)
    {
        // Accounts that we need to update
        Account[] accounts = [SELECT Name, Type, LesseeNo__c, Industry, CompanyTypeID__c, CustomerTypeID__c, CustProspectID__c, Legal_Site_Duns__c, Site_Duns__c, SIC, DUNS_HQ__c, Domestic_Ultimate_DUNS__c, Global_Ultimate_DUNS__c, 
        					  NationalCustFlag__c, Account_Classification__c,CO_SEGMENT__c, Equifax_No__c, Legal_Equifax_No__c, Equifax_Street1__c, Equifax_Street2__c, Equifax_City__c, Equifax_State__c, Equifax_Country__c, 
        					  Equifax_Zip_Postal_Code__c, Equifax_Phone__c, Equifax_Fax__c, Equifax_Email__c, Equifax_Company_Name__c, LastModifiedBy.Ride_ID__c, SIC_Code__r.Name FROM Account WHERE Id IN :accountIds];
        
        // Create criteria to send request to Ryder WSDL
        updateCompany.CompanyUpdateRequest requestCriteria = new updateCompany.CompanyUpdateRequest();

        // Go through the accounts and update using the soap method
        for (Account account : accounts)
        {
            requestCriteria.CompanyName = account.Name;
            requestCriteria.CompanyType = account.CompanyTypeID__c;
            requestCriteria.LesseNum = account.LesseeNo__c;
            //Saad Wali Jaan changed 02/07/2012 - Use Legal Site Duns as Legal Site Duns & Site Duns as Site Duns
            //Julio Gonzalez changed 02/04/2011 - Use Legal Site Duns as Site Duns
            requestCriteria.LegalSiteDuns = account.Legal_Site_Duns__c;
            requestCriteria.SiteDuns = account.Site_Duns__c;
            requestCriteria.HQDuns = account.DUNS_HQ__c;
            requestCriteria.UltimateDuns = account.Domestic_Ultimate_DUNS__c;
            requestCriteria.IndustryType = account.Industry;
            requestCriteria.CustomerType = account.CustomerTypeID__c;
            // 12/22/2011- Neelima- replaced sic with SIC_Code__r.Name
            requestCriteria.SICCode = account.SIC_Code__r.Name;
            requestCriteria.CompanySegment = account.CO_SEGMENT__c;
            if (account.CustProspectID__c != null)
                requestCriteria.Id = Integer.valueOf(account.CustProspectID__c);
           // requestCriteria.NationalCustFlag = account.NationalCustFlag__c;
           // 03/18 , Neelima-- replaced NationalCustFlag with account classification
           requestCriteria.NationalCustFlag = account.Account_Classification__c=='National' ? true:false;
            
            //MPH changed 1/20/2011 - requested by Neelima
            //requestCriteria.LastUpdateUser = account.LastModifiedBy.Name;
            requestCriteria.LastUpdateUser = account.LastModifiedBy.Ride_ID__c;
            
            //Added By Saad Wali Jaan. 07/11/2012- Changes for Equifax fields
            requestCriteria.EquifaxNo = account.Equifax_No__c;
            requestCriteria.LegalEquifaxNo = account.Legal_Equifax_No__c;
            requestCriteria.EquifaxStreet1 = account.Equifax_Street1__c;
            requestCriteria.EquifaxStreet2 = account.Equifax_Street2__c;
            requestCriteria.EquifaxCity = account.Equifax_City__c;
            requestCriteria.EquifaxState = account.Equifax_State__c;
            requestCriteria.EquifaxCountry = account.Equifax_Country__c;
            requestCriteria.EquifaxZipCode = account.Equifax_Zip_Postal_Code__c;
            requestCriteria.EquifaxPhone = account.Equifax_Phone__c;
            requestCriteria.EquifaxFax = account.Equifax_Fax__c;
            requestCriteria.EquifaxEmail = account.Equifax_Email__c;
            requestCriteria.EquifaxCompanyName = account.Equifax_Company_Name__c;

            UpdateCompany.UpdateCompanySoap companySoap = new UpdateCompany.UpdateCompanySoap();
            UpdateCompany.CRMCredential credential = new UpdateCompany.CRMCredential();
            //credential.UserName = UserInfo.getUserName();
            //credential.Password = 'passw0rd';
            //credential.SecurityToken = 'x9hJscMUilGopqHFAZETe0Glm';
            
            system.debug('requestCriteria.LegalEquifaxNo = ' + requestCriteria.LegalEquifaxNo);  
            system.debug('account.Legal_Equifax_No__c = ' + account.Legal_Equifax_No__c);
            
            credential.UserName = '';
            credential.Password = '';
            credential.SecurityToken = '';
            try
            {
                
                // Make a soap request
                UpdateCompany.DCCompanyUpdate updateCompanyInfo;
                
                if (RyderGlobalVariables.IS_TEST==false)
                {
                    System.debug('++++++++requestCriteria: '+ requestCriteria);
                    updateCompanyInfo = companySoap.ProcessRequest(credential, requestCriteria);
                    System.debug('+++++++++updateCompanyInfo: ' + updateCompanyInfo);
                    //Check if there was a success
                    if (updateCompanyInfo != null)
                    {
                        String companyId = String.valueOf(updateCompanyInfo.ID);        
                    }
                }
            }
            catch(Exception ex)
            {
                System.debug('Error while updating the company: ' + ex.getMessage());
            }
        }
                
    }

}