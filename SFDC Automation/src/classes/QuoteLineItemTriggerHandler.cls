/*************************************************************************************************
Created By:    Sunil Gupta
Date:          September 11, 2014
Description  : Handler class for QuoteLineItem Trigger
**************************************************************************************************/

public class QuoteLineItemTriggerHandler {

  // Create Quote Line Item History Records.
  public static void createHistoryRecords(Map<Id, QuoteLineItem> newMap ,Map<Id, QuoteLineItem> oldMap) {

    List<QuoteLineItemHistory__c> lstItems = new List<QuoteLineItemHistory__c>();
    for(QuoteLineItem item :newMap.values()){
        if(oldMap == null || oldMap.get(item.Id).UnitPrice != item.UnitPrice){
            QuoteLineItemHistory__c obj = new QuoteLineItemHistory__c();
        obj.Field__c = 'UnitPrice__c';
        if(oldmap == null){
          obj.OldValue__c = '0.00';
        }
        else{
            obj.OldValue__c = String.valueOf(oldMap.get(item.Id).UnitPrice);
        }
        obj.NewValue__c = String.valueOf(item.UnitPrice);
        obj.Action__c = 'Changed from ' + obj.OldValue__c + ' to ' + obj.NewValue__c;
        obj.Quote_Line_Item__c = item.Id;
        lstItems.add(obj);
        }
    }

    try{
        System.debug('@@@' + lstItems);
        insert lstItems;
    }
    catch(Exception ex){
        System.debug(ex.getMessage());
    }
  }

  public static void calculateBase(List<QuoteLineItem> listQli){
    for(QuoteLineItem qli : listQli){
        if(qli.Interest_Rate__c <> null && qli.Term__c <> null){
          qli.Base__c = calculateBaseValue(qli.Interest_Rate__c, qli.Term__c);
        }
    }
  }

  public static double calculateBaseValue(String InterestRate, String term){
      Double base = 1.0000000000;
      Double mbase = 1.0000000000 + (Decimal.ValueOf(InterestRate )/ 1200);
      system.debug('********mbase***'+mbase);
      for(integer i=0; i < Integer.ValueOf(term); i++){
        base = base * mbase;
        system.debug('********base***'+base);
      }
      return base;
  }
}