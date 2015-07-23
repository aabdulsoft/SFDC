/**=============================================================================
 * Created By: Nimisha (Appirio, Inc)
 * Created Date: [09/23/2014]
 * Description: Controller for inLine VF Page in Opportunity related list.


==============================================================================*/
public with sharing class UVS_OLIRelatedList {
  public ApexPages.StandardSetController sc {get; set;}
  public Id deleteRecordId{get;set;}
  public Opportunity opp{get;set;}
  public List<OpportunityLineItem> oliList{get;set;}

  public UVS_OLIRelatedList(ApexPages.StandardController sc) {
    this.opp = (Opportunity)sc.getRecord();
     fetchRecords(opp);
  }
  private void fetchRecords(Opportunity opp){

    //AAK 03/10/2015 Start - updated the odometer__c to SAM_Odom__c
    oliList = [Select o.Unit_Number__c, o.Eng_Mdl__c, o.NVI_Percent__c, o.ServiceDate,o.Quantity, o.Make_Model__c, o.Branch_Name__c,
                o.ListPrice,o.Description, o.Vosa__c, o.UnitPrice, o.Take_Price_percent__c, o.Take_Price2__c, o.SAM_Class__c,
                 o.Model_Year__c, o.Gain_Loss__c, o.Days_held__c, o.Book_Value__c, o.Approved_to_take__c, o.Approved_Price__c,
                 o.Unit_Number__r.Name, o.Unit_Number__r.NVI__c, o.Unit_Number__r.Branch_Name__c, o.Unit_Number__r.SAM_Odom__c,
                 o.Unit_Number__r.AS_IS_Vehicle__c, o.NVI__c
               From OpportunityLineItem o
               WHERE o.OpportunityId = :opp.Id];


  }

  public PageReference deleteRecord(){
    list <OpportunityLineItem> olidel = [Select Id from OpportunityLineItem where id = :deleteRecordId] ;
    if(!olidel.isEmpty()) {
      delete olidel;
    }


    return null;
  }


}