public with sharing class OpportunityDSAndRSVO {
    public List<Deal_Summary__c> dealSummariesList {get; set;}
    public List<Rate_Sheet__c> rateSheetsList {get; set;}
    public List<Pipeline_Detail__c> pipelineDetailsList {get; set;}
    public List<Opportunity_Split__c> opportunitySplitsListCUSTOM {get; set;}
    public List<OpportunityLineItem> opportunityProductLineItem {get; set;}    
    
    static testMethod void test_OpportunityDSAndRSVO(){
        OpportunityDSAndRSVO temp = new OpportunityDSAndRSVO();
        temp.dealSummariesList = new List<Deal_Summary__c>();
        temp.rateSheetsList = new List<Rate_Sheet__c>();
        List<Deal_Summary__c> resultDS = temp.dealSummariesList;
        List<Rate_Sheet__c> resultRS = temp.rateSheetsList;
        system.assertEquals(resultDS, temp.dealSummariesList);
        system.assertEquals(resultRS, temp.rateSheetsList);
    }
}