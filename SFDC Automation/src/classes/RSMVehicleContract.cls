/************************************************************************************
 *  Date            Name          Description
 * --------   --------------    ----------------
 * 1/24/2014    Saad Wali Jaan    RydeSmart Contracts Data Visibility on Vehicle page        
 *************************************************************************************/

/*
* This class is defined to be a controller to the page RydeSmartContract page
*/

public with sharing class RSMVehicleContract
{
    public List<RSM_Contract__c> vehicleRelatedActiveContracts {get;set;}
    public List<RSM_ContractDetail__c> vehicleRelatedContractDetails {get;set;}
    public Vehicle__c vehicleInfo {set; get;}
    public id ContractId {set; get;}
    
    public String sortOrder {get;set;}
    public String sortField {get;set;}
    
    public ApexPages.StandardSetController stdActiveContractController {get;set;}
    
    public List<RSM_Contract__c> getPageActiveContracts()
    {
        return stdActiveContractController.getRecords();
    }
    
    public RSMVehicleContract(ApexPages.StandardController stdController) 
    {
        this.vehicleInfo = (Vehicle__c)stdController.getRecord();
        system.debug('Saad - vehicleInfo = ' + vehicleInfo); 
        init();
    }
       
    public void init()
    {
        if(vehicleInfo.Id!=null)
        {
        	vehicleRelatedContractDetails = new List<RSM_ContractDetail__c>();
            vehicleRelatedContractDetails = [select Contract_Number__c from RSM_ContractDetail__c where Unit_Number__c=: vehicleInfo.id and Is_Current__c = true limit 1];
            system.debug('Saad - vehicleRelatedContractDetails = ' + vehicleRelatedContractDetails);
            ContractId = vehicleRelatedContractDetails[0].Contract_Number__c;
            system.debug('Saad - ContractId = ' + ContractId);
        }
        searchActiveContracts();
    }
    
    public void searchActiveContracts()
    {
        vehicleRelatedActiveContracts = new List<RSM_Contract__c>();
        stdActiveContractController = new ApexPages.StandardSetController(new List<RSM_Contract__c>());
        stdActiveContractController = new ApexPages.StandardSetController(Database.getQueryLocator(
        [Select r.Contract_Number__c, r.CreatedBy__c, r.CreatedDate__c, r.Document_Type_Name__c, r.Effective_Date__c, r.Id, r.Lessee__c, r.Lessee_Email__c, r.Name, r.Status_Name__c from RSM_Contract__c r WHERE id =:ContractId order by Effective_Date__c desc]));
        stdActiveContractController.setpageSize(10);
    }
}