/****************************************************************************
 *  Date            Name          Description
 * --------   --------------    ----------------
 * 12/1/2012    Swetha Mandadi    SFDC Visibility Enchanement        
 ****************************************************************************/


/*
 * This class is defined to be a controller to the page 'Duplicaterecordscheck.Page'
 */

public class Duplicaterecordscheck
{
    public List<Account> leadRelatedAccount {get;set;}
    //public List<Contact> leadRelatedContact {get;set;}
    public List<Contact> leadRelatedContactbyemail {get;set;}
    public List<Lead> MatchingLeads {get;set;}
    public Lead leadInfo {get;set;}

    public String searchCriteriaCompany {get;set;}
    public String searchCriteriaFirstName {get;set;}
    public String searchCriteriaLastName {get;set;}
    public String searchCriteriaEmail {get;set;}
    public String searchCriteriaState {get;set;}
    public String searchCriteriaCountry {get;set;}
    public String searchCriteriaCity {get;set;}  
    
    public String accountQuery {get;set;}
    public String contactQuery {get;set;}
    public String leadQuery {get;set;}
    public String searchQuery{get;set;}
    public String sortOrder {get;set;}
    public String sortField {get;set;}
    public String accIdField {get;set;}
   

    public ApexPages.StandardSetController stdAccountController {get;set;}
    public ApexPages.StandardSetController stdContactController {get;set;}
    public ApexPages.StandardSetController stdContactControllerMatchingEmail {get;set;}
    public ApexPages.StandardSetController stdLeadController {get;set;}
    public ApexPages.StandardSetController stdLeadControllerMatchingEmail {get;set;}
    
    public List<Account> getPageAccounts()
    {
        return stdAccountController.getRecords();
    }
    
    public List<Contact> getPageContacts()
    {
        return stdContactController.getRecords();
    }
    
    public List<Contact> getpageContactsMatchingEmail()
    {
        return stdContactControllerMatchingEmail.getRecords();
    }
    
    public List<Lead> getPageLeads()
    {
        return stdLeadController.getRecords();
    }
    
    public List<Lead> getpageLeadsMatchingEmail()
    {
        return stdLeadControllerMatchingEmail.getRecords();
    }
    
    public void changeOrder()
    {
        if(sortOrder == 'ASC')
        {
            sortOrder = 'DESC';
        }
        else
        {
            sortOrder = 'ASC';
        }
        searchAccounts();
    }
    
    public Duplicaterecordscheck(ApexPages.StandardController controller) 
    {
        leadInfo = (Lead)controller.getRecord();
        //stdAccountController = new ApexPages.StandardSetController(new List<Account>());
        sortField = 'Name';
        sortOrder = 'ASC';
        accIdField = NULL;
        reset();
    }
    
    /**
     * This method is used to query the accounts dynamically  based on Company Name and Biling State and Billing City
     **/
    public void searchAccounts()
    {
        leadRelatedAccount = new List<Account>();
        stdAccountController = new ApexPages.StandardSetController(new List<Account>());
        accountQuery = 'select id, Is_Selected__c, Name, Type, Account_Classification__c, Account_Type__c, Owner.Alias, Owner.Name, Owner.Profile.Name, Owner.Sales_Territory_Code__c, BillingState, BillingCity, Central_Decisionmaking__c, Last_Sales_Interaction__c, NCA__c from Account';
        String tempAccountName;
        
        if(searchCriteriaCompany!='')
        {
            accountQuery += ' where';
            tempAccountName = '%'+normalizeCompanyName(searchCriteriaCompany)+'%';
            accountQuery += ' Name Like: tempAccountName';
            
            if(searchCriteriaState!='')
            {                  
                accountQuery += ' AND BillingState =: searchCriteriaState';
            }
            if(searchCriteriaCity!='')
            {
                accountQuery += ' AND BillingCity =: searchCriteriaCity';
            }
            accountQuery += ' order by '+sortField+' '+sortOrder;
            //accountQuery += ' limit 50';
            stdAccountController = new ApexPages.StandardSetController(Database.getQueryLocator(accountQuery));
            stdAccountController.setpageSize(10);
        } 
    }    
   
    
    /**
     * This method is used to query the contacts dynamically based on First Name or Last Name or Email 
     **/
    private void searchContacts()
    {
        List<Contact> leadRelatedContacts = new List<Contact>();
        stdContactController = new ApexPages.StandardSetController(leadRelatedContacts);
        stdContactControllerMatchingEmail = new ApexPages.StandardSetController(new List<Contact>());
   
        // fetching contacts with matching email Id
        if(searchCriteriaEmail!='')
        {
            contactQuery = 'Select id, Name, Account.Name, FirstName, Lastname, Email, Owner.Alias, Owner.Name, Owner.Profile.Name from Contact where Email =: searchCriteriaEmail';
            if(!leadRelatedContacts.isEmpty())
            {
                contactQuery += ' and id not in: leadRelatedContacts';
            }
            contactQuery += ' limit 50';
            system.debug('searchCriteriaEmail= '+searchCriteriaEmail);
            system.debug('Contacts 1= '+contactQuery);
            stdContactControllerMatchingEmail = new ApexPages.StandardSetController(Database.getQueryLocator(contactQuery));
            stdContactControllerMatchingEmail.setpageSize(10);
        }
        else
        {
            contactQuery = 'Select id, Name, Account.Name, FirstName, Lastname, Email, Owner.Alias, Owner.Name, Owner.Profile.Name from Contact';
            
            String tempFirstName;
            String tempLastName;
            String tempAccount;
            String tempCity;
            
            
            if(searchCriteriaCompany!='')
            {
                
                contactQuery += ' where';
                tempAccount = '%'+normalizeCompanyName(searchCriteriaCompany)+'%';
                contactQuery += ' Account.name Like: tempAccount';
                
                if(searchCriteriaFirstName!='')
                {
                    tempFirstName = '%'+searchCriteriaFirstName+'%';
                    contactQuery += ' AND';
                    contactQuery += ' FirstName Like: tempFirstName';
                    system.debug('Contacts 2= '+contactQuery);
                }
                if(searchCriteriaLastName!='')
                {
                    contactQuery += ' AND';
                    tempLastName = '%'+searchCriteriaLastName+'%';
                    contactQuery += ' LastName Like: tempLastName';
                    system.debug('Contacts 3= '+contactQuery);
                }
                if(searchCriteriaCity!='')
                {
                    contactQuery += ' AND';
                    tempCity = '%'+searchCriteriaCity+'%';
                    contactQuery += ' MailingCity Like: tempCity'; 
                    system.debug('Contacts 4= '+contactQuery);             
                }
            }
            else
            if(searchCriteriaFirstName!='')
            {
                contactQuery += ' where';
                tempFirstName = '%'+searchCriteriaFirstName+'%';
                contactQuery += ' FirstName Like: tempFirstName';
                system.debug('Contacts 5= '+contactQuery);                
                
                if(searchCriteriaLastName!='')
                {
                    contactQuery += ' AND';
                    tempLastName = '%'+searchCriteriaLastName+'%';
                    contactQuery += ' LastName Like: tempLastName';
                    system.debug('Contacts 6 '+contactQuery);
                }
                if(searchCriteriaCity!='')
                {
                    contactQuery += ' AND';
                    tempCity = '%'+searchCriteriaCity+'%';
                    contactQuery += ' MailingCity Like: tempCity'; 
                    system.debug('Contacts 7= '+contactQuery);             
                }
            }
            else
            if(searchCriteriaLastName!='')
            {
                contactQuery += ' where';
                tempLastName = '%'+searchCriteriaLastName+'%';
                contactQuery += ' LastName Like: tempLastName';
                system.debug('Contacts 8= '+contactQuery);                
                if(searchCriteriaCity!='')
                {
                    contactQuery += ' AND';
                    tempCity = '%'+searchCriteriaCity+'%';
                    contactQuery += ' MailingCity Like: tempCity'; 
                    system.debug('Contacts 9= '+contactQuery);             
                }
            }
            else
            if(searchCriteriaCity!='')
            {
                contactQuery += ' where';
                tempCity = '%'+searchCriteriaCity+'%';
                contactQuery += ' MailingCity Like: tempCity'; 
                system.debug('Contacts 10= '+contactQuery);             
            }       
            contactQuery += ' limit 50';
            system.debug('Contacts 11 '+contactQuery);
            leadRelatedContacts = Database.query(contactQuery);
            //stdContactController = new ApexPages.StandardSetController(Database.getQueryLocator(contactQuery));
            stdContactController = new ApexPages.StandardSetController(leadRelatedContacts);
            stdContactController.setpageSize(10);
            
        }
    }
        
    /**
     * This method is used to query the Leads dynamically based on Company name.
     
     **/
    private void searchLeads()
    {
        matchingLeads = new List<Lead>();
        stdLeadController = new ApexPages.StandardSetController(matchingLeads);
        LeadQuery = 'Select id,Name,Email,Phone,Company,Status,City,State,country,Owner.Alias, Owner.Name, Owner.Profile.Name from Lead';
        String tempAccountName;
        String tempCity;
               
        if(searchCriteriaCompany!='' )
        {
            LeadQuery += ' where';
            tempAccountName = '%'+normalizeCompanyName(searchCriteriaCompany)+'%';
            LeadQuery += ' Company Like: tempAccountName';
            accountQuery += ' Company Like: CentralDecisionmaking';
                      
            if(searchCriteriaCity!='')
            {
                LeadQuery += ' AND';
                tempCity = '%'+searchCriteriaCity+'%';
                LeadQuery += ' City Like: tempCity';              
            }  
            
            //leadQuery += ' limit 50'; // need only 10 records to display but querying 50 
            matchingLeads = Database.query(leadQuery);
            stdLeadController = new ApexPages.StandardSetController(matchingLeads);
            stdLeadController.setpageSize(10);
        }
        if(searchCriteriaEmail!=null )
        {
            leadQuery = 'Select id,Name,Email,Title,Phone,Company,Status,City,State,country,Owner.Alias, Owner.Name, Owner.Profile.Name from Lead where Email =: searchCriteriaEmail AND Email !=null';
            if(!matchingLeads.isEmpty())
            {
                leadQuery += ' and id not in: matchingLeads';
            }
            //leadQuery += ' limit 50';
            stdLeadControllerMatchingEmail = new ApexPages.StandardSetController(Database.getQueryLocator(leadQuery));
            stdLeadControllerMatchingEmail.setpageSize(10);
        }
    }
   
    public void reset()
    {
        if(leadInfo.Id!=null)
        {
            leadInfo = [select id, Name, Company, FirstName, LastName, Email, City, State, Country,Owner.alias from Lead where id=: leadinfo.id ];
        }
        searchCriteriaCompany = (leadInfo.Company!=null)?leadInfo.Company:'';
        searchCriteriaFirstName = (leadInfo.FirstName!=null)?leadInfo.FirstName:'';
        searchCriteriaLastName = (leadInfo.LastName!=null)?leadInfo.LastName:'';
        searchCriteriaEmail = (leadInfo.Email!=null)?leadInfo.Email:'';
        searchCriteriaCity = (leadInfo.City!=null)?leadInfo.City:'';
        searchCriteriaState = (leadInfo.State!=null)?leadInfo.State:'';
        searchCriteriaCountry =(leadInfo.Country!=null)?leadInfo.Country:'';
       
        searchAccounts();
        searchContacts();
        searchLeads();
    }
    
    
    public void searchData()
    {
        if(searchCriteriaCompany.length()>0 && searchCriteriaCompany.length()<2)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Company Name should have more than 2 characters'));
        }
        if(searchCriteriaFirstName.length()>0 && searchCriteriaFirstName.length()<2)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'First Name should have more than 2 characters'));
        }
        if(searchCriteriaLastName.length()>0 && searchCriteriaLastName.length()<2)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Last Name should have more than 2 characters'));
        }
        if(!ApexPages.hasMessages())
        {
            searchAccounts();
            searchContacts();
            searchLeads();
        }
    }
    
    public PageReference GetDataForTask() {
           
        List<Account> lstLocalAcc = new List<Account>();
        List<Account> lstNationalAcc = new List<Account>();
        List<String> lstST = new List<String>();
        List<Sales_Territory__c> lstSTObj = new List<Sales_Territory__c>();
        Map<String, id> mapST = new Map<String, id>();
        List<User> lstSalesAdmin = [Select id from User where name = 'Sales Admin' limit 1];
        leadRelatedAccount = stdAccountController.getRecords();
        Boolean dontSave = true;
        Id userTskOwner;
        
        for (Account acc: leadRelatedAccount)
        {
            if (acc.Is_Selected__c == true)
            {
                dontSave = false;
                if (acc.Account_Classification__c == 'Local')
                {
                    lstLocalAcc.add(acc);
                }
                else if (acc.Account_Classification__c == 'National')
                {
                    lstNationalAcc.add(acc);
                }
            }
        }   
        
        if(dontSave == true)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.error, 'Please choose atleast one Account to get Access.');
            ApexPages.addmessage(mymsg);
        }
        else
        {
            if (lstLocalAcc.size() > 0)
            {                
                for (Account lclAcct: lstLocalAcc){
                    lstST.add(lclAcct.Owner.Sales_Territory_Code__c);
                }
                
                lstSTObj = [Select Sales_Territory_Code__c, SAC__c from Sales_Territory__c where Sales_Territory_Code__c in :lstST];
                
                for (Sales_Territory__c st: lstSTObj){
                    if(!mapST.containskey(st.Sales_Territory_Code__c)) mapST.put(st.Sales_Territory_Code__c, st.SAC__c);
                }
                system.debug('Saad1 = ' + mapST);
                for (Account lAcct: lstLocalAcc){
                    
                    if((mapST.get(lAcct.Owner.Sales_Territory_Code__c) == null)||(lAcct.Owner.Sales_Territory_Code__c == null)) 
                    {
                        system.debug('Saad2');
                        userTskOwner = lstSalesAdmin[0].id;
                    }
                    else
                    {
                        system.debug('Saad3 = ' + mapST.get(lAcct.Owner.Sales_Territory_Code__c));                    
                        userTskOwner = mapST.get(lAcct.Owner.Sales_Territory_Code__c);
                    }
                    CreateTask(userTskOwner, lAcct.Id, lAcct.Name);
                }
            }
            
            if (lstNationalAcc.size() > 0)
            {            
                for (Account ntlAcct: lstNationalAcc)
                {
                    if (ntlAcct.NCA__c == NULL)
                    {
                        userTskOwner = lstSalesAdmin[0].id;
                    }
                    else
                    {
                        userTskOwner = ntlAcct.NCA__c;
                    }
                    CreateTask(userTskOwner, ntlAcct.Id, ntlAcct.Name);
                }
            }
        }
        return NULL;
    }
    
    public void CreateTask(id userTskOwner, Id AccountId, string AccName){
        
        //Declare Date
        date myDate = System.Today();
        Map<String, Id> taskRecordTypes= CommonFunctions.getRecordTypeMap('Task');
        
        Task T = new Task();
        T.RecordTypeId = taskRecordTypes.get('Ryder_Task');
        T.OwnerId = userTskOwner;
        T.WhatId = AccountId; 
        T.Subject = 'Request to be added to account team';
        T.Description = UserInfo.getName() + ' has been requested to be added to the account team for ' + AccName;
        T.ActivityDate = myDate.addDays(1);
        T.Status = 'Not Started';
        T.Priority = 'High';
        T.Type = 'Other';
        Insert T;
    }
    
    private string normalizeCompanyName(string aValue) 
    {
        if(aValue!=null && !aValue.trim().equals(''))
        {
            aValue = aValue.toLowerCase();
            aValue = aValue.replace('corporation','');
            aValue = aValue.replace('incorporated','');
            aValue = aValue.replace('limited partnership','');
            aValue = aValue.replace('limited liability','');
            aValue = aValue.replace('limited company','');
            aValue = aValue.replace('limited','');
            aValue = aValue.replace('cooperative','');
            aValue = aValue.replace('non-profit-organization','');
            aValue = aValue.replace('ltd.,','');
            aValue = aValue.replace('llc.,','');
            aValue = aValue.replace('corp.,','');
            aValue = aValue.replace('inc.,','');
            aValue = aValue.replace('co.,','');
            aValue = aValue.replace('l.p.,','');
            aValue = aValue.replace('l.l.c.,','');
            aValue = aValue.replace('l.c.,','');
            
            aValue = aValue.replace('ltd.','');
            aValue = aValue.replace('ltd.','');
            aValue = aValue.replace('llc.','');
            aValue = aValue.replace('corp.','');
            aValue = aValue.replace('inc.','');
            aValue = aValue.replace('co.','');
            aValue = aValue.replace('l.p.','');
            aValue = aValue.replace('l.l.c.','');
            aValue = aValue.replace('l.c.','');
            aValue = aValue.replace('ltd.','');
            
            aValue = aValue.replace('co,','');
            aValue = aValue.replace('l.p,','');
            aValue = aValue.replace('l.l.c,','');
            aValue = aValue.replace('l.c,','');
            
            
            aValue = aValue.replace('ltd','');
            aValue = aValue.replace('llc','');
            aValue = aValue.replace('corp','');
            aValue = aValue.replace('inc','');
            aValue = aValue.replace('company','');
            aValue = aValue.replace(',',' ');
            aValue = aValue.replace('.',' ');
            aValue = aValue.replace('  ','');
        }
    return aValue;
    }
      
}