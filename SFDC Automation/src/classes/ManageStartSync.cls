public with sharing class ManageStartSync {
	
	public static boolean isUpdatingFromOpportunity{get;set;}
	
	public ManageStartSync(){
		isUpdatingFromOpportunity = false;
	}
	
	public static void copyValuesToQLI(QuoteLineItem quoteItem, OpportunityLineItem oppItem){
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

  public static void copyValuesToOLI(QuoteLineItem quoteItem, OpportunityLineItem oppItem){
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
  	

}