/************************************************************************************
 *  Date            Name          Description
 * --------   --------------    ----------------
 * 1/24/2014    Saad Wali Jaan    RydeSmart Contracts Data Visibility on Accounts page        
 *************************************************************************************/

/*
* This class is defined to be a controller to the page RydeSmartContract page
*/

public with sharing class RSMAccountContracts
{
    public List<RSM_Contract__c> accountRelatedAllContracts {get;set;}
    public Account accountInfo {set; get;}
    
    public String sortOrder {get;set;}
    public String sortField {get;set;}
    
    public ApexPages.StandardSetController stdAllContractController {get;set;}
    
    public List<RSM_Contract__c> getPageAllContracts()
    {
        return stdAllContractController.getRecords();
    }
    
    public RSMAccountContracts(ApexPages.StandardController stdController) 
    {
        this.accountInfo = (Account)stdController.getRecord(); 
        sortField = 'Name';
        sortOrder = 'ASC';
        init();
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
        init();
    }
    
    public void init()
    {
        if(accountInfo.Id!=null)
        {
            accountInfo = [select id, LesseeNo__c from Account where id=: accountInfo.id ];
        }
        searchAllContracts();
    }
    
    public void searchAllContracts()
    {
        accountRelatedAllContracts = new List<RSM_Contract__c>();
        stdAllContractController = new ApexPages.StandardSetController(new List<RSM_Contract__c>());
        stdAllContractController = new ApexPages.StandardSetController(Database.getQueryLocator(
        [Select r.CreatedBy__c, r.CreatedDate__c, r.Document_Type_Name__c, r.Effective_Date__c, r.Id, r.Lessee__c, r.Lessee_Email__c, r.Name, r.Status_Name__c from RSM_Contract__c r WHERE Lessee__c =:accountInfo.LesseeNo__c order by Effective_Date__c desc]));
        stdAllContractController.setpageSize(10);
    }
}