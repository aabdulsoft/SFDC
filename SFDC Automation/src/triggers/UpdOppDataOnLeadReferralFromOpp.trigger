trigger UpdOppDataOnLeadReferralFromOpp on Opportunity (after update) 
{
    if(trigger.isAfter)
    {
        list <id> listOppId = new list<id>();
        list <Opportunity> lOpp = new list<Opportunity>();
        list <Lead_Referral__c> lLeadReferral = new list <Lead_Referral__c>();
        //list <Opportunity> listOppLR = new list<Opportunity>();
        
        map<id, id> mapLeadRefOpp = new map<id, id>();
        
        //Traversing through all the opportunities that were changed
        for(Opportunity lstOpp : trigger.new)
        {
            system.debug('UODOLRH 0.1 id = ' + lstOpp.id);
            system.debug('UODOLRH 0.2 Name = ' + trigger.oldMap.get(lstOpp.id).Name + ', ' + trigger.newMap.get(lstOpp.id).Name);
            system.debug('UODOLRH 0.3 Owner = ' + trigger.oldMap.get(lstOpp.id).Owner + ', ' + trigger.newMap.get(lstOpp.id).Owner);
            system.debug('UODOLRH 0.4 StageName = ' + trigger.oldMap.get(lstOpp.id).StageName + ', ' + trigger.newMap.get(lstOpp.id).StageName);
            system.debug('UODOLRH 0.5 EST_DEAL_VAL__c = ' + trigger.oldMap.get(lstOpp.id).EST_DEAL_VAL__c + ', ' + trigger.newMap.get(lstOpp.id).EST_DEAL_VAL__c);
            system.debug('UODOLRH 0.6 CloseDate = ' + trigger.oldMap.get(lstOpp.id).CloseDate + ', ' + trigger.newMap.get(lstOpp.id).CloseDate);
            system.debug('UODOLRH 0.7 NextStep = ' + trigger.oldMap.get(lstOpp.id).NextStep + ', ' + trigger.newMap.get(lstOpp.id).NextStep);
            system.debug('UODOLRH 0.8 Num_of_vehicles__c = ' + trigger.oldMap.get(lstOpp.id).Num_of_vehicles__c + ', ' + trigger.newMap.get(lstOpp.id).Num_of_vehicles__c);
            system.debug('UODOLRH 0.9 CreatedDate = ' + trigger.oldMap.get(lstOpp.id).CreatedDate + ', ' + trigger.newMap.get(lstOpp.id).CreatedDate);
            system.debug('UODOLRH 0.10 Reason_Won_Lost__c = ' + trigger.oldMap.get(lstOpp.id).Reason_Won_Lost__c + ', ' + trigger.newMap.get(lstOpp.id).Reason_Won_Lost__c);
            system.debug('UODOLRH 0.11 Notes__c = ' + trigger.oldMap.get(lstOpp.id).Notes__c + ', ' + trigger.newMap.get(lstOpp.id).Notes__c);
            
            //Checking if the value in any of the four columns were changed, then adding that opp into the lOpp
            if((trigger.oldMap.get(lstOpp.id).StageName != trigger.newMap.get(lstOpp.id).StageName) ||
                (trigger.oldMap.get(lstOpp.id).EST_DEAL_VAL__c != trigger.newMap.get(lstOpp.id).EST_DEAL_VAL__c) ||
                (trigger.oldMap.get(lstOpp.id).Owner != trigger.newMap.get(lstOpp.id).Owner) ||
                (trigger.oldMap.get(lstOpp.id).Name != trigger.newMap.get(lstOpp.id).Name) ||
                (trigger.oldMap.get(lstOpp.id).CloseDate != trigger.newMap.get(lstOpp.id).CloseDate) ||
                (trigger.oldMap.get(lstOpp.id).NextStep != trigger.newMap.get(lstOpp.id).NextStep) ||
                (trigger.oldMap.get(lstOpp.id).Num_of_vehicles__c != trigger.newMap.get(lstOpp.id).Num_of_vehicles__c) ||
                (trigger.oldMap.get(lstOpp.id).CreatedDate != trigger.newMap.get(lstOpp.id).CreatedDate) ||
                (trigger.oldMap.get(lstOpp.id).Reason_Won_Lost__c != trigger.newMap.get(lstOpp.id).Reason_Won_Lost__c) ||
                (trigger.oldMap.get(lstOpp.id).Notes__c != trigger.newMap.get(lstOpp.id).Notes__c))
            {
                lOpp.add(lstOpp);
                system.debug('UODOLRH 0.6 lOpp = ' + lOpp);
            }
        }
        
        //Getting the LeadReferral data for the opportunities for which the data was changed
        if(lOpp.size()>0)
        {
            lLeadReferral = [select id, FMS_Opportunity_Name__c from Lead_Referral__c where FMS_Opportunity_Name__c in: lOpp];
            system.debug('UODOLRH 0.7 lLeadReferral = ' + lLeadReferral);
        }
        
        
        if(lLeadReferral.size() > 0)
        {
            for(Lead_Referral__c lstLR :lLeadReferral)
            {
                if(!mapLeadRefOpp.containskey(lstLR.id)) mapLeadRefOpp.put(lstLR.id, lstLR.FMS_Opportunity_Name__c);
                listOppId.add(lstLR.FMS_Opportunity_Name__c);
                system.debug('UODOLRH 0.8 mapLeadRefOpp = ' + mapLeadRefOpp + ' listOppId = ' + listOppId);
            }
        }
                    
        if(listOppId!= null && listOppId.size() > 0)
        {
            system.debug('UODOLRH 0.9');
            UpdOppDataOnLeadReferralHelper.UpdateLeadReferralFromOpp(listOppId, trigger.oldMap, trigger.newMap, mapLeadRefOpp);
        }
    }  
}