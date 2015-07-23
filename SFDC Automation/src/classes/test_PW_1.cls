@isTest
private class test_PW_1 {
    public List<PartialWinRateSheet__c> partialWinRateSheet {get;set;}
    public ApexPages.StandardSetController stdPartialWinController {get;set;}

//PW Ratesheet
static testMethod void PWRatesheet_test() {    
    PWRateSheet pw = new PWRateSheet();
    PWRateSheet.ClosePartialWinTask('testoppty');
}

static testMethod void PWRelocateOpportunities_test() {
    PWRelocateOpportunities pw = new PWRelocateOpportunities();           
    PWRelocateOpportunities.RequestData met1 = new PWRelocateOpportunities.RequestData();
    PWRelocateOpportunities.ProcessRequestResponse_element met2 = new PWRelocateOpportunities.ProcessRequestResponse_element();   
    PWRelocateOpportunities.PartialWinRequestCriteria  met3 = new PWRelocateOpportunities.PartialWinRequestCriteria();
    PWRelocateOpportunities.CRMCredential met4 = new PWRelocateOpportunities.CRMCredential();
    PWRelocateOpportunities.DCPartialWin met5 = new PWRelocateOpportunities.DCPartialWin();
    PWRelocateOpportunities.ProcessRequest_element met7 = new PWRelocateOpportunities.ProcessRequest_element();
    PWRelocateOpportunities.ArrayOfDCPartialWin  met8 = new PWRelocateOpportunities.ArrayOfDCPartialWin();
    PWRelocateOpportunities.ResponseData met9 = new PWRelocateOpportunities.ResponseData();
    //PWRelocateOpportunities.PWRelocateOpportunitiesSoap met10 = new PWRelocateOpportunities.PWRelocateOpportunitiesSoap();    
}
}