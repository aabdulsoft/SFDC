public with sharing class AddProductRelayController {

        
    public AddProductRelayController() 
    {

    }
    
    private String opptyId {set; get;}
    
    public PageReference init()
    {
        this.opptyId = ApexPages.currentPage().getParameters().get('id');
        String multiItemEdit = ApexPages.currentPage().getParameters().get('multiItemEdit');
        if (multiItemEdit == null || multiItemEdit.length() == 0) {
        	multiItemEdit = '0';
        }
        Opportunity oppty = [Select o.Id, o.account.CustProspectID__c, o.Name, o.CloseDate, o.StageName From Opportunity o where o.Id =:this.opptyId];
        PageReference pageRef = null;
        SavePoint sp = Database.setSavepoint();
	   try {
	       if (validateOppty(oppty)) {
		        // Page reference variable
		        if (multiItemEdit == '1') {
		           pageRef = new PageReference('/oppitm/multilineitem.jsp?oppId=' + this.opptyId + '&retURL=/' + this.opptyId);
		        } else {
		           pageRef = new PageReference('/ui/opportunity/SelectSearch?addTo=' + this.opptyId + '&retURL=/' + this.opptyId);
		        }
		        pageRef.setRedirect(true);
	        } 
	   } catch (DMLException ex) {
	   	        ApexPages.Message msgError = new ApexPages.Message(ApexPages.Severity.Error, ex.getDmlMessage(0));  
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