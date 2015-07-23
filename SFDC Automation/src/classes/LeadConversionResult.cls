public without sharing class LeadConversionResult {

    // Normal get/set of objects    
    public Lead lead {get; set;}
    public String leadId {get; set;}
    public Account account {get; set;}
    public Account AccChild {get; set;}
    public Contact contact {get; set;}
    public Opportunity opp {get; set;}
    public String accountStatus {get; set;}
    public String contactStatus {get; set;}
    public Boolean isOppFound {get; set;}
    public Boolean ShowChild {get; set;}
    public LeadConversionResult() 
    {
    	AccChild = new Account();
    	ShowChild = false;
    	System.debug(LoggingLevel.INFO, 'Start of LeadConversionResult');
    	//this.lead = (Lead)controller.getRecord();
    	this.leadId = ApexPages.currentPage().getParameters().get('id');
    	this.accountStatus = ApexPages.currentPage().getParameters().get('accountStatus');
    	this.contactStatus = ApexPages.currentPage().getParameters().get('contactStatus');
    	
    	
    	System.debug(LoggingLevel.INFO, 'this.leadId: ' + this.leadId);
    	System.debug(LoggingLevel.INFO, 'this.accountStatus: ' + this.accountStatus);
    	System.debug(LoggingLevel.INFO, 'this.contactStatus: ' + this.contactStatus);
    	init();
    }
    
    private void init() {
      this.lead =[select id, name, isConverted, ConvertedAccountId ,ConvertedContactId, ConvertedOpportunityId  from lead where id =: this.leadId];
    	System.debug(LoggingLevel.INFO, 'this.lead: ' + this.lead);
    	if (lead.IsConverted) {
    		account = [SELECT Id, Name FROM Account where id =: lead.ConvertedAccountId];
    		contact = [select id, name from Contact where id =: lead.ConvertedContactId];
    		if(lead.ConvertedOpportunityId != null){
    		  opp = [select id, name from Opportunity where id =: lead.ConvertedOpportunityId];
    		  isOppFound = true;
    		}
    		else{
    			isOppFound = false;
    		}
    		 List<Account> lAcc = [SELECT Id, Name FROM Account where ParentId =: account.Id];
    		 if(lAcc != null && lAcc.size() == 1)
    		 {
    		 	AccChild = lAcc[0];
    		 	ShowChild = true;
    		 }
    	}
    	
    	System.debug(LoggingLevel.INFO, 'this.account: ' + this.account);
    	System.debug(LoggingLevel.INFO, 'this.contact: ' + this.contact);
    	if (accountStatus != null) {
    		//{NewAccount,MatchFromDnB,ExistingSFDCAcct}
    		if (accountStatus == RyderGlobalVariables.LeadConversionAccountState.ExistingSFDCAcct.name()) {
                accountStatus = 'Existing';
            } else {
            	accountStatus = 'New';
            }
    	}
    	if (contactStatus != null) {
            //{NewContact,ExistingSFDCContact,CreatedContact}
            if (contactStatus == RyderGlobalVariables.LeadConversionContactState.ExistingSFDCContact.name()) {
                contactStatus = 'Existing';
            } else {
                contactStatus = 'New';
            }
        }
        
        
    }
}