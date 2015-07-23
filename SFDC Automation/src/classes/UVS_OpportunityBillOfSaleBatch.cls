global with sharing class UVS_OpportunityBillOfSaleBatch implements Database.Batchable<SObject>
{
	/*
		Declare a String for Query all the Bill Of Sales History object records 
		where field is Process and Opportunity field is not null on Parent.
		We need to process only those records where Process is true and 
		in the process set Amount and Count on Opportunity record
	*/	
	String query = 'Select u.Parent.OPPORTUNITY__c, u.ParentId, u.OldValue,'
						+ ' u.NewValue, u.Id, u.Field From UVS_Bill_of_Sale__History u where'
						+ ' Field = \'PROCESSED__c\' and'
						+ ' CreatedDate = TODAY and Parent.OPPORTUNITY__c != null';
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		// retrun the Query locator
		return Database.getQueryLocator(query);
	}
	global void execute(Database.BatchableContext BC, List<UVS_Bill_of_Sale__History> lUVS_Bill_of_SaleHistory)
	{
		// Iterate all the history records where value is true and leave the others
		Set<String> sOppIds = new Set<String>();
		for(UVS_Bill_of_Sale__History Obj : lUVS_Bill_of_SaleHistory)
		{
			if(Obj.NewValue == true)
				sOppIds.add(Obj.Parent.OPPORTUNITY__c);
		}
		// there are records found than pass those to other method for processing
		if(sOppIds.size() > 0)
			CalculateOpportunityAmount(sOppIds);
	}
	public void CalculateOpportunityAmount(Set<String> sOppIds)
	{
		List<Opportunity> lOpp = new List<Opportunity>();		
		if(sOppIds.size() > 0)
		{
			// Query all the Bill of Sales records based on the Opportunity Ids
			List<UVS_Bill_of_Sale__c> lBOS = [Select u.SALES_AMOUNT__c, u.OPPORTUNITY__c 
												From UVS_Bill_of_Sale__c u 
												where OPPORTUNITY__c in : sOppIds];
			if(lBOS != null && lBOS.size() > 0)
			{
				// If Bill of Sales records found than add the amount and count the records as well
				for(String OppId : sOppIds)
				{
					Decimal dAmount = 0;
					Integer iCount = 0;
					for(UVS_Bill_of_Sale__c Obj : lBOS)
					{
						if(OppId == Obj.OPPORTUNITY__c)
						{
							if(Obj.SALES_AMOUNT__c != null)
								dAmount += Obj.SALES_AMOUNT__c;
							iCount++;
						}
					}
					// If Bill of Sales record's count is not 0 then set the Amount and Count on Opportunity 
					if(iCount > 0)
					{
						Opportunity Opp = new Opportunity(Id = OppId, EST_DEAL_VAL__c = dAmount, Num_of_vehicles__c = iCount);
						lOpp.add(Opp);
					}
				}
			}
		}
		if(lOpp.size() > 0)
			update lOpp;
	}
	global void finish(Database.BatchableContext BC)
	{
		// there is nothing needs to be done after the process completes
	}
}