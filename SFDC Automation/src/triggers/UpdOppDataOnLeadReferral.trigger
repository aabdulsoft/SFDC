trigger UpdOppDataOnLeadReferral on Lead_Referral__c (after update) {

	if(trigger.isAfter)
    {
        list <Lead_Referral__c> lLeadReferral = new list<Lead_Referral__c>();
	 	
	 	for(Lead_Referral__c lstLeadReferral : trigger.new)
        {
        	system.debug('UODOLRH 0.1 lstLeadReferral = ' + lstLeadReferral.id);
	 		system.debug('UODOLRH 0.2 mapEventOld = ' + trigger.oldMap.get(lstLeadReferral.id).FMS_Opportunity_Name__c);
        	system.debug('UODOLRH 0.3 mapEventNew = ' + trigger.newMap.get(lstLeadReferral.id).FMS_Opportunity_Name__c);
        	
            if(trigger.oldMap.get(lstLeadReferral.id).FMS_Opportunity_Name__c != trigger.newMap.get(lstLeadReferral.id).FMS_Opportunity_Name__c)
            {
                lLeadReferral.add(lstLeadReferral);
            }
        } 
        
        if(lLeadReferral != null && lLeadReferral.size() > 0)
		{
			system.debug('UODOLRH 0.4');
			UpdOppDataOnLeadReferralHelper.UpdateLeadReferral(trigger.new, trigger.oldMap, trigger.newMap);
		}
    }  
}