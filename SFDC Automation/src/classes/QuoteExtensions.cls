/**=====================================================================
 * Appirio, Inc
 * Name: QuoteExtensions
 * Created Date: 10-28-2014
 * Created By: Sunil (Appirio)
 * Extension for inline vf page to show warning messsage on Quote
 =====================================================================*/
public with sharing class QuoteExtensions {
	public Quote currentQuote {get;set;}
	public Boolean showMessage{get;set;}
	
	
	public QuoteExtensions(ApexPages.StandardController controller) {
		//initialize the stanrdard controller
		 if (!Test.isRunningTest()) { 
			controller.addFields(new List<String>{'Status', 'Max_Approval_Level__c'});
		 }
    this.currentQuote = (Quote)controller.getRecord();
    showMessage = false;
    if(currentQuote.Max_Approval_Level__c != null && currentQuote.Max_Approval_Level__c > 0
      && currentQuote.Status != 'Approved' && currentQuote.Status != 'Rejected'
      && currentQuote.Status != 'Submitted for BTR Approval' && currentQuote.Status != 'BTR Approved'){
      showMessage = true;
    }
  }
}