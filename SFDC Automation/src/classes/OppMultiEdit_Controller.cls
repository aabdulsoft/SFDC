public with sharing class OppMultiEdit_Controller
{
	private Set<ID> sOppIds = new Set<ID>();
	public List<Opportunity> lOpp {get; set;}
	public String sRetURL = '';
	public OppMultiEdit_Controller(ApexPages.StandardSetController Control)
	{
		sRetURL = ApexPages.currentPage().getParameters().get('retURL');		
		system.debug('Nitin-------------->'+Control.getRecords());
		List<Opportunity> lSelectedOpp = Control.getSelected();
		if(lSelectedOpp != null && lSelectedOpp.size() > 0)
		{
			for(Opportunity Opp : lSelectedOpp)
			{
				sOppIds.add(Opp.Id);
			}
			if(sOppIds.size() > 0)
			{
				lOpp = [select Id, Name, Actual_Close_Date__c, AccountId, Account.Name, 
						Reason_Won_Lost__c, Deal_lost_to_Won_from_whom__c, 
						Customer_100_Ownership__c, CMPT_ID__c, StageName, 
						Was_this_competitor_the_incumbent__c, Local_Provider_Name__c, 
						Notes__c, Who_is_the_main_incumbent__c from Opportunity where Id in : sOppIds];
			}
		}
		else
		{
			apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Please select at-least one record from List view!');
			apexpages.addmessage(msg);
		}
	}
	public void UpdateData()
	{
		try
		{
			update lOpp;
			apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info, 'Records Updated!');
			apexpages.addmessage(msg);
		}
		catch(exception ex)
		{
			apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error, ex.getMessage());
			apexpages.addmessage(msg);
		}
	}
}