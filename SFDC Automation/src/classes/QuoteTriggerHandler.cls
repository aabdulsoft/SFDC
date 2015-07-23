/**=====================================================================
 * Appirio, Inc
 * Name: QuoteTriggerHandler
 * Description: Fire Approval Process
 * Created Date: 9-20-2014
 * Created By: Sunil (Appirio)
 =====================================================================*/
public with sharing class QuoteTriggerHandler {
    // Hari Krishnan (12/29/2014): This method updates the UTC_Assigned__c based on the user who created this quote. 
    public static void updateUTC(List<Quote> listQuotes) {
        String utcId = null;
        User u = [SELECT UTC__c FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.debug('$$$: QuoteTriggerHandler.updateUTC() userUTC = ' + u.UTC__c);
        if(String.isBlank(u.UTC__c) == false){
            List<Ryder_Branch__c> lstRB = [SELECT Id FROM Ryder_Branch__c WHERE Branch_Code__c = :u.UTC__c];
        
            if(lstRB.size() > 0 && String.isBlank(lstRB.get(0).Id) == false){
                utcId = lstRB.get(0).Id;
            }
        }
        List<RecordType> listRecordTypes = [SELECT Id FROM RecordType WHERE SObjectType = 'Quote' and IsActive = true AND DeveloperName = 'UVS' LIMIT 1];
        if(listRecordTypes != null && listRecordTypes.size() > 0) {
            String uvsRecordTypeName = listRecordTypes.get(0).Id;
            for(Quote quote : listQuotes) {
                if(quote.RecordTypeId == uvsRecordTypeName) // Assign the UTC only for UVS record types.
                    quote.UTC_Assigned__c = utcId;
            }
        }
    } 


  
  public static void SysnLIsBeforeUpdate(List<Quote> listQuotes, map<id,Quote> oldQuotes){
  	
  	    set<id> quoteIds = new set<id>();
  	   // find Relative Quote Line Items.
        Map<String, QuoteLineItem> mapUniqueItems = new Map<String, QuoteLineItem>();
        Map<String, OpportunityLineItem> mapOppsItems = new Map<String, OpportunityLineItem>();
        Set<Id> vehicleIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
  	
  	 for(Quote qt:listQuotes){
  	 	if(qt.IsSyncing == true && qt.IsSyncing != oldQuotes.get(qt.Id).IsSyncing){
  	 		quoteIds.add(qt.Id);
  	 	}
  	 }
  	
  	 if(!quoteIds.isEmpty()){ 
	    for(QuoteLineItem qli : [Select q.Quote.OpportunityId, q.Warranty__c, q.Vosa__c, q.Vehicle__c, q.UnitPrice,
	                                q.Transfer_expense_paid_by__c, q.Transfer_expense_included__c, q.TotalPrice, q.Term__c,
	                                q.Take_Price2__c, q.SystemModstamp, q.Subtotal, q.SortOrder, q.ServiceDate, q.SAM_Class__c,
	                                q.Quote_Price__c, q.Quote_Line_Item_Number__c, q.Quote_Line_Item_Description__c, q.QuoteId, q.Quantity__c,
	                                q.Quantity, q.PricebookEntryId, q.Model_Year__c, q.ListPrice, q.LineNumber, q.LastModifiedDate, q.LastModifiedById,
	                                q.IsDeleted, q.Interest_Rate__c, q.Id, q.Gain_Loss__c, q.Financing__c, q.Down_Payment_Percent__c, q.Discount, q.Description,
	                                q.Days_held__c, q.Customer_Offer_Price__c, q.CurrencyIsoCode, q.CreatedDate, q.CreatedById, q.Category__c, q.Book_Value__c,
	                                q.Approved_to_take__c, q.Approved_Ryder_Finance_Vendor_Date__c, q.Approved_Price__c, q.Approval_Level__c,q.Down_Payment__c,q.Finance_Company__c,
	                                Miscellaneous_Fee__c,Sales_Tax__c,Warranty_Amount__c,Warranty_Provider__c,Document_Fee_del__c
	                                From QuoteLineItem q
	                                where QuoteId in :quoteIds
	                                and quote.Opportunity.RecordType.DeveloperName = 'UVS_Opportunity'
	                                and quote.Opportunity.isClosed = false
	                                and Vehicle__c != null
	                                ]){
	             	 // check if quote item was updated or not
	              String key = qli.Quote.OpportunityId + '~' + qli.PriceBookEntryId + '~' +
	                       String.valueOf(qli.UnitPrice);
	                mapUniqueItems.put(key, qli);
	                oppIds.add(qli.Quote.OpportunityId);
	                vehicleIds.add(qli.Vehicle__c);
	                system.debug('::qli key::'+key);
	                system.debug(':::QLI >><<<>>>::::'+qli);
	//                system.debug('::qli::'+qli.quote.isSyncing);
	     }
	     
	     List<OpportunityLineItem> lstOppItemsToUpdate = new List<OpportunityLineItem>();
	     QuoteLineItem quoteItem;
	     system.debug('------oppIds in Handler-----'+oppIds);
	     system.debug('--------vehicleIds in Handler-----'+vehicleIds);
	     for(OpportunityLineItem oppItem :[Select o.Warranty__c, o.Vosa__c,  o.Unit_Number__c,
		                                    o.UnitPrice, o.Transfer_expense_paid_by__c, o.Transfer_expense_included__c, o.Transaction_Type__c, o.TotalPrice,
		                                    o.Term__c, o.Take_Price2__c, o.SystemModstamp, o.SortOrder, o.ServiceDate, o.SAM_Class__c,
		                                    o.Quantity, o.Product_Line__c, o.Product_Detail__c, o.Probability__c, o.PricebookEntryId,
		                                    o.Oppurtunity_Product_Number__c, o.Opportunity_Product_Description__c, o.OpportunityId, o.Old_Revenue__c,
		                                    o.Net_Revenue__c, o.Model_Year__c, o.ListPrice, o.LastModifiedDate, o.LastModifiedById, o.IsDeleted,
		                                    o.Interest_Rate__c, o.Id, o.Gain_Loss__c, o.Financing__c, o.Down_Payment_Percent__c, o.Description,
		                                    o.Days_held__c, o.Customer_Branch__c, o.CurrencyIsoCode, o.CreatedDate, o.CreatedById, o.Category__c,
		                                    o.Book_Value__c, o.Automatic_Renewed__c, o.Approved_to_take__c, o.Approved_Ryder_Finance_Vendor_Date__c,
		                                    o.Approved_Price__c, o.Opportunity.SyncedQuoteId, o.Quantity__c, o.Customer_Offer_Price__c, o.Down_Payment__c,o.Finance_Company__c,
		                                    o.Miscellaneous_Fee__c,o.Sales_Tax__c,o.Warranty_Amount__c,Warranty_Provider__c,Document_Fee__c
		                                    From OpportunityLineItem o
		                                    where  Unit_Number__c != NULL
		                                    and Opportunity.isClosed = false
		                                    and OpportunityId in:oppIds
		                                    and Opportunity.SyncedQuoteId != NULL
		                                    AND Unit_Number__c in :vehicleIds
		                                    and Opportunity.RecordType.DeveloperName = 'UVS_Opportunity']
	                                        ){
	          String key = String.valueOf(oppItem.OpportunityId) + '~' + String.valueOf(oppItem.PriceBookEntryId)+ '~' +
	                       String.valueOf(oppItem.UnitPrice);
	          system.debug('::oppItem Key::'+key);      
	          mapOppsItems.put(key,oppItem);        
	          quoteItem = mapUniqueItems.get(key);
	          // if opp item matches with the quote, perform sync
	          if(quoteItem != null){
	               lstOppItemsToUpdate.add(oppItem);
	          }
	     }
	     
	     List<QuoteLineItem>  qliRecentUpdated = new List<QuoteLineItem>();
	  	 List<OpportunityLineItem>  oliRecentUpdated = new List<OpportunityLineItem>();
	  	 
	  	
	     for(String key:mapUniqueItems.keySet()){
	     	if(mapOppsItems.containsKey(key)){
	     		OpportunityLineItem li = mapOppsItems.get(key);
	     		QuoteLineItem Ql = mapUniqueItems.get(key);
	     		if(li.LastModifiedDate > Ql.LastModifiedDate){
	     			ManageStartSync.copyValuesToQLI(Ql,li);
	     			qliRecentUpdated.add(Ql);
	      		}else if(li.LastModifiedDate < Ql.LastModifiedDate){
	     			ManageStartSync.copyValuesToOLI(Ql,li);
	     			oliRecentUpdated.add(li);
	     		}
	     	}
	     }
	     
	     if(!qliRecentUpdated.isEmpty()){
            ManageStartSync.isUpdatingFromOpportunity = true;	     
	     	update qliRecentUpdated;
	     	system.debug('::: QLI Updated ::'+qliRecentUpdated);
	     }
	     
	     if(!oliRecentUpdated.isEmpty()){
	     	ManageStartSync.isUpdatingFromOpportunity = true;	
	     	update oliRecentUpdated;
	     }
  	}
     
     
  }
  
  
  
    
}