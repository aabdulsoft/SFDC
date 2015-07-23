public with sharing class DealSummaryVO {
    
    public Deal_Summary__c dealSummary {get; set;}
    
    public List<Rate_Sheet__c> rateSheetsAssociatedWithDS {get; set;}
    
    static testMethod void test_DealSummaryVO() {
        
        DealSummaryVO dsVO = new DealSummaryVO();
        dsVO.dealSummary = new Deal_Summary__c();
        dsVO.rateSheetsAssociatedWithDS = new List<Rate_Sheet__c>();
        
        system.assertEquals(dsVO.dealSummary, new Deal_Summary__c());
        system.assertEquals(dsVO.rateSheetsAssociatedWithDS, new List<Rate_Sheet__c>());
    }
}