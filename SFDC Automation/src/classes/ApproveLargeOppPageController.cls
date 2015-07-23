/****************************************************************************
 *   Date            Name                 Description
 * --------        --------------       ----------------
 * 6/10/2015       Saad Wali Jaan       For displaying Booked Opportunities with More than 10 Units    
 ****************************************************************************/
/*This class is defined to be a controller to the page ApproveLargeOppPage page*/
public with sharing class ApproveLargeOppPageController
{
    private String userId;
    integer intApproveLargeOppCount = integer.valueof(LABEL.ApproveLargeOppCount);
    date dtApproveLargeOppDate = Date.valueOf(LABEL.ApproveLargeOppDate); 

    string strApproveLargeOppStage = LABEL.ApproveLargeOppStage;

    List<string> lstApproveLargeOppStage = new List<string>(strApproveLargeOppStage.remove('\'').split(','));

    //List<string> lstApproveLargeOppStage = new List<string>(strApproveLargeOppStage.split(','));    
        
    public List<Opportunity> lstOpportunity {get;set;}
    
    public ApproveLargeOppPageController(ApexPages.StandardController stdController) 
    {
        System.debug('ALOPC0.0 = ' + strApproveLargeOppStage);
        system.debug('ALOPC0.1 - lstApproveLargeOppStage = ' + lstApproveLargeOppStage );
        system.debug('ALOPC0.2');    
        this.userId = ApexPages.currentPage().getParameters().get('id');
        GetOpportunities();
    }
    
    public void GetOpportunities()
    {
        system.debug('ALOPC0.3');
        lstOpportunity = [select o.Id, o.Name, o.Actual_Close_Date__c, o.AccountId, o.Account.Name, o.Approved__c, o.Approved_Date__c, o.ext_pipeline_id__c, 
                          o.Reason_Won_Lost__c, o.Deal_lost_to_Won_from_whom__c, o.Who_is_the_main_incumbent__c, o.CMPT_ID__c, o.Local_Provider_Name__c,                            
                          o.StageName, o.Num_of_vehicles__c, o.Owner.Name, o.Owner.ManagerId from Opportunity o where o.Owner.ManagerId =:userId and 
                          StageName in: lstApproveLargeOppStage and Num_of_vehicles__c >=: intApproveLargeOppCount and Actual_Close_Date__c >: dtApproveLargeOppDate  
                          and Approved__c = NULL order by Actual_Close_Date__c];
    }
    public void updateOpportunity()
    {
        system.debug('ALOPC0.4');
        List<Opportunity> lstOpportunityUpdate = new List<Opportunity>();
        try
        {
            system.debug('ALOPC5');
            for(Opportunity ops: lstOpportunity )
            {
                if(ops.Approved__c != null)
                {
                    system.debug('ALOPC6');
                    ops.Approved_Date__c = system.today();
                    lstOpportunityUpdate.add(ops);
                }            
            }
            if(lstOpportunityUpdate.size() > 0)
            {
                system.debug('ALOPC7');
                update lstOpportunityUpdate;
                GetOpportunities();                
            }
            else
            {
                system.debug('ALOPC8');
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Please select at-least one record from List view!');
                apexpages.addmessage(msg);
            }
        }
        catch(exception ex)
        {
            
        }
    }
}