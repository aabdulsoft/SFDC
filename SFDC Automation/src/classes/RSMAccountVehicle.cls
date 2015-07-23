/****************************************************************************
 *  Date            Name          Description
 * --------   --------------    ----------------
 * 1/24/2014    Saad Wali Jaan    RydeSmart Vehicle Data Visibility on Accounts page        
 ****************************************************************************/


/*
* This class is defined to be a controller to the page RydeSmartVehicles page
*/

public with sharing class RSMAccountVehicle 
{
    //public List<Vehicle__c> accountRelatedVehicle {get;set;}
   
    public Account accountInfo {set; get;}
    
    public String searchCriteriaVehicle{get; set;}
    public String searchCriteriaCompany {get;set;}
    public String vehicleQuery {get;set;}
    
    public String sortOrder {get;set;}
    public String sortField {get;set;}
    
    public ApexPages.StandardSetController stdVehicleController {get;set;}
    
    public List<Vehicle__c> getPageVehicles()
    {
        return stdVehicleController.getRecords();
    }
    
    public RSMAccountVehicle(ApexPages.StandardController stdController) 
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
            searchCriteriaCompany = accountInfo.id;
        }
        searchVehicles();
    }
    
    public void searchVehicles()
    {
        searchCriteriaVehicle = (searchCriteriaVehicle!=null)?searchCriteriaVehicle:'';
        stdVehicleController = new ApexPages.StandardSetController(new List<Vehicle__c>());
        
        vehicleQuery = 'SELECT id, EXPIRATION_DATE__c, In_Service_Date__c, Name, Out_Service_Date__c, PRODUCT_LINE__c, ';
        vehicleQuery += 'Product_Name__c, SAM_CLASS__c, Unit__c FROM Vehicle__c where Account__c =\''+searchCriteriaCompany+'\'';
        vehicleQuery += ' and RSM_Service_Level__c != \'\'';
        if (searchCriteriaVehicle!='')
        {
            searchCriteriaVehicle = '\''+searchCriteriaVehicle+'\'';
            searchCriteriaVehicle = searchCriteriaVehicle.replace(' ','');
            searchCriteriaVehicle = searchCriteriaVehicle.replace(',','\',\''); 
            vehicleQuery += ' and Unit__c IN (' +searchCriteriaVehicle +')';
            searchCriteriaVehicle = searchCriteriaVehicle.replace('\'','');             
        }
        
        vehicleQuery += ' order by ' + sortField + ' ' + sortOrder;
        stdVehicleController = new ApexPages.StandardSetController(Database.getQueryLocator(vehicleQuery));
        stdVehicleController.setpageSize(10);
    }
}