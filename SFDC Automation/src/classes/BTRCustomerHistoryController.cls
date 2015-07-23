/**=====================================================================
 * Appirio, Inc
 * Name: BTR_List
 * Description: T-324750: Create New VF Page to Display Specific Previous BTR for Customer Name
 * Created Date: 09/10/2014
 * Created By: [Rahul Aeran] (Appirio)
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 =====================================================================*/
public without sharing class BTRCustomerHistoryController{

    // Public Valriables
    public string vehNumber {get;set;}
    public string customerName {get;set;}
    public string btrId {get;set;}
    public List<QuoteLineItemHistory__c> quoteLIHistoryList{get;set;}
    public list<BTR_History__c> lstBTRList {get;set;}

    // Constructor
    public BTRCustomerHistoryController(){
        vehNumber = ApexPages.currentPage().getParameters().get('vehNumber');
        customerName  = ApexPages.currentPage().getParameters().get('customerName');
        btrId = ApexPages.currentPage().getParameters().get('btrId');
        populateBTRList();
    }

   // Method to fetch list of BTR History based on vehicle number.
    public void populateBTRList(){
        if(vehNumber != null){
            
            lstBTRList = [SELECT Vehicle_Number__c,SAM_Class__c,Year__c,Make_Model__c,Location__c,Days_At_UTC__c,Engine_Make_Model__c,Mileage__c,NVI_Percent__c
                                        ,Book_Value__c,Take_Price__c,Offer_Price_Sale_Price__c,Take_Price_percent__c,Gain_Loss__c,As_Is_Vehicle__c,
                                        VOSA__c,Approved_Price__c,Approved_to_take__c, UTC__c 
                                        FROM BTR_History__c
                                        WHERE Vehicle_Number__c = :vehNumber];
            // Get Quote Line Items Record based on vehicle
            Set<Id> quoteLineItemIds = new Set<Id>();
            for(QuoteLineItem qli :[Select Id
                        From QuoteLineItem
                        where Vehicle__r.Name = :vehNumber ]){
                quoteLineItemIds.add(qli.Id);
            }
            quoteLIHistoryList = [SELECT Name,LastModifiedDate,LastModifiedBy.Name
                                    FROM QuoteLineItemHistory__c
                                    WHERE Quote_Line_Item__c IN: quoteLineItemIds];
           
           
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Invalid Vehicle Number.'));
        }
    }

    

   
}