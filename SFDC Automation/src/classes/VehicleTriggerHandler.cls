/*************************************************************************************************
Created By:    Sunil Gupta
Date:          September 10, 2014
Description  : Handler class for Vehicle Trigger
**************************************************************************************************/
public class VehicleTriggerHandler { 

  public static void updateOppChatter(Map<Id, Vehicle__c> oldMap, Map<Id, Vehicle__c> newMap) {
    Set<Id> setVehicles = new Set<Id>();
    for(Vehicle__c v :newMap.values()){
      if(v.Ask_Price__c != oldMap.get(v.Id).Ask_Price__c || v.Take_Price__c != oldMap.get(v.Id).Take_Price__c ||
         v.NBV__c != oldMap.get(v.Id).NBV__c){
        setVehicles.add(v.Id);
      }
    }
    System.debug('@@@setVehicles' + setVehicles);

    
    Map<Id, Set<Id>> eligibleOpps = new Map<Id, Set<Id>>();
    for(OpportunityLineItem oli :[SELECT OpportunityId, Unit_Number__c  FROM OpportunityLineItem WHERE Unit_Number__c IN :setVehicles]){
      if(eligibleOpps.containsKey(oli.OpportunityId) == false){
        eligibleOpps.put(oli.OpportunityId, new Set<Id>());
      }
      eligibleOpps.get(oli.OpportunityId).add(oli.Unit_Number__c);
    }
    System.debug('@@@' + eligibleOpps);
    
    
    
    Map<Id, List<String>> chatterMsg = new Map<Id, List<String>>();
    for(Id vehicleId :setVehicles){
      if(newMap.get(vehicleId).Ask_Price__c != oldMap.get(vehicleId).Ask_Price__c){
      	//Updated By Virendra to fix null pointer issues 
      	if(oldMap.get(vehicleId).Ask_Price__c != null && newMap.get(vehicleId).Ask_Price__c != null){
	        String askPriceOld = (oldMap.get(vehicleId).Ask_Price__c.setScale(0)).format();
	         String askPriceNew = ( newMap.get(vehicleId).Ask_Price__c.setScale(0)).format();
	         
	        String s = 'The Ask price for Unit# ' + newMap.get(vehicleId).Name + ' was changed from ' + askPriceOld + ' to ' + askPriceNew;
	        if(chatterMsg.containsKey(vehicleId) == false){
	          chatterMsg.put(vehicleId, new List<String>());
	        }
	        chatterMsg.get(vehicleId).add(s);
      	}
      }
      
      if(newMap.get(vehicleId).NBV__c != oldMap.get(vehicleId).NBV__c){
      	//Updated By Virendra to fix null pointer issues 
      	if(oldMap.get(vehicleId).NBV__c != null && newMap.get(vehicleId).NBV__c != null ){
	        String bookPriceOld = (oldMap.get(vehicleId).NBV__c.setScale(0)).format();
	         String bookPriceNew = ( newMap.get(vehicleId).NBV__c.setScale(0)).format();
	         
	        String s = 'The Book price for Unit# ' + newMap.get(vehicleId).Name +' was changed from ' + bookPriceOld + ' to ' + bookPriceNew;
	        if(chatterMsg.containsKey(vehicleId) == false){
	          chatterMsg.put(vehicleId, new List<String>());
	        }
	        chatterMsg.get(vehicleId).add(s);
      	}
      }
      
      if(newMap.get(vehicleId).Take_Price__c != oldMap.get(vehicleId).Take_Price__c){
      	//Updated By Virendra to fix null pointer issues 
      	if(oldMap.get(vehicleId).Take_Price__c != null && newMap.get(vehicleId).Take_Price__c != null ){
	         String takePriceOld = (oldMap.get(vehicleId).Take_Price__c.setScale(0)).format();
	         String takePriceNew = ( newMap.get(vehicleId).Take_Price__c.setScale(0)).format();
	         
	         //return s.substring(0,s.length()-1);
	    
	        String s = 'The Take price for Unit# ' + newMap.get(vehicleId).Name + ' was changed from ' + takePriceOld + ' to ' + takePriceNew;
	        if(chatterMsg.containsKey(vehicleId) == false){
	          chatterMsg.put(vehicleId, new List<String>());
	        }
	        chatterMsg.get(vehicleId).add(s);
      	}
      }
    }
    System.debug('@@@$$$' + chatterMsg);
    if(eligibleOpps.size() > 0 && chatterMsg.size() > 0){
      postChatterTextFeed(eligibleOpps, chatterMsg);
    }
  }

  private static void postChatterTextFeed(Map<Id, Set<Id>> eligibleOpps, Map<Id, List<String>> chatterMsg){
    List<FeedItem> lst = new List<feedItem>();
    for(Id oppId :  eligibleOpps.keySet()){
      for(Id vehicleId :eligibleOpps.get(oppId)){
        for(String msg :chatterMsg.get(vehicleId)){
          FeedItem fi = new FeedItem();
          fi.parentId = oppId;
          fi.body = msg;
          lst.add(fi);
        }
      }
    }
    System.debug('chatter feeds'+lst);
    insert lst;
    /*
    String communityID = null; //Set the community to null to post internally, else set the communityId

    ConnectApi.FeedType feedType = ConnectApi.FeedType.Record;
    ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
    ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
    messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

    ConnectApi.TextSegmentInput initTextSegment = new ConnectApi.TextSegmentInput();
    initTextSegment.text = content;

    messageInput.messageSegments.add(initTextSegment);

    input.body = messageInput;

    ConnectApi.FeedItem feedItemResponse = ConnectApi.ChatterFeeds.postFeedItem(communityId, feedType, parentId, input, null);
    System.debug('@@@###' + parentId);
    System.debug('@@@###' + feedItemResponse);
    */
  }

}