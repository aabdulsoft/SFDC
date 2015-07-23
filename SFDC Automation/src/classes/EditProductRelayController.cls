public with sharing class EditProductRelayController {

    public OpportunityLineItem oli;
    private String opptyId {set; get;}        
    public EditProductRelayController(ApexPages.StandardController stdController) 
    {
        // Retrieve oppty id
        this.oli = (OpportunityLineItem)stdController.getRecord();
        this.oli = [select id, OpportunityId from OpportunityLineItem where id=: this.oli.Id];
        this.opptyId = this.oli.OpportunityId;
    }
    
    public PageReference init()
    {
        Opportunity oppty = [Select o.Id, o.account.CustProspectID__c, o.Name, o.CloseDate, o.StageName From Opportunity o where o.Id =:this.opptyId];
        PageReference pageRef = null;
       SavePoint sp = Database.setSavepoint();
       try {
           if (validateOppty(oppty)) {
	            // Page reference variable
	            pageRef = new PageReference('/' + this.oli.Id + '/e&retURL=/' + this.oli.Id);
	            pageRef.setRedirect(true);
	        } 
        } catch (Exception ex) {
                ApexPages.Message msgError = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());  
                ApexPages.addMessage(msgError);
       } finally {
            Database.rollback(sp);
       }
        return pageRef;
    }
    
    private boolean validateOppty(Opportunity oppty) {
        Boolean result = true;
        upsert oppty;
        return result;
    }
    
    public PageReference backToOpportunity() {
        PageReference page = new PageReference('/' + this.opptyId);
        return page;
    }
}