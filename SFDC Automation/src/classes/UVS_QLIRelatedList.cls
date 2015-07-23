/**=============================================================================
 * Created By: Nimisha (Appirio, Inc)
 * Created Date: [09/24/2014]
 * Description: Controller for inLine VF Page in Quote related list. (T-321414)


==============================================================================*/
public with sharing class UVS_QLIRelatedList {

  public ApexPages.StandardSetController sc {get; set;}
  public Id deleteRecordId{get;set;}
  public Quote quote{get;set;}
  public List<QuoteLineItem> qliList{get;set;}
  public list<QliColorCode> qliColorList{get;set;}
  public UAT_Total uatTotal{get;set;}
  public QuoteLineItem totalOfAllItems{get;set;}
  public Vehicle__c vehicleTemp{get;set;}

  public UVS_QLIRelatedList(ApexPages.StandardController sc) {
    this.quote = (Quote)sc.getRecord();
    uatTotal = new UAT_Total();
    vehicleTemp = new Vehicle__c();
    totalOfAllItems = new QuoteLineItem();
    fetchRecords(quote);
  }
  private void fetchRecords(Quote quote){
    qliColorList = new list<QliColorCode>();
    //AAK 03/10/2015 Start - updated the odometer__c to SAM_Odom__c
    for(QuoteLineItem qli:[Select ServiceDate, NVI_Percent__c, Make_Model__c, Eng_Mdl__c, Quantity, ListPrice, Description, Vosa__c,
                            UnitPrice, Take_Price2__c, SAM_Class__c,
                            Model_Year__c, Gain_Loss__c, Days_held__c, Book_Value__c, Approved_to_take__c, Approved_Price__c, BankOfAmerica__c,
                            SpecialPrice__c, Display_Code__c, NonCompliantCAUnits__c, Overstock__c, Meq_sale_prc_am__c, Vehicle__c, Vehicle__r.Name,
                            Vehicle__r.NVI__c, Vehicle__r.Branch_Name__c, Vehicle__r.SAM_Odom__c, Take_Price_percent__c, Vehicle__r.AS_IS_Vehicle__c,
                            NVI__c, Vehicle__r.Sold_Flag__c, AS_IS_Vehicle__c 
                           From QuoteLineItem
                           WHERE QuoteId = :quote.Id]) {
      qliColorList.add(new QliColorCode(qli,false));
      
      if(qli.NVI_Percent__c != null){
        uatTotal.total_NVI += qli.NVI__c;
      }
      if(qli.Book_Value__c != null){
        uatTotal.total_BookValue += qli.Book_Value__c;
      }
      if(qli.UnitPrice != null){
        uatTotal.total_SalesPrice += qli.UnitPrice;
      }
      
      if(qli.Take_Price2__c != null){
        uatTotal.total_TakePrice += qli.Take_Price2__c;
      }
      
      
      if(qli.Gain_Loss__c != null){
        uatTotal.total_GainLoss += qli.Gain_Loss__c;
      }
      
      if(qli.Approved_Price__c != null){
        uatTotal.total_ApprovedPrice += qli.Approved_Price__c;
      }
      
    }
    
    QuoteLineItem lastRowDummyItem = new QuoteLineItem();
    qliColorList.add(new QliColorCode(lastRowDummyItem,true));
    
    vehicleTemp.NBV__c = uatTotal.total_BookValue;
    vehicleTemp.Ask_Price__c = uatTotal.total_SalesPrice;
    totalOfAllItems.Take_Price2__c =  uatTotal.total_TakePrice;
    totalOfAllItems.Customer_Offer_Price__c = uatTotal.total_GainLoss;
    totalOfAllItems.Approved_Price__c = uatTotal.total_ApprovedPrice;
    
    
    Decimal d= 0.0;
    
    if(uatTotal.total_NVI != 0){
      d = (uatTotal.total_SalesPrice/uatTotal.total_NVI)*100;
      uatTotal.total_NVIPer = d.setScale(2);
    }
    
    if(uatTotal.total_TakePrice != 0){
      d = (uatTotal.total_SalesPrice/uatTotal.total_TakePrice)*100;
      uatTotal.total_TakePricePer = d.setScale(2);
    }
    
    if(uatTotal.total_TakePrice != 0){
      d = (uatTotal.total_ApprovedPrice/uatTotal.total_TakePrice)*100;
      uatTotal.total_ApprovedPerofTake = d.setScale(2);
    }


  }

  public PageReference deleteRecord(){
    list <QuoteLineItem> qlidel = [SELECT Id
                                   FROM QuoteLineItem
                                   WHERE id = :deleteRecordId] ;
    if(!qlidel.isEmpty()) {
        delete qlidel;
    }
    return null;
  }

 // Wrapper class used in visualforce page to display Totals
  public class UAT_Total{
    public Double total_NVI{get;set;}
    public Double total_NVIPer{get;set;}
    public Double total_BookValue{get;set;}
    public Double total_SalesPrice{get;set;}
    public Double total_TakePrice{get;set;}
    public Double total_TakePricePer{get;set;}
    public Double total_GainLoss{get;set;}
    public Double total_ApprovedPrice{get;set;}
    public Double total_ApprovedPerofTake{get;set;}
    
    public UAT_Total(){
      this.total_NVI=0.0;
      this.total_NVIPer = 0.0;
      this.total_BookValue = 0.0;
      this.total_SalesPrice = 0.0;
      this.total_TakePrice = 0.0;
      this.total_TakePricePer = 0.0;
      this.total_GainLoss = 0.0;
      this.total_ApprovedPrice = 0.0;
      this.total_ApprovedPerofTake = 0.0;
    }
  }

  // Wrapper class used in visualforce page to display result
  public class QliColorCode {
    public QuoteLineItem qliWrap{get;set;}
    public String color{get;set;}
    public boolean isLastRow{get;set;}
    public QliColorCode(QuoteLineItem qli,Boolean isLastRow) {
      qliWrap = qli;
      color = getColorCode(qli,isLastRow);
      this.isLastRow = isLastRow;
    }

    // helper method to get color code
     private String getColorCode(QuoteLineItem q,boolean isLastRow) {
      String colorCode = '#E0E0E0';
      if(isLastRow){
        colorCode = 'cadetblue';
        return colorCode;
      }
      
      if(q.OverStock__c <> false) {
        colorCode = '#00cc00';
      }
      
      if(q.SpecialPrice__c <> null && q.SpecialPrice__c <> 0.00) {
        colorCode = '#ccffff';
      }

      //if(q.Display_Code__c == true) {
        //colorCode = '#ffff99';
      //}
      
      if(q.AS_IS_Vehicle__c == true) {
        colorCode = '#ffff99';
      }

      if(q.Vehicle__r.Sold_Flag__c != NULL && q.Vehicle__r.Sold_Flag__c) {
        colorCode = '#FF3333';
      }

      if(q.BankOfAmerica__c == true) {
        colorCode = '#FF8040';
      }

      if(q.NonCompliantCAUnits__c  == true) {
        colorCode = '#7fe57f';
      }
      
      return colorCode ;
    }
  }
}