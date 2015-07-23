/**=====================================================================
 * Appirio, Inc
 * Name: BTR_List
 * Description: T-324750: Create New VF Page to Display Previous BTR List for a Given Vehicle
 * Created Date: 08/10/2014
 * Created By: [Rahul Agrawal] (Appirio)
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 =====================================================================*/
public with sharing class BTRVehicleHistoryController{
  // Public Valriables
  public string vehNumber {get;set;}
  public string btrId{get;set;}
  public List<BTRWrapper> wrapperList {get;set;}

  // HK (02/24/2015): The 'showBackToBTR' variable will control whether to show the 'Back to BTR' button or now.
  public boolean showBackToBTR { get; set; }
  
  // Constructor
  public BTRVehicleHistoryController(){
    vehNumber = ApexPages.currentPage().getParameters().get('vehNumber');
    btrId = ApexPages.currentPage().getParameters().get('BTRId');
    // HK (02/24/2015): if btrid is null, then the user is accessing the vehicle history directly from the tab, instead from 'Prev BTR'; hence no need to show the 'Back to BTR button.
    if(btrId != null)
        showBackToBTR = true;
    else
        showBackToBTR = false;
    
    populateBTRList();
  }
  
  // Method to fetch list of BTR History based on vehicle number.
  public void populateBTRList(){
    if(vehNumber != null){
      wrapperList = new List<BTRWrapper>();
      
      // Fetch records from BTR History to display historical data.
      List<BTR_History__c> lstBTRList = [SELECT Id, Customer_Name__c,Requestor__c,Request_Date__c,UTC__c, BTR_Status__c,Approved_Price__c, 
                    Offer_Price_Sale_Price__c, BTR_Number__c, BTR_Number__r.Name, Quote_Number__c
                    FROM BTR_History__c
                    WHERE Vehicle_Number__c = :vehNumber];
      
      
      for(BTR_History__c obj :lstBTRList){
        BTRWrapper objWrapper = new BTRWrapper();
        objWrapper.btrId = obj.BTR_Number__c;
        objWrapper.btrNumber = obj.BTR_Number__r.Name;
        objWrapper.customerName = obj.Customer_Name__c;
        objWrapper.requestor = obj.Requestor__c;
        objWrapper.requestDate = obj.Request_Date__c.format('MM/dd/yyyy');
        objWrapper.utc = obj.Utc__c;
        objWrapper.status = 'Approved';
        objWrapper.offerPrice = obj.Offer_Price_Sale_Price__c;
        objWrapper.approvedPrice = obj.Approved_Price__c;
        wrapperList.add(objWrapper);
      }
      
      // Fetch records from Quote Line Item History for current BTR's
      Map<Id, List<QuoteLineItem>> mapQuoteLineItems = new Map<Id, List<QuoteLineItem>>();
      BTRVehicleHistoryInnerClass ObjInnerClass = new BTRVehicleHistoryInnerClass();
      for(QuoteLineItem qli : ObjInnerClass.QueryQuoteLineItem(vehNumber))
      {
        if(mapQuoteLineItems.containsKey(qli.QuoteId) == false){
            mapQuoteLineItems.put(qli.QuoteId, new List<QuoteLineItem>());
        }
        mapQuoteLineItems.get(qli.QuoteId).add(qli);    
      }
      System.debug('@@@' + mapQuoteLineItems);
      
      // Find related Quote's BTR's from above result and display information from both BTR and QLI.
      List<BTR__c> lstBTR = [SELECT Ryder_Branch__r.Name, Owner.Name, CreatedDate, Status__c, Requester_Comments__c, Quote__c, OwnerId, Name, LastModifiedDate, LastModifiedById, 
                             Is_Conditional_Approval__c, Id, Customer_Name__c 
                             FROM BTR__c b WHERE Quote__c = :mapQuoteLineItems.keySet()
                             AND Status__c != 'Approved'];
      
      System.debug('@@@' + lstBTR);
      for(BTR__c objBTR :lstBTR){
        for(QuoteLineItem qli :mapQuoteLineItems.get(objBTR.Quote__c)){
          BTRWrapper objWrapper = new BTRWrapper();
          objWrapper.btrId = objBTR.Id;
          objWrapper.btrNumber = objBTR.Name;
          objWrapper.approvedPrice = qli.Approved_Price__c;
          objWrapper.offerPrice = qli.Customer_Offer_Price__c;
          objWrapper.utc = objBTR.Ryder_Branch__r.Name;
          objWrapper.status = objBTR.Status__c;
          objWrapper.requestDate = objBTR.CreatedDate.format('MM/dd/yyyy');
          objWrapper.requestor = objBTR.Owner.Name;
          objWrapper.customerName = qli.Quote.Opportunity.Account.Name;
          wrapperList.add(objWrapper);
        }
      }
      System.debug('@@@' + wrapperList);
      
      if(wrapperList.size() == 0){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No BTR Record is found.'));
      }
    }
  }

  // Method to initiate search for BTR history record based on vehicle number entered by User and clicked on Go button
  public void searchBTRList(){
    populateBTRList();
  }
  
  // Wrapper class for displaying final results on UI
  public class BTRWrapper{
    public String btrNumber {get; set;}
    public String customerName {get;set;}
    public String requestor {get;set;}
    public String requestDate {get;set;}
    public String utc {get;set;}
    public String status {get;set;}
    public Id btrId {get;set;}
    public Decimal offerPrice{get;set;} 
    public Decimal approvedPrice{get;set;}
  }
  public without sharing class BTRVehicleHistoryInnerClass
  {
		public List<QuoteLineItem> QueryQuoteLineItem(String vehNumber)
		{
			List<QuoteLineItem> lQuoteLineItem = [SELECT Id, QuoteId, Quote.Opportunity.Account.Name, 
													Customer_Offer_Price__c, Approved_Price__c 
													FROM QuoteLineItem WHERE Vehicle__r.Name = :vehNumber];
			return lQuoteLineItem;
		}
  }
}