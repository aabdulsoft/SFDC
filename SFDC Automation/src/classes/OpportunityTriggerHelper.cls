//RA: Please provide Appirio Header
public with sharing class OpportunityTriggerHelper {

    // Sunil : 10/14/2014: Send Email to Employee by Finding the Converted Lead.
  public static void sendEmailToEmployee(Map<Id, Opportunity> mapOldOps, Map<Id, Opportunity> mapNewOps) {

    Id recordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('UVS Opportunity').getRecordTypeId();

    // Eligible Opportunities.
    Set<Id> setEligibleOps = new Set<Id>();
    for(Opportunity opp :mapNewOps.values()){
      if(opp.RecordTypeId == recordTypeId && opp.isClosed == true && mapOldOps.get(opp.Id).isClosed != opp.isClosed){
        setEligibleOps.add(opp.Id);
      }
    }
    system.debug('@@@---------------------' + setEligibleOps);

    Map<Id, String> mapEmployee = new Map<Id, String>();
    for(Lead lead :[SELECT Employee_Email__c, ConvertedOpportunityId FROM Lead WHERE IsConverted = true AND ConvertedOpportunityId IN :setEligibleOps]){
      if(String.isBlank(lead.Employee_Email__c) == false && lead.ConvertedOpportunityId != null){
        mapEmployee.put(lead.ConvertedOpportunityId, lead.Employee_Email__c);
      }
    }
    System.debug('@@@' + mapEmployee);

    List<Opportunity> lstOppsToUpdate = new List<Opportunity>();
    for(Id oppId :mapEmployee.keySet()){
        Opportunity opp = new Opportunity(Id = oppId);
        opp.Send_Email_To_Lead_Employee__c = true;
        opp.Lead_Employee_Email__c = mapEmployee.get(oppId);
        lstOppsToUpdate.add(opp);
    }
    System.debug('@@@' + lstOppsToUpdate);
    update lstOppsToUpdate;
  }
  // Sunil : 9/15/2014: Set Vehicle's Sold_Flag__c to true.
  public static void setSoldFlagOnVehicle(Map<Id, Opportunity> mapOld, Map<Id, Opportunity> mapNew){
    Id uvsOppRTId = UVS_Util.UVSRecordType_Opp;

    // set of eligible Opportunities.
    Set<Id> setOps = new Set<Id>();
    for(Opportunity opp :mapNew.values()){
      if(opp.RecordTypeId == uvsOppRTId && mapOld.get(opp.Id).IsClosed == false && opp.IsClosed == true){
        setOps.add(opp.Id);
      }
    }
    System.debug('@@@' + setOps);

    // prepare set for Vehicles which Sold flag is false.
    Set<Id> setVehicles = new Set<Id>();
    Map<Id, List<OpportunityLineItem>> mapOpportunities = new Map<Id, List<OpportunityLineItem>>();
    for(OpportunityLineItem oli :[SELECT Id,Unit_Number__r.Product_Name__c, Opportunity.IsClosed,Unit_Number__c, Opportunity.OwnerId,OpportunityId FROM OpportunityLineItem
                                  WHERE Unit_Number__r.Sold_Flag__c = false
                                  AND OpportunityId = :setOps]){

      setVehicles.add(oli.Unit_Number__c);
      if(oli.Unit_Number__c!=null && oli.Opportunity.IsClosed == false)
      {
      if(mapOpportunities.containsKey(oli.OpportunityId) == false){
        mapOpportunities.put(oli.OpportunityId, new List<OpportunityLineItem>());
      }
        mapOpportunities.get(oli.OpportunityId).add(oli);
       }
    }
    System.debug('@@@' + setVehicles);


    List<Vehicle__c> lstVehicles = new List<Vehicle__c>();
    for(Vehicle__c veh : [select id,Sold_Flag__c from Vehicle__c where id in :setVehicles]){
        Veh.Sold_Flag__c = true;
        lstVehicles.add(Veh);
    }
    System.debug('@@@' + lstVehicles);

    if(lstVehicles.size()>0)
    {
    update lstVehicles;
    }


    // fetch all opportunities associated to these vehicles WHICH ARE NOT CLOSED

  /*  for(OpportunityLineItem oli :[SELECT Id, ,  OpportunityId,  FROM OpportunityLineItem
                                  WHERE Unit_Number__c in :setVehicles
                                  AND Opportunity.IsClosed = false]){


    }  */
    System.debug('@@@' + mapOpportunities);

    // post chatter message on opportunity record.
    // exclude the opportunities which are in current context.
    Set<Id> selectedOppIds = new Set<Id>();
    for(Id oppId :mapOpportunities.keySet()){
        if(mapNew.keySet().contains(oppId) == false){
            selectedOppIds.add(oppId);
        }
    }
    System.debug('@@@' + selectedOppIds);

    // post chatter
    if(selectedOppIds.size() > 0){
      postChatterFeed(selectedOppIds);
    }


    // create task.
    createTask(selectedOppIds, mapOpportunities);

  }

    // Hari Krishnan(12/29/2014): This method populates the UTC_Assigned__c.
    public static void updateUTC(List<Opportunity> listOpportunities) {
        String utcId = null;
        User u = [SELECT UTC__c FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.debug('$$$: OpportunityTriggerHelper.updateUTC() userUTC = ' + u.UTC__c);
        if(String.isBlank(u.UTC__c) == false){
            List<Ryder_Branch__c> lstRB = [SELECT Id FROM Ryder_Branch__c WHERE Branch_Code__c = :u.UTC__c];

            if(lstRB.size() > 0 && String.isBlank(lstRB.get(0).Id) == false){
                utcId = lstRB.get(0).Id;
            }
        }
        if(utcId != null) {
            for(Opportunity opp : listOpportunities) {
                opp.UTC_Assigned__c = utcId;
            }
        }
    }

    public static void createTask(Set<Id> selectedOppIds, Map<Id, List<OpportunityLineItem>> mapOpportunities){
    	List<Task> lstTasks = new List<Task>();
	    for(Id oppId :selectedOppIds){
	      Task objTask = new Task();
	      //objTask.OwnerId = relatedOpp.OwnerId;
	      objTask.Subject = 'The vehicle attached to this opportunity is no longer available for sale.';

	      String description = 'The below vehicles is no longer available for sale. ';
	      for(OpportunityLineItem oli :mapOpportunities.get(oppId)){
	        description = description + oli.Unit_Number__r.Product_Name__c;
	      }
	      objTask.Description = description;
	      objTask.WhatId = oppId;
	      lstTasks.add(objTask);
	    }
	    System.debug('@@@' + lstTasks);

	    insert lstTasks;
    }

  // Helper method to post chatter message on opportunities record.
  public static void postChatterFeed(Set<Id> oppIds){
    List<FeedItem> lst = new List<feedItem>();
    for(Id oppId :  oppIds){
      FeedItem fi= new FeedItem();
      fi.parentId = oppId;
      fi.body = 'The vehicle attached to this opportunity is no longer available for sale.';
      lst.add(fi);
    }
    insert lst;
  }
}