/*************************************************************************************************
Created By:    Sunil Gupta
Date:          Oct 13, 2014
Description  : Class to sync OppotunityLineItem and QuoteLineItem
**************************************************************************************************/
public class QLIOLISyncManager {

  public static boolean isSynced = false;

  //-----------------------------------------------------------------------------------------------
  //  Sync Quote Line Items to Opportunity Line Items for UVS before Insert
  //-----------------------------------------------------------------------------------------------
  public static void syncQuoteLineItemsOnInsert(List<QuoteLineItem> newList){
    try{
      Set<Id> quoteIds = new Set<Id>();
      map<String,QuoteLineItem> oppPBEtoQLIMap = new map<String,QuoteLineItem>();
      for(QuoteLineItem qli : newList){
          quoteIds.add(qli.QuoteId);
      }
      Set<Id> UniquePBEntryIds = new Set<Id>();
      map<Id, Id> mapQuoteIdOppId = new map<Id, Id>();
      for(Quote quote: [Select Id, OpportunityId
                        from Quote
                        where Id in :quoteIds
                        and Opportunity.RecordType.DeveloperName = 'UVS_Opportunity'
                        and Opportunity.isClosed = false]){
        mapQuoteIdOppId.put(quote.Id, quote.OpportunityId);

      }

      for(QuoteLineItem quoteItem : newList){
          system.debug('======================' + quoteItem);
        String key = String.valueOf(mapQuoteIdOppId.get(quoteItem.quoteId)) +'~'+
                     String.valueOf(quoteItem.PricebookEntryId) + '~' +
                     String.valueOf(quoteItem.Description);
        //+ '~' +String.valueOf(quoteItem.Description) + '~' + String.valueOf(quoteItem.Quantity) ;
        system.debug('============= : key==================' + Key);
        oppPBEtoQLIMap.put(key, quoteItem);
        UniquePBEntryIds.add(quoteItem.PricebookEntryId);
      }
      QuoteLineItem quoteItem;
      for(OpportunityLineItem oppItem :[SELECT Id, OpportunityId, Unit_Number__c, Quantity__c, UnitPrice, Transfer_expense_paid_by__c,
                                        Transfer_expense_included__c, Approved_Ryder_Finance_Vendor_Date__c, Warranty__c,
                                        Category__c, Financing__c, Interest_Rate__c, Term__c, Down_Payment__c, Book_Value__c,
                                        Customer_Offer_Price__c, Take_Price2__c, Gain_Loss__c, SAM_Class__c, Quantity, Description, 
                                        Model_Year__c, Approved_Price__c, Vosa__c, PricebookEntryId, ListPrice, TotalPrice, Subtotal,Finance_Company__c,
                                        Down_Payment_Percent__c,Miscellaneous_Fee__c,Sales_Tax__c,Warranty_Amount__c,Warranty_Provider__c,Document_Fee__c
                                      FROM OpportunityLineItem
                                      WHERE OpportunityId in :mapQuoteIdOppId.values()
                                      AND PricebookEntryId in :UniquePBEntryIds
                                      ]){
        if(!oppPBEtoQLIMap.isEmpty()){
          String key = String.valueOf(oppItem.OpportunityId) +'~'+
                       String.valueOf(oppItem.PricebookEntryId) + '~' +
                       String.valueOf(oppItem.Description);
          //+ '~' + String.valueOf(oppItem.Description) + '~' + String.valueOf(oppItem.Quantity);
          quoteItem = oppPBEtoQLIMap.get(key);
          system.debug('========== : key==========' + key);
          system.debug('========== : oppItem==========' + oppItem);
          system.debug('========== : quoteItem==========' + quoteItem);
          if(quoteItem <> null){
            copyValuesToQLI(quoteItem, oppItem);
          }

        }

      }

    }
    catch(Exception ex){
        system.debug('QuoteLineItemTriggerHandler.syncQuoteLineItemsOnInsert(): An exception occurred while processing the request. Exception message ='+
                     ex.getMessage() +  '. \n Stacktrace = ' + ex.getStackTraceString());
    }
  }



  //-----------------------------------------------------------------------------------------------
  //  Sync Quote Line Items to Opportunity Line Items for UVS before Insert
  //-----------------------------------------------------------------------------------------------
  public static void syncOppLineItemsOnInsert(List<OpportunityLineItem> newList){
    try{
      Set<Id> oppIds = new Set<Id>();
      map<String,OpportunityLineItem> oppPBEtoOLIMap = new map<String,OpportunityLineItem>();
      for(OpportunityLineItem oli : newList){
          oppIds.add(oli.OpportunityId);
      }
      Set<Id> UniquePBEntryIds = new Set<Id>();
      map<Id, Id> mapOppIdQuoteId = new map<Id, Id>();
      for(Opportunity opp: [Select Id, syncedQuoteId
                        from Opportunity
                        where Id in :oppIds
                        and RecordType.DeveloperName = 'UVS_Opportunity'
                        and Opportunity.isClosed = false
                        and Opportunity.SyncedQuoteId != null]){
        mapOppIdQuoteId.put(opp.Id, opp.SyncedQuoteId);

      }

      for(OpportunityLineItem oppItem : newList){
        String key = String.valueOf(mapOppIdQuoteId.get(oppItem.OpportunityId)) +'~'+
                     String.valueOf(oppItem.PricebookEntryId) + '~' +
                     String.valueOf(oppItem.Description);
        //+ '~' +String.valueOf(oppItem.Description) + '~' + String.valueOf(oppItem.Quantity) ;
        system.debug('============= : key==================' + Key);
        oppPBEtoOLIMap.put(key, oppItem);
        UniquePBEntryIds.add(oppItem.PricebookEntryId);
      }
      OpportunityLineItem oppItem;
      for(QuoteLineItem quoteItem :[SELECT Id, QuoteId, Vehicle__c, Quantity__c, UnitPrice, Transfer_expense_paid_by__c,
                                        Transfer_expense_included__c, Approved_Ryder_Finance_Vendor_Date__c, Warranty__c,
                                        Category__c, Financing__c, Interest_Rate__c, Term__c, Down_Payment__c, Book_Value__c,
                                        Customer_Offer_Price__c, Take_Price2__c, Gain_Loss__c, SAM_Class__c, Quantity,
                                        Model_Year__c, Approved_Price__c, Vosa__c, PricebookEntryId, ListPrice,Finance_Company__c,
                                        TotalPrice, Subtotal, Down_Payment_Percent__c,Miscellaneous_Fee__c,
                                        Sales_Tax__c,Warranty_Amount__c,Document_Fee_del__c,
                                        Warranty_Provider__c, Description 
                                      FROM QuoteLineItem
                                      WHERE QuoteId in :mapOppIdQuoteId.values()
                                      AND PricebookEntryId in :UniquePBEntryIds
                                      ]){
        if(!oppPBEtoOLIMap.isEmpty()){
          String key = String.valueOf(quoteItem.QuoteId) +'~'+
                       String.valueOf(quoteItem.PricebookEntryId) + '~' +
                       String.valueOf(quoteItem.Description);
          // + '~' +  String.valueOf(quoteItem.Description) + '~' + String.valueOf(quoteItem.Quantity);
          oppItem = oppPBEtoOLIMap.get(key);
          system.debug('========== : key==========' + key);
          system.debug('========== : oppItem==========' + oppItem);
          system.debug('========== : quoteItem==========' + quoteItem);
          if(oppItem <> null){
            copyValuesToOLI(quoteItem, oppItem);
          }

        }

      }

    }
    catch(Exception ex){
        system.debug('QuoteLineItemTriggerHandler.syncOppLineItemsOnInsert(): An exception occurred while processing the request. Exception message ='+
                     ex.getMessage() +  '. \n Stacktrace = ' + ex.getStackTraceString());
    }
  }

  private static void copyValuesToQLI(QuoteLineItem quoteItem, OpportunityLineItem oppItem){
    quoteItem.Quantity__c = oppItem.Quantity__c;
    quoteItem.UnitPrice = oppItem.UnitPrice;
    quoteItem.Transfer_expense_paid_by__c = oppItem.Transfer_expense_paid_by__c;
    quoteItem.Transfer_expense_included__c = oppItem.Transfer_expense_included__c;
    quoteItem.Approved_Ryder_Finance_Vendor_Date__c = oppItem.Approved_Ryder_Finance_Vendor_Date__c;
    quoteItem.Warranty__c = oppItem.Warranty__c;
    quoteItem.Category__c = oppItem.Category__c;
    quoteItem.Financing__c = oppItem.Financing__c;
    quoteItem.Interest_Rate__c = oppItem.Interest_Rate__c;
    quoteItem.Term__c = oppItem.Term__c;
    quoteItem.Down_Payment__c = oppItem.Down_Payment__c;
    quoteItem.Down_Payment_Percent__c = oppItem.Down_Payment_Percent__c;
    quoteItem.Customer_Offer_Price__c = oppItem.Customer_Offer_Price__c;
    quoteItem.Vehicle__c = oppItem.Unit_Number__c;
    quoteItem.Approved_Price__c = oppItem.Approved_Price__c;
    quoteItem.Quantity = oppItem.Quantity;
    quoteItem.Take_Price2__c = oppItem.Take_Price2__c;
    quoteItem.Finance_Company__c = oppItem.Finance_Company__c;
    quoteItem.Miscellaneous_Fee__c = oppItem.Miscellaneous_Fee__c;
    quoteItem.Sales_Tax__c = oppItem.Sales_Tax__c;
    quoteItem.Warranty_Amount__c = oppItem.Warranty_Amount__c;
    quoteItem.Warranty_Provider__c = oppItem.Warranty_Provider__c;
    quoteItem.Document_Fee_del__c = oppItem.Document_Fee__c;
  }

  private static void copyValuesToOLI(QuoteLineItem quoteItem, OpportunityLineItem oppItem){
    oppItem.Quantity__c = quoteItem.Quantity__c;
      oppItem.UnitPrice = quoteItem.UnitPrice;
      oppItem.Transfer_Expense_Paid_By__c = quoteItem.Transfer_Expense_Paid_By__c;
      oppItem.Transfer_Expense_Included__c = quoteItem.Transfer_Expense_Included__c;
      oppItem.Approved_Ryder_Finance_Vendor_Date__c = quoteItem.Approved_Ryder_Finance_Vendor_Date__c;
      oppItem.Warranty__c = quoteItem.Warranty__c;
      oppItem.Category__c = quoteItem.Category__c;
      oppItem.Financing__c = quoteItem.Financing__c;
      oppItem.Interest_Rate__c = quoteItem.Interest_Rate__c;
      oppItem.Term__c = quoteItem.Term__c;
      oppItem.Down_Payment__c = quoteItem.Down_Payment__c;
      oppItem.Down_Payment_Percent__c = quoteItem.Down_Payment_Percent__c;
      oppItem.Customer_Offer_Price__c = quoteItem.Customer_Offer_Price__c;
      oppItem.Unit_Number__c = quoteItem.Vehicle__c;
      oppItem.Approved_Price__c = quoteItem.Approved_Price__c;
      oppItem.Quantity = quoteItem.Quantity;
      oppItem.Take_Price2__c = quoteItem.Take_Price2__c;
      oppItem.Finance_Company__c = quoteItem.Finance_Company__c;
      oppItem.Miscellaneous_Fee__c = quoteItem.Miscellaneous_Fee__c;
      oppItem.Sales_Tax__c = quoteItem.Sales_Tax__c;
      oppItem.Warranty_Amount__c = quoteItem.Warranty_Amount__c;
      oppItem.Warranty_Provider__c = quoteitem.Warranty_Provider__c;
      oppItem.Document_Fee__c = quoteitem.Document_Fee_del__c;
  }

  //-----------------------------------------------------------------------------------------------
  //  Sync Quote Line Items to Opportunity Line Items for UVS On QLI Update
  //-----------------------------------------------------------------------------------------------
  public static void syncOppLineItems(Map<Id, QuoteLineItem> mapOld, Map<Id, QuoteLineItem> mapNew){
    system.debug('=================QLIOLISyncManager.isSynced========' + QLIOLISyncManager.isSynced);
        system.debug('=================Synced OLI========');
        
        if(ManageStartSync.isUpdatingFromOpportunity == true){
        	return;
        }
        
        QLIOLISyncManager.isSynced = true;
        try{
        // find Relative Quote Line Items.
        Map<String, QuoteLineItem> mapUniqueItems = new Map<String, QuoteLineItem>();
        Set<Id> vehicleIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();

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
                                where Id in : mapNew.keySet()
                                and quote.Opportunity.RecordType.DeveloperName = 'UVS_Opportunity'
                                and quote.Opportunity.isClosed = false
                                and Vehicle__c != null
                                and quote.isSyncing = true]){
            // check if quote item was updated or not
            if(checkIfQuoteItemChanged(qli, mapOld.get(qli.Id))){
                String key = qli.Quote.OpportunityId + '~' + qli.PriceBookEntryId + '~' +
                       String.valueOf(qli.Description);
                mapUniqueItems.put(key, qli);
                oppIds.add(qli.Quote.OpportunityId);
                vehicleIds.add(qli.Vehicle__c);
                system.debug('::qli key::'+key);
//                system.debug('::qli::'+qli.quote.isSyncing);
            }
        }

        List<OpportunityLineItem> lstOppItemsToUpdate = new List<OpportunityLineItem>();
        QuoteLineItem quoteItem;
        system.debug('------oppIds in Handler-----'+oppIds);
        system.debug('--------vehicleIds in Handler-----'+vehicleIds);
        for(OpportunityLineItem oppItem :[SELECT Id, OpportunityId, UnitPrice, Description,PricebookEntryId
                                        FROM OpportunityLineItem
                                        WHERE OpportunityId in :oppIds
                                        AND Unit_Number__c in :vehicleIds]){
          String key = String.valueOf(oppItem.OpportunityId) + '~' + String.valueOf(oppItem.PriceBookEntryId)+ '~' +
                       String.valueOf(oppItem.Description);
          system.debug('::oppItem Key::'+key);              
          quoteItem = mapUniqueItems.get(key);
          // if opp item matches with the quote, perform sync
          if(quoteItem != null){
            copyValuesToOLI(quoteItem, OppItem);
            lstOppItemsToUpdate.add(oppItem);
          }

        }
        System.debug('Update OppLI >>> @@@' + lstOppItemsToUpdate);
        if(!lstOppItemsToUpdate.isEmpty()){
            update lstOppItemsToUpdate;
        }
        }catch(Exception ex){
            String message = 'QuoteLineItemTriggerHandler.syncOppLineItems(): An exception occurred while processing the request. Exception message = ' + ex.getMessage();
            system.debug(message + '\n Stacktrace = ' + ex.getStackTraceString());
            throw ex;                 
        }
  }

  // check if below fields on a Quote Item has been updated or not.
  private static Boolean checkIfQuoteItemChanged(QuoteLineItem newItem, QuoteLineItem oldItem){
    if(newItem.Quantity__c <> oldItem.Quantity__c || newItem.Quantity <> oldItem.Quantity || newItem.UnitPrice <> oldItem.UnitPrice ||
       newItem.Transfer_Expense_Paid_By__c <> oldItem.Transfer_Expense_Paid_By__c || newItem.Warranty__c <> oldItem.Warranty__c ||
       newItem.Transfer_Expense_Included__c <> oldItem.Transfer_Expense_Included__c ||
       newItem.Approved_Ryder_Finance_Vendor_Date__c <> oldItem.Approved_Ryder_Finance_Vendor_Date__c ||
       newItem.Category__c <> oldItem.Category__c || newItem.Financing__c <> oldItem.Financing__c ||
       newItem.Interest_Rate__c <> oldItem.Interest_Rate__c || newItem.Interest_Rate__c <> oldItem.Interest_Rate__c ||
       newItem.Term__c <> oldItem.Term__c || newItem.Down_Payment_Percent__c <> oldItem.Down_Payment_Percent__c ||
       newItem.Book_Value__c <> oldItem.Book_Value__c || newItem.Customer_Offer_Price__c <> oldItem.Customer_Offer_Price__c 
       || newItem.Down_Payment__c <> oldItem.Down_Payment__c || newItem.Finance_Company__c <> oldItem.Finance_Company__c||
       newItem.Take_Price2__c <> oldItem.Take_Price2__c || newItem.Gain_Loss__c <> oldItem.Gain_Loss__c ||
       newItem.SAM_Class__c <> oldItem.SAM_Class__c || newItem.Model_Year__c <> oldItem.Model_Year__c ||
       newItem.Approved_Price__c <> oldItem.Approved_Price__c || newItem.Vosa__c <> oldItem.Vosa__c||
       newItem.Miscellaneous_Fee__c <> oldItem.Miscellaneous_Fee__c || newItem.Sales_Tax__c <> oldItem.Sales_Tax__c
       || newItem.Vehicle__c <> oldItem.Vehicle__c  || newItem.Warranty_Amount__c <> oldItem.Warranty_Amount__c
       || newItem.Warranty_Provider__c <> oldItem.Warranty_Provider__c 
       ||newItem.Document_Fee_del__c <> oldItem.Document_Fee_del__c
    )
    {
        system.debug('================= TRUE =====');
        return true;


    }else{
        system.debug('================= FALSE =====');
        return false;
    }
  }

  //-----------------------------------------------------------------------------------------------
  //  Sync Opportunity Line Items to Quote Line Items for UVS
  //-----------------------------------------------------------------------------------------------
  public static void syncQuoteLineItems(Map<Id, OpportunityLineItem> mapOld, Map<Id, OpportunityLineItem> mapNew){
    System.debug('@@@###');
        
        if(ManageStartSync.isUpdatingFromOpportunity == true){
        	return;
        }
        
        QLIOLISyncManager.isSynced = true;
        try{
            // find Relative Quote Line Items.
            Map<String, OpportunityLineItem> mapUniqueItems = new Map<String, OpportunityLineItem>();
            Set<Id> vehicleIds = new Set<Id>();
            Set<Id> quoteIds = new Set<Id>();

            for(OpportunityLineItem oli : [Select o.Warranty__c, o.Vosa__c,  o.Unit_Number__c,
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
                                    where Id in : mapNew.keySet()
                                    and Unit_Number__c != NULL
                                    and Opportunity.isClosed = false
                                    and Opportunity.SyncedQuoteId != NULL
                                    and Opportunity.RecordType.DeveloperName = 'UVS_Opportunity']){
          // check if opp item was updated or not
            System.debug('@@@###' + oli);
            if(checkIfOppItemChanged(oli, mapOld.get(oli.Id))){
            System.debug('@@@###');
            system.debug('===========oli=========' + oli);
            String key = oli.Opportunity.SyncedQuoteId + '~' + oli.PriceBookEntryId+ '~' +
                       String.valueOf(oli.Description);
            mapUniqueItems.put(key, oli);
            quoteIds.add(oli.Opportunity.SyncedQuoteId);
            vehicleIds.add(oli.Unit_Number__c);
            }
        }

        List<QuoteLineItem> lstQuoteItemsToUpdate = new List<QuoteLineItem>();
        OpportunityLineItem oppItem;
        for(QuoteLineItem quoteItem :[SELECT Id, QuoteId, Vehicle__c,PricebookEntryId,UnitPrice, Description 
                                    FROM QuoteLineItem
                                    WHERE QuoteId in : quoteIds
                                    AND Vehicle__c in :vehicleIds]){
          String key = String.valueOf(quoteItem.QuoteId) + '~' + String.valueOf(quoteItem.PriceBookEntryId)+ '~' +
                       String.valueOf(quoteItem.Description);
          oppItem = mapUniqueItems.get(key);
          // if opp item matches with the quote, perform sync
          if(oppItem != null){
            copyValuesToQLI(quoteItem, oppItem);
            lstQuoteItemsToUpdate.add(quoteItem);
          }
      }
        System.debug('@@@' + lstQuoteItemsToUpdate);
        if(!lstQuoteItemsToUpdate.isEmpty()){
            update lstQuoteItemsToUpdate;
        }
        }catch(Exception ex){
            String message = 'QuoteLineItemTriggerHandler.syncQuoteLineItems(): An exception occurred while processing the request. Exception message = ' + ex.getMessage();
            system.debug(message + '\n Stacktrace = ' + ex.getStackTraceString());
            throw ex;
        }

  }

  // check if below fields on a Opp Item has been updated or not.
  private static Boolean checkIfOppItemChanged(OpportunityLineItem newItem, OpportunityLineItem oldItem){
    if(newItem.Quantity__c <> oldItem.Quantity__c         || newItem.Quantity <> oldItem.Quantity
    || newItem.Warranty__c <> oldItem.Warranty__c         || newItem.Category__c <> oldItem.Category__c
    || newItem.Financing__c <> oldItem.Financing__c       || newItem.Interest_Rate__c <> oldItem.Interest_Rate__c
    || newItem.Term__c <> oldItem.Term__c                 || newItem.Down_Payment_Percent__c <> oldItem.Down_Payment_Percent__c
    || newItem.Book_Value__c <> oldItem.Book_Value__c     || newItem.Customer_Offer_Price__c <> oldItem.Customer_Offer_Price__c
    || newItem.Finance_Company__c <> oldItem.Finance_Company__c || newItem.Miscellaneous_Fee__c <> oldItem.Miscellaneous_Fee__c
    || newItem.Take_Price2__c <> oldItem.Take_Price2__c   || newItem.UnitPrice <> oldItem.UnitPrice
    || newItem.Gain_Loss__c <> oldItem.Gain_Loss__c       || newItem.Unit_Number__c <> oldItem.Unit_Number__c
    || newItem.SAM_Class__c <> oldItem.SAM_Class__c       || newItem.Model_Year__c <> oldItem.Model_Year__c
    || newItem.Approved_Price__c <> oldItem.Approved_Price__c || newItem.Down_Payment__c <> newItem.Down_Payment__c
    || newItem.Vosa__c <> oldItem.Vosa__c
    || newItem.Transfer_Expense_Paid_By__c <> oldItem.Transfer_Expense_Paid_By__c
    || newItem.Transfer_Expense_Included__c <> oldItem.Transfer_Expense_Included__c
    || newItem.Approved_Ryder_Finance_Vendor_Date__c <> oldItem.Approved_Ryder_Finance_Vendor_Date__c
    || newItem.Sales_Tax__c <> oldItem.Sales_Tax__c || newItem.Unit_Number__c <> oldItem.Unit_Number__c
    || newItem.Warranty_Amount__c <> oldItem.Warranty_Amount__c
    || newItem.Warranty_Provider__c <> oldItem.Warranty_Provider__c
    || newItem.Document_Fee__c <> oldItem.Document_Fee__c


    ){
        system.debug('================= TRUE =====');
        return true;
    }else{
        return false;
    }
}
	// As per discussion with Franklin we have dicided to use Description field to make a link b/w OLI and QLI records under an Opportunity
	public static void UpdateOLIDescriptionField(List<OpportunityLineItem> newList)
	{
		for(OpportunityLineItem Obj : newList)
		{
			system.debug('--------------Obj.OppRecordTypeName__c----->'+Obj.OppRecordTypeName__c);
			if(Obj.OppRecordTypeName__c == 'UVS Opportunity')
				Obj.Description = Obj.Unit_Number__c;
		}
	}

}