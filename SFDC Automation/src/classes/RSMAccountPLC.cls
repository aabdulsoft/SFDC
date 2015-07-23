/****************************************************************************
 *  Date            Name          Description
 * --------   --------------    ----------------
 * 1/24/2014    Saad Wali Jaan    RydeSmart PreLaunchChecklist Data Visibility on Accounts page        
 ****************************************************************************/
/*
* This class is defined to be a controller to the page PreLaunchChecklist page
*/

public with sharing class RSMAccountPLC
{
    //public List<RSM_Pre_Launch_Checklist__c> accountPreLaunchChecklist {get;set;}
       
    public Account accountInfo {set; get;}
    
    public String sortOrder {get;set;}
    public String sortField {get;set;}
    
    public ApexPages.StandardSetController stdPreLaunchChecklist {get;set;}
    
    public List<RSM_Pre_Launch_Checklist__c> getPagePreLaunchChecklist()
    {
        return stdPreLaunchChecklist.getRecords();
    }

    public RSMAccountPLC(ApexPages.StandardController stdController) 
    {
        this.accountInfo = (Account)stdController.getRecord(); 
        sortField = 'Name';
        sortOrder = 'ASC';
        init();
    }
    
    public void init()
    {
        if(accountInfo.Id!=null)
        {
            accountInfo = [select id, LesseeNo__c from Account where id=: accountInfo.id ];

        }
        searchPreLaunchChecklist();
    }
    
    public void searchPreLaunchChecklist()
    {
        //accountPreLaunchChecklist = new List<RSM_Pre_Launch_Checklist__c>();
        stdPreLaunchChecklist = new ApexPages.StandardSetController(new List<RSM_Pre_Launch_Checklist__c>());
        stdPreLaunchChecklist = new ApexPages.StandardSetController(Database.getQueryLocator(
        [Select r.Account__c, r.Completed__c, r.Description__c, r.End_Date__c, r.Id, r.Item_Number__c, r.Name, r.Start_Date__c from RSM_Pre_Launch_Checklist__c r WHERE Account__c =:accountInfo.id order by r.Item_Number__c]));
        

        /*system.debug('Saad - stdPreLaunchChecklist = ' + stdPreLaunchChecklist);
        completed = stdPreLaunchChecklist.Completed__c;
        startDate = stdPreLaunchChecklist[0].Start_Date__c;
        endDate = stdPreLaunchChecklist[0].End_Date__c;
        system.debug('Saad - completed = ' + completed);
        system.debug('Saad - startDate = ' + startDate);
        system.debug('Saad - endDate = ' + endDate);*/
        
    }
    
    public PageReference saveRecord(){
        
        stdPreLaunchChecklist.save();
        return null;
    }
}