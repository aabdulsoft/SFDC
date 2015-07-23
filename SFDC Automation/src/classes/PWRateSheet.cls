/************************************************************************************
 *  Date            Name          Description
 * --------   --------------    ----------------
 * 3/25/2014    Saad Wali Jaan    For displaying the PartialWinrateSheet data         
 *************************************************************************************/

/*
* This class is defined to be a controller to the page PWRateSheet page
*/

public with sharing class PWRateSheet
{
    public List<PartialWinRateSheet__c> partialWinRateSheet {get;set;}
    public Opportunity oppInfo {get; set;}
    public Opportunity opportunityInfo {get; private set;}
    
    public String sortOrder {get;set;}
    public String sortField {get;set;}
    public Boolean dontSave = false;
    public String rsStatus = '';
    public Boolean isSubmit = false;
    
    public ApexPages.StandardSetController stdPartialWinController {get;set;}
    
    public List<PartialWinRateSheet__c> getPagePartialWinData()
    {
        return stdPartialWinController.getRecords();
    }
    
    public PWRateSheet(){}
            
    public PWRateSheet(ApexPages.StandardController stdController) 
    {
        this.oppInfo = (Opportunity)stdController.getRecord();
        opportunityInfo = (Opportunity)stdController.getRecord();
        
        if(oppInfo.Id!=null)
        {
            oppInfo = [select id, Name, ext_pipeline_id__c, StageName, Original_Decision_Maker__c, PartialWinRateSheetStatus__c, PartialWinLostReason__c, PartialWinDealLostToWonFrom__c, PartialWinRateSheetCompetitor__c, PartialWinIncumbent__c, PartialWinLocalProvider__c from Opportunity where id=: oppInfo.id ];
        }
        
        searchPartialWinData();
    }
    
    public void searchPartialWinData()
    {
        stdPartialWinController = new ApexPages.StandardSetController(new List<PartialWinRateSheet__c>());
        stdPartialWinController = new ApexPages.StandardSetController(Database.getQueryLocator(
        [Select p.IsSelected__c, p.Rate_Sheet__c, p.Rate_Sheet_Name__c, p.Deal_Summary__c, p.Deal_Summary_Name__c, p.Opportunity__c, p.Status__c, Reason_Won_Lost__c, Deal_lost_to_Won_from_whom__c, Competitor__c, Was_this_competitor_the_incumbent__c, Local_Provider_Name__c from PartialWinRateSheet__c p where Opportunity__c =:oppInfo.id and IsProcessed__c = false order by Deal_Summary__c, Rate_Sheet__c]));
        system.debug('stdPartialWinController.getResultSize() = ' + stdPartialWinController.getResultSize());
        stdPartialWinController.setPageSize(stdPartialWinController.getResultSize());
    }
     
    public PageReference doSave()
    {
        dontSave = false;
        rsStatus = '';
        
        Map<String, String> DS_Status = new Map<String, String>();
        
        partialWinRateSheet = stdPartialWinController.getRecords();
        
        for (PartialWinRateSheet__c pwrs: partialWinRateSheet)
        {
            if(isSubmit && pwrs.Status__c == null){
                dontSave = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.error, 'Please select a status');
                ApexPages.addmessage(mymsg);
            }
            
            if (DS_Status.isEmpty() && pwrs.Deal_Summary__c != '')
            {
                DS_Status.put(pwrs.Deal_Summary__c, pwrs.Status__c);
            }
            else
            {
                if (pwrs.Deal_Summary__c != '' && pwrs.Deal_Summary__c != null)
                {
                    if (DS_Status.containsKey(pwrs.Deal_Summary__c))
                    {
                        rsStatus = DS_Status.get(pwrs.Deal_Summary__c);
                        If (rsStatus != pwrs.Status__c)
                        {
                            dontSave = true;
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.error, 'Please choose same status for all the Rate Sheets for Deal Summary # ' + pwrs.Deal_Summary__c);
                            ApexPages.addmessage(mymsg);
                        }
                    }
                    else
                    {
                        DS_Status.put(pwrs.Deal_Summary__c, pwrs.Status__c);
                    }
                }
            }
            
            if(pwrs.Status__c == 'Lost')
            {
                if(opportunityInfo.PartialWinLostReason__c == null)
                {
                    dontSave = true;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.error, 'Please choose Lost reason ');
                    ApexPages.addmessage(mymsg);
                }
                else
                {
                    pwrs.Reason_Won_Lost__c = opportunityInfo.PartialWinLostReason__c;
                    pwrs.Deal_lost_to_Won_from_whom__c = opportunityInfo.PartialWinRateSheetCompetitor__c;
                    pwrs.Competitor__c = opportunityInfo.PartialWinDealLostToWonFrom__c;
                    pwrs.Was_this_competitor_the_incumbent__c = opportunityInfo.PartialWinIncumbent__c;
                    pwrs.Local_Provider_Name__c = opportunityInfo.PartialWinLocalProvider__c;
                    pwrs.IsSelected__c = false;
                }
            }
            else
            {
                pwrs.Reason_Won_Lost__c = '';
                pwrs.Deal_lost_to_Won_from_whom__c = '';
                pwrs.Competitor__c = '';
                pwrs.Was_this_competitor_the_incumbent__c = '';
                pwrs.Local_Provider_Name__c = '';
                pwrs.IsSelected__c = false;
            }   
        }
        if(dontSave == false)
        {
            update partialWinRateSheet;
        }
        
        //// Send the user to the detail page for the response.
        //PageReference saveResult = ApexPages.currentPage().setRedirect(dontSave);
        
        return null;
    }
    
    public PageReference doSubmit()
    {
        isSubmit = true;
        doSave();
        
        system.debug('aaaaa dontSave 1: ' + dontSave);
        
        if(dontSave == true){
            system.debug('aaaaa dontSave 2: ' + dontSave);
            return null;
        }
        system.debug('aaaaa dontSave 3: ' + dontSave);
        
        system.debug('aaaaa opp Id: ' + oppInfo.Id);
        
        //Create new opportunity(s)
        List<PartialWinRateSheet__c> partialWinResults = RelocateOpportunities.CreateOpportunityFromPartialWin(oppInfo.Id);
        system.debug('albert partialWinResults: ' + partialWinResults);
        
        RelocateRateSheets(partialWinResults);
        ClosePartialWinTask(oppInfo.Id);
        
        //Redirect user to results page
        PageReference redirectResult = new PageReference('/apex/PWRateSheet_Result');
        redirectResult.setRedirect(true);
        
        return redirectResult;
    }
    
    public void RelocateRateSheets(List<PartialWinRateSheet__c> partialWinResults){
        
        //Convert data to JSON
        String partialWinResultJSON = JSON.serialize(partialWinResults);
        
        //Move (partial win) ratesheet(s) in Radar
        RelocateRateSheets.MoveRateSheetsInRadarFuture(partialWinResultJSON, oppInfo.Id);

        //Extract Opportunity Id's to refresh them
        ExtractAndRefreshNewOpportunityIds(partialWinResults);
    }
    
    public void ExtractAndRefreshNewOpportunityIds(List<PartialWinRateSheet__c> partialWinResults){
        
        //List<PartialWinRateSheet__c> newOppIds = new List<PartialWinRateSheet__c>();
        String opptyIdToRefresh = null;
        
        for (PartialWinRateSheet__c pw :partialWinResults){
            if(pw.Opportunity__c != opptyIdToRefresh){
                ////Add to list so an Update can be performed
                //newOppIds.add(pw);
                //Call the @future refresh for this new opportunity
                System.debug('aaaaaaa new oppty refresh' + pw.Opportunity__c);                
                RelocateRateSheets.RefreshNewOpportunityFuture(pw.Opportunity__c);
            }
            opptyIdToRefresh = pw.Opportunity__c;
        }
    }
    
    public void UpdateMovedRSDS(List<PartialWinRateSheet__c> refreshedOpptys){
        
        //Update each opportunity to all "Include_In_Quote=true"
        for (PartialWinRateSheet__c opp :refreshedOpptys){
            Opportunity oppty = new Opportunity();
            oppty.Id = opp.Opportunity__c;
            oppty.Included_in_Monthly_Forecast__c = true;
            oppty.Included_in_Quarterly_Forecast__c = true;
        }
    }
    
    public static void ClosePartialWinTask(String oppId){
        //Close the Task related to this partial win
        CreateTaskPartialWin.ClosePartialWinTask(oppId);
        System.debug('aaaaaaa pw task closed');
    }  
    
    
    static testMethod void test_PWRateSheet(){
        
        Test.startTest();
        
        ClosePartialWinTask('123456');
        
        //List<PartialWinRateSheet__c> refreshedOpptys = new List<PartialWinRateSheet__c>();
        //UpdateMovedRSDS(refreshedOpptys);
        
        //PageReference pageRef = Page.success;
        //Test.setCurrentPage(pageRef);
        //oppsplitcontroller controller = new oppsplitcontroller(New ApexPages.StandardController(o));
        
        
        //Test.setCurrentPage(doSubmit());
        
        Test.stopTest();
    }
 
}