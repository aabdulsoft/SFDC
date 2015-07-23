/*
* 
*   Helper class for the trigger UpdOppDataOnLeadReferral that updates the values of Opp Name, Opp
*   Owner on the Lead Referral record when Opportunity is linked with the Lead Referral record.
*
*   Author                     |Date               |Comment
*   -------------------------|------------------|--------------------------------------------------
*   Saad Wali Jaan    |05.18.2015   |First draft
*
*/
public with sharing class UpdOppDataOnLeadReferralHelper {

    public static void UpdateLeadReferral(List<Lead_Referral__c> lLeadRef, Map<Id, Lead_Referral__c> mapOld, Map<Id, Lead_Referral__c> mapNew) {
        
        system.debug('UODOLRH 1 lLeadRef = ' + lLeadRef);
        system.debug('UODOLRH 2 mapOld = ' + mapOld);
        system.debug('UODOLRH 3 mapNew = ' + mapNew);

        map<id, id> mapLeadRefOpp = new map<id, id>();
        list<id> lstOppId = new list<id>();
        list<Lead_Referral__c> lstLeadRefToUpdate = new list<Lead_Referral__c>(); 
        
        for(Lead_Referral__c lstLeadRef: lLeadRef)
        {
            if(!mapLeadRefOpp.containskey(lstLeadRef.id)) mapLeadRefOpp.put(lstLeadRef.id, mapNew.get(lstLeadRef.id).FMS_Opportunity_Name__c);
            if(mapNew.get(lstLeadRef.id).FMS_Opportunity_Name__c <> null) lstOppId.add(mapNew.get(lstLeadRef.id).FMS_Opportunity_Name__c);            
        }   
        system.debug('UODOLRH 4 - mapLeadRefOpp = ' + mapLeadRefOpp);
        system.debug('UODOLRH 5 - lstOppId = ' + lstOppId);
        
        //list<opportunity> lstOpportunity = [select id, Name, Owner.Name, StageName, EST_DEAL_VAL__c from Opportunity where id in :lstOppId];
        list<opportunity> lstOpportunity = [select id, Name, Owner.Name, StageName, EST_DEAL_VAL__c, CloseDate, NextStep, Num_of_vehicles__c, CreatedDate, Reason_Won_Lost__c, Notes__c from Opportunity where id in :lstOppId];
        system.debug('UODOLRH 6 - lstOpportunity = ' + lstOpportunity);
        
        for(Lead_Referral__c lstLR: lLeadRef)
        {
            system.debug('UODOLRH 7.1 - mapLeadRefOpp.get(lstLR.id) = ' + mapLeadRefOpp.get(lstLR.id));
            if (mapLeadRefOpp.get(lstLR.id)== null)
            {
                system.debug('UODOLRH 7.2');
                //lstLeadRefToUpdate.add(new Lead_Referral__c(id=lstLR.id, FMS_Oppty_Name__c=NULL, FMS_Oppty_Amount__c=NULL, FMS_Oppty_Stage__c=NULL, FMS_Oppty_Owner__c=NULL));
                lstLeadRefToUpdate.add(new Lead_Referral__c(id=lstLR.id, FMS_Oppty_Name__c=NULL, FMS_Oppty_Amount__c=NULL, FMS_Oppty_Stage__c=NULL, FMS_Oppty_Owner__c=NULL, Close_Date__c=NULL, Next_Steps__c=NULL, FMS_Oppty_Total_Vehicles__c=NULL, FMS_Oppty_Created_Date__c=NULL, FMS_Oppty_Reason_Won_Lost__c=NULL, FMS_Oppty_Win_Loss_Notes__c=NULL));                      
            }
            else
            {
                system.debug('UODOLRH 7.3');
                for(Opportunity Opp: lstOpportunity)
                {
                    system.debug('UODOLRH 8 - mapLeadRefOpp.get(lstLR.id) = ' + mapLeadRefOpp.get(lstLR.id) + ' Opp.id = ' + Opp.id);
                    if(mapLeadRefOpp.get(lstLR.id) == Opp.id)
                    {
                        //lstLeadRefToUpdate.add(new Lead_Referral__c(id=lstLR.id, FMS_Oppty_Name__c=Opp.Name, FMS_Oppty_Amount__c=Opp.EST_DEAL_VAL__c, FMS_Oppty_Stage__c=Opp.StageName, FMS_Oppty_Owner__c=Opp.Owner.Name));
                        lstLeadRefToUpdate.add(new Lead_Referral__c(id=lstLR.id, FMS_Oppty_Name__c=Opp.Name, FMS_Oppty_Amount__c=Opp.EST_DEAL_VAL__c, FMS_Oppty_Stage__c=Opp.StageName, FMS_Oppty_Owner__c=Opp.Owner.Name, Close_Date__c=Opp.CloseDate, Next_Steps__c=Opp.NextStep, FMS_Oppty_Total_Vehicles__c=Opp.Num_of_vehicles__c, FMS_Oppty_Created_Date__c=Opp.CreatedDate, FMS_Oppty_Reason_Won_Lost__c=Opp.Reason_Won_Lost__c, FMS_Oppty_Win_Loss_Notes__c=Opp.Notes__c));  
                        system.debug('UODOLRH 9 - lstLeadRefToUpdate = ' + lstLeadRefToUpdate);
                    }
                }
            }
        }
        if (lstLeadRefToUpdate.size() > 0) update lstLeadRefToUpdate; 
    }
    
    public static void UpdateLeadReferralFromOpp(List<Id> lstOppId, Map<Id, Opportunity> mapOld, Map<Id, Opportunity> mapNew, Map<id, Id> mapLeadRefOpp) {
    
        system.debug('UODOLRH 10 lstOppId = ' + lstOppId);
        system.debug('UODOLRH 11 mapOld = ' + mapOld);
        system.debug('UODOLRH 12 mapNew = ' + mapNew);
        system.debug('UODOLRH 13 mapLeadRefOpp = ' + mapLeadRefOpp);
        
        //list<id> lstLeadRefId = new list<id>(mapLeadRefOpp.keyset());
        list<Lead_Referral__c > lstLeadRefId = [Select id from Lead_Referral__c where id in: mapLeadRefOpp.keyset()];
        system.debug('UODOLRH 14 - lstLeadRefId = ' + lstLeadRefId);
        
        list<Lead_Referral__c> lstLeadRefToUpdate = new list<Lead_Referral__c>(); 
        
        list<opportunity> lstOpportunity = [select id, Name, Owner.Name, StageName, EST_DEAL_VAL__c, CloseDate, NextStep, Num_of_vehicles__c, CreatedDate, Reason_Won_Lost__c, Notes__c from Opportunity where id in :lstOppId];
        system.debug('UODOLRH 15 - lstOpportunity = ' + lstOpportunity);
        
        for(Lead_Referral__c lstLR: lstLeadRefId)
        {
            system.debug('UODOLRH 16 - lstLR.id = ' + lstLR.id);
            for(Opportunity Opp: lstOpportunity)
            {
                system.debug('UODOLRH 17 - mapLeadRefOpp.get(lstLR.id) = ' + mapLeadRefOpp.get(lstLR.id) + ' Opp.id = ' + Opp.id);
                if(mapLeadRefOpp.get(lstLR.id) == Opp.id)
                {
                    lstLeadRefToUpdate.add(new Lead_Referral__c(id=lstLR.id, FMS_Oppty_Name__c=Opp.Name, FMS_Oppty_Amount__c=Opp.EST_DEAL_VAL__c, FMS_Oppty_Stage__c=Opp.StageName, FMS_Oppty_Owner__c=Opp.Owner.Name, Close_Date__c=Opp.CloseDate, Next_Steps__c=Opp.NextStep, FMS_Oppty_Total_Vehicles__c=Opp.Num_of_vehicles__c, FMS_Oppty_Created_Date__c=Opp.CreatedDate, FMS_Oppty_Reason_Won_Lost__c=Opp.Reason_Won_Lost__c, FMS_Oppty_Win_Loss_Notes__c=Opp.Notes__c));
                    system.debug('UODOLRH 18 - lstLeadRefToUpdate = ' + lstLeadRefToUpdate);
                }
            }
        }
        if (lstLeadRefToUpdate.size() > 0) update lstLeadRefToUpdate; 
    }
}