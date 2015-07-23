/**=====================================================================
 * Appirio, Inc
 * Name: BTRTriggerHandler
 * Created Date: 9-25-2014
 * Created By: Sunil (Appirio)
 =====================================================================*/
public without sharing class BTRTriggerHandler {
  // update Quote Satus To Approved
  public static void updateQuoteSatusToApproved(Map<Id, BTR__c> mapOld, Map<Id, BTR__c> mapNew) {
    Set<Id> setQuotes = new Set<Id>();
    Set<Id> setEligibleIds = new Set<Id>();
    Set<Id> ownerIds = new Set<Id>();
    for(BTR__c b :mapNew.values()){
        if(mapOld.get(b.Id).Status__c != b.Status__c && b.Status__c == 'Approved'){
        setQuotes.add(b.Quote__c);
        setEligibleIds.add(b.Id);
        ownerIds.add(b.OwnerId);
      }
    }
    System.debug('@@@' + setQuotes);
    
    Map<Id, BTR__c> mapBTR = new Map<Id, BTR__c>([SELECT Id, Quote__c,CreatedDate, Is_Conditional_Approval__c, Name, 
                     Status__c, Owner.Name, Requester_Comments__c, 
                     OwnerId, Ryder_Branch__r.Name FROM BTR__c WHERE Id IN :setEligibleIds]);
    
    // Update Related Quote Status
    List<Quote> lstQuotes = new List<Quote>();
    for(Quote q :[SELECT Id, Status FROM Quote WHERE Id IN :setQuotes]){
      q.Status = 'BTR Approved';
      lstQuotes.add(q);
    }
    System.debug('@@@' + lstQuotes);
    update lstQuotes;
    
    Map<Id, User> mapOwners = new Map<Id, User>([SELECT Id, UTC__c FROM User WHERE Id IN :ownerIds]);
    System.debug('@@@' + mapOwners);
        
    // Insert BTR History record.
    Set<Id> quotesIdSet = new Set<Id>();
    map<Id,BTR__c> quoteToBTRMap = new map<Id,BTR__c>();
    for(BTR__c b :mapNew.values()){
      if(setEligibleIds.contains(b.Id)){
        quotesIdSet.add(b.Quote__c);
        BTR__c objBTR = mapBTR.get(b.Id);
        quoteToBTRMap.put(b.Quote__c, objBTR);
      }
    }
    
    System.debug('Map New:'+mapNew.keySet());
    System.debug('Eligible ids:'+setEligibleIds);
    
    List<Quote> quotesList = [Select Id, Opportunity.Account.Name, (Select Id,SAM_Class__c, UnitPrice, Model_Year__c,Make_Model__c,Eng_Mdl__c,Miles__c,
                                       NVI_Percent__c,Take_Price_percent__c, Book_Value__c,Take_Price2__c,Customer_Offer_Price__c,Gain_Loss__c,As_Is_Vehicle__c,
                                        Vosa__c,Approved_Price__c,Vehicle__r.Name, CreatedBy.Name, CreatedDate, Days_Held__c
                                FROM QuoteLineItems), UTC_Assigned__c 
                                FROM Quote WHERE Id in:quotesIdSet];
    List<QuoteLineItem> lineItems;
    List<BTR_History__c> lstHistory = new List<BTR_History__c>();
    BTR_History__c objHistory ;
    //map<Id,List<QuoteLineItem>> quoteLineItemsMap = new map<Id,List<QuoteLineItem>>([Select Id,(Select Id From QuoteLineItems) from Quote where Id in:quotesIdSet]);
    for(Quote quo : quotesList){
        lineItems = quo.QuoteLineItems;
        if(lineItems!=null && !lineItems.isEmpty()){
            for(QuoteLineItem qli : lineItems){
                objHistory = new BTR_History__c();
                objHistory.BTR_Number__c = quoteToBTRMap.get(quo.Id).Id;
                objHistory.Requester_Comments__c = quoteToBTRMap.get(quo.Id).Requester_Comments__c;
                objHistory.Quote_Number__c = quoteToBTRMap.get(quo.Id).Quote__c;
                objHistory.BTR_Status__c = quoteToBTRMap.get(quo.Id).Status__c;
                objHistory.Vehicle_Number__c = qli.Vehicle__r.Name;
                objHistory.SAM_Class__c = qli.SAM_Class__c;
                objHistory.Year__c = qli.Model_Year__c;
                objHistory.Make_Model__c = qli.Make_Model__c;
                objHistory.Days_At_UTC__c = qli.Days_Held__c;
                objHistory.NVI_Percent__c = qli.NVI_Percent__c;
                objHistory.Take_Price_percent__c = qli.Take_Price_percent__c;
                objHistory.Engine_Make_Model__c = qli.Eng_Mdl__c;
                objHistory.Mileage__c = qli.Miles__c;
                objHistory.Book_Value__c = qli.Book_Value__c;
                objHistory.Take_Price__c = qli.Take_Price2__c;
                objHistory.Offer_Price_Sale_Price__c = qli.UnitPrice;//qli.Customer_Offer_Price__c;
                objHistory.Gain_Loss__c = qli.Gain_Loss__c;
                objHistory.As_Is_Vehicle__c = qli.As_Is_Vehicle__c;
                objHistory.VOSA__c = qli.Vosa__c;
                objHistory.Approved_Price__c = qli.Approved_Price__c;
                objHistory.Customer_Name__c = quo.Opportunity.Account.Name;
                objHistory.Requestor__c = quoteToBTRMap.get(quo.Id).Owner.Name;
                objHistory.Is_Conditional_Approval__c = quoteToBTRMap.get(quo.Id).Is_Conditional_Approval__c;
                objHistory.Request_Date__c = quoteToBTRMap.get(quo.Id).CreatedDate;
                objHistory.UTC__c = quoteToBTRMap.get(quo.Id).Ryder_Branch__r.Name;//mapOwners.get(quoteToBTRMap.get(quo.Id).OwnerId).UTC__c;
                lstHistory.add(objHistory);
            }
        }
    }
    System.debug('List history:'+lstHistory);
 
    /*for(Id quoteId : quotesIdSet){
        if(quoteLineItemsMap.containsKey(quoteId)){
            for(QuoteLineItem qli: quoteLineItemsMap.get(quoteId)){
                objHistory = new BTR_History__c();
                objHistory.BTR_Number__c = b.Id;
                objHistory.Quote_Number__c = b.Quote__c;
                objHistory.BTR_Status__c = b.Status__c;
                objHistory.Vehicle_Number__c = b.Name;
                objHistory.SAM_Class__c = b.SAM_Class__c;
                objHistory.Year__c = b.Year__c;
                objHistory.Make_Model__c = b.Make_Model__c;
                objHistory.Location__c = b.Location__c;
                objHistory.Days_At_UTC__c = b.Days_At_UTC__c;
                objHistory.Engine_Make_Model__c = b.Engine_Make_Model__c;
                objHistory.Mileage__c = b.Mileage__c;
                objHistory.Book_Value__c = b.Book_Value__c;
                objHistory.Take_Price__c = b.Take_Price2__c;
                objHistory.Offer_Price_Sale_Price__c = b.Offer_Price_Sale_Price__c;
                objHistory.Gain_Loss__c = b.Gain_Loss__c;
                objHistory.As_Is_Vehicle__c = b.As_Is_Vehicle__c;
                objHistory.VOSA__c = b.VOSA__c;
                objHistory.Approved_Price__c = b.Approved_Price__c;
                objHistory.Customer_Name__c ='';
                objHistory.Requestor__c ='';
                objHistory.Request_Date__c  = '';
                objHistory.UTC__c = '';
                
                lstHistory.add(objHistory);
            }
        }
    }*/
    if(!lstHistory.isEmpty())
        insert lstHistory;
  }
}