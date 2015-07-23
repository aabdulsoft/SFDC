public with sharing class OppChangeForecast_Controller
{
	private Set<ID> sOppIds = new Set<ID>();
	public List<Opportunity> lOpp {get; set;}
	public String sRetURL = '';
	public OppChangeForecast_Controller(ApexPages.StandardSetController Control)
	{
		sRetURL = ApexPages.currentPage().getParameters().get('retURL');		
		List<Opportunity> lSelectedOpp = Control.getSelected();
		if(lSelectedOpp != null && lSelectedOpp.size() > 0)
		{
			for(Opportunity Opp : lSelectedOpp)
			{
				sOppIds.add(Opp.Id);
			}
			if(sOppIds.size() > 0)
			{
				lOpp = [select Id, Name, Owner.Name, AccountId, Account.Name, EST_DEAL_VAL__c, 
						Included_in_Monthly_Forecast__c, Included_in_Quarterly_Forecast__c, OwnerId, 
						Description, NextStep, StageName from Opportunity where Id in : sOppIds];
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