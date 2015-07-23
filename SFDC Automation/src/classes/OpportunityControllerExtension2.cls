// 09/10/2014 : MG : Updated the code for S-255606
public without sharing class OpportunityControllerExtension2 {
    public Opportunity oppty {get; set;}

    public Id opptyId {get; set;}

    //Ram -12/28 added isTest for unit test support
    public boolean isTest = false;

    private boolean validOppty;

    public String currentIPAddress{get; set;}

    public List<Deal_Summary__c> dealSummaries {get; private set;}
    public List<Rate_Sheet__c> rateSheets {get; private set;}
    public List<Rate_Sheet__c> rateSheetsNotAssociatedWithDS {get; private set;}
    public List<DealSummaryVO> dealSummaryVOList {get; private set;}
    private Map<Id, DealSummaryVO> mapOfDS;

    private boolean saveIncludeToQuote = false;

    public String rateSheetLink {get; set;}

    public String dealSummaryLink {get; set;}
    public String newRateSheetLink {get; set;}
    public String editRateSheetLink {get; set;}

    // 09/10/2014: MG : S-255606 : Get rate sheet details only for non UVS Opportunities
    public boolean nonUVS{get;set;}
    
    //public Boolean showMaxRecordMessage {get; set;}

    public OpportunityControllerExtension2(ApexPages.StandardController stdController) {

        this.oppty = (Opportunity)stdController.getRecord();

        String strValidOppty = ApexPages.currentPage().getParameters().get('validOppty');
        validOppty = false;
        if (strValidOppty != null && strValidOppty.length() > 0) {
            validOppty = Boolean.valueOf(strValidOppty);
        }
        System.debug(LoggingLevel.INFO, '************************* validOppty:' + validOppty);
        init();
    }

    public void init()
    {
        System.debug('*********** Start OpptyRelatedRatesAndDealsController **************');
        this.currentIPAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        //this.opptyId = ApexPages.currentPage().getParameters().get('id');
        this.opptyId = oppty.Id;
        if (this.opptyId != null) {
        // 09/10/2014: MG : S-255606 : Added recordtype.Name
        this.oppty = [Select o.Id, o.account.CustProspectID__c, o.account.int_CustProspectID__c, o.Name, o.CloseDate, o.StageName, o.RecordType.Name,
        	(Select Id, ext_ratesheet_id__c, Name, Rate_Sheet_Name__c, Product_Line__c, Package_Type__c, Gross_Revenue__c,
            No_of_Vehicles__c, EVA__c, Include_In_Quote__c, Deal_Summary__c From Rate_Sheets__r),
            (Select Id, opportunity__r.account.CustProspectID__c, opportunity__r.account.int_CustProspectID__c, Name, ext_dealsummary_id__c, Include_In_Quote__c, Status__c, EVA__c, No_of_Vehicles__c, Gross_Revenue__c
            From Deal_Summaries__r)
            From Opportunity o where o.Id =:this.opptyId];
        }
        // 09/10/2014 : MG : S-255606 : check the Opportunity type based on record type
        nonUVS = true;
        if(oppty.recordType.Name.contains('UVS')){
        	nonUVS = false;
        }
        buildLinks();
        System.debug('*********** End OpptyRelatedRatesAndDealsController **************');
    }

    /*
    * Create links for Rate Sheet/Deal Summary in RADAR
    */
    private void buildLinks() {
        Account opptyAccount = this.oppty.Account;
        String custProspectId = '';
        if (opptyAccount != null && opptyAccount.int_CustProspectID__c != null) {
            custProspectId = opptyAccount.int_CustProspectID__c;
        }
        this.newRateSheetLink = RyderGlobalVariables.NEW_RATE_SHEET_LINK +
            '&CustProspId=' + custProspectId + 'NOTENCODED' +
           '&OpportunityId=' + this.opptyId + 'NOTENCODED' +
           '&BackToScreen=' + EncodingUtil.urlEncode(ApexPages.currentPage().getUrl(), 'UTF-8');

       this.editRateSheetLink = RyderGlobalVariables.EDIT_RATE_SHEET_LINK +
            '&CustProspId=' + custProspectId + 'NOTENCODED' +
           '&OpportunityId=' + this.opptyId + 'NOTENCODED' +
           '&BackToScreen=' + EncodingUtil.urlEncode(ApexPages.currentPage().getUrl(), 'UTF-8');

       this.dealSummaryLink = RyderGlobalVariables.NEW_DEAL_SUMMARY_LINK +
            '&CustProspId=' + custProspectId + 'NOTENCODED' +
            '&OpportunityId=' + this.opptyId + 'NOTENCODED' +
           '&BackToScreen=' + EncodingUtil.urlEncode(ApexPages.currentPage().getUrl(), 'UTF-8');

    }

    /*
    *   Retrieve all Deal Summaries and Rate Sheets associated with the opportunity and then update opportunity totals
    */
    public PageReference retrieveRateSheetsAndDealSummaries() {
        // 09/10/2014 : MG : S-255606 : rate sheet callout has to be made only for non UVS Opportunities.
        if(nonUVS){
        PageReference result = null;
        System.debug(LoggingLevel.INFO, '+++++++++++++++++++++ Inside retrieveRateSheetsAndDealSummaries');
        if (this.saveIncludeToQuote == false) {
          try {
               if (validOppty == true ){
                   // only retrieve rate sheets/ deal summary info if oppty is not lost/won
                    //if(!isTest && (this.oppty.StageName != RyderGlobalVariables.OpportunitySatgeName.Booked.name() && this.oppty.StageName != RyderGlobalVariables.OpportunitySatgeName.Signed.name()
                    //   && this.oppty.StageName != RyderGlobalVariables.OpportunitySatgeName.Lost.name())){
                        OpportunityDSAndRSVO tempMap = DealSummaryRateSheetUtil.SyncDealSummaryAndRateSheetForOpportunity(this.oppty.Id);
                        if (tempMap != null ) {
                            this.dealSummaries = tempMap.dealSummariesList;
                            System.debug(LoggingLevel.INFO, '+++++++++++++++++++++ this.dealSummaries:' + this.dealSummaries);
                            this.rateSheets = tempMap.rateSheetsList;
                            getDSAndRS();
                        }
                    //}
                    List<Id> opptyIds = new List<Id>();
                    opptyIds.add(this.oppty.Id);
                    OpportunityUtil.updateOpportunityTotals(opptyIds);
               } else {
                if (validateOppty(oppty)) {
                    result = new PageReference('/apex/OpptyDetail2?validOppty=true&id=' + this.opptyId);
                    result.setRedirect(true);
                }
               }
           } catch (DMLException ex) {
                 ApexPages.Message msgError = new ApexPages.Message(ApexPages.Severity.Error, ex.getDmlMessage(0));
                 ApexPages.addMessage(msgError);
           } catch (Exception ex) {
                 ApexPages.Message msgError = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
                 ApexPages.addMessage(msgError);
           } finally {
           }
        }
        System.debug(LoggingLevel.INFO, '+++++++++++++++++++++ Exiting retrieveRateSheetsAndDealSummaries');
        System.debug(LoggingLevel.INFO, '+++++++++++++++++++++ result: ' + result);
        getCanEditRecord();
        return result;
        }
        return null;
    }

    private boolean validateOppty(Opportunity oppty) {

    	System.debug(LoggingLevel.INFO, 'fffffffffffffffffffffff validateOppty:' + oppty);
        Boolean result = true;
      //  upsert oppty;
        return result;
    }

    /*
    *
    */
    public void getDSAndRS() {
           if (this.oppty != null) {
            mapOfDS = new Map<Id, DealSummaryVO>();
            if (this.dealSummaries  != null) {
               this.dealSummaryVOList = new List<DealSummaryVO>();
               
               for (Deal_Summary__c ds : this.dealSummaries) {
                   DealSummaryVO temp = new DealSummaryVO();
                   temp.dealSummary = ds;
                   temp.rateSheetsAssociatedWithDS = new List<Rate_Sheet__c>();
                   // this.dealSummaryVOList.add(temp);
                   mapOfDS.put(ds.Id, temp);
               }
            }
            if (this.rateSheets != null) {
               rateSheetsNotAssociatedWithDS = new List<Rate_Sheet__c>();
               
               /* 
               	Added by Albert Miranda - 1/5/2015 - QC# - limit the record size to avoid overloading page 
               
               System.debug(LoggingLevel.INFO, '++++++++++++ rateSheets size:' + rateSheets.size());
               if(rateSheets.size() > 1) {
               		//Display 'reached max record count' message
               		//showMaxRecordMessage = true;
               }
               */
               integer i = 0;
               
               for (Rate_Sheet__c tempRS: this.rateSheets) {
                if (tempRS.Deal_Summary__c == null) {
                    rateSheetsNotAssociatedWithDS.add(tempRS);
                } else {
                    DealSummaryVO temp = mapOfDS.get(tempRS.Deal_Summary__c);
                    List<Rate_Sheet__c> tempRSs = temp.rateSheetsAssociatedWithDS;
                    tempRSs.add(tempRS);
                    temp.rateSheetsAssociatedWithDS = tempRSs;
                    System.debug(LoggingLevel.INFO, '++++++++++++ tempRSList:' + tempRSs);
                    mapOfDS.put(temp.dealSummary.Id, temp);
                }
                i++;
                System.debug(LoggingLevel.INFO, '++++++++++++ rateSheets loop end:' + i);
                if(i == 1) { 
               		//break; 
                }
               }
            }
            this.dealSummaryVOList = mapOfDS.values();
            System.debug(LoggingLevel.INFO, '++++++++++++ mapOfDS:' + mapOfDS);
            System.debug(LoggingLevel.INFO, '++++++++++++ mapOfDS:' + mapOfDS.values());
        }
        System.debug(LoggingLevel.INFO, '++++++++++++ Oppty:' + this.oppty);
        System.debug(LoggingLevel.INFO, '++++++++++++ dealSummaryVOList:' + this.dealSummaryVOList);
    }

    Public PageReference backtoOppty() {
        PageReference page = new PageReference('/' + this.opptyId);
        return page;
    }

    Public PageReference updateDSAndRS() {
        if ((this.dealSummaryVOList != null && this.dealSummaryVOList.size() > 0) ||
           (this.rateSheets != null && this.rateSheets.size() > 0)) {
            this.saveIncludeToQuote = true;
            PageReference page = new PageReference('/' + this.opptyId);
            System.debug(LoggingLevel.INFO, '++++++++++++++++++++ inside update: ' + this.dealSummaryVOList);
            List<Deal_Summary__c> updatedDS = new List<Deal_Summary__c>();

            //get the latest DS as ID might have been modified
            List<Deal_Summary__c> recentDS = [Select Id, opportunity__r.account.CustProspectID__c, Name, ext_dealsummary_id__c, Include_In_Quote__c, Status__c, EVA__c, No_of_Vehicles__c, Gross_Revenue__c
                From Deal_Summary__c where Opportunity__c =: this.opptyId];

            Map<Decimal, Deal_Summary__c> mapExtIDToDS = new Map<Decimal, Deal_Summary__c>();

            for(DealSummaryVO dsVO: this.dealSummaryVOList){
               mapExtIDToDS.put(dsVO.dealSummary.ext_dealsummary_id__c, dsVO.dealSummary);
            }

            for (Deal_Summary__c tempDS: recentDS){
                 Deal_Summary__c oldDS = mapExtIDToDS.get(tempDS.ext_dealsummary_id__c);
                 if (oldDS != null) {
                    tempDS.Include_In_Quote__c = oldDS.Include_In_Quote__c;
                 }
                 updatedDS.add(tempDS);
            }

            if (updatedDS.size() > 0) {
                update updatedDS;
                this.dealSummaries = updatedDS;
            }

            //get the latest RS as ID might have been modified
            List<Rate_Sheet__c> updatedRS = new List<Rate_Sheet__c>();
            List<Rate_Sheet__c> recentRS = [Select Id, Name, Rate_Sheet_Name__c, Product_Line__c, Package_Type__c, Gross_Revenue__c,
                No_of_Vehicles__c, EVA__c, Include_In_Quote__c,
                Deal_Summary__c, ext_ratesheet_id__c  From Rate_Sheet__c where Opportunity__c =: this.opptyId];

            Map<Decimal, Rate_Sheet__c> mapExtIDToRS = new Map<Decimal, Rate_Sheet__c>();

            for(Rate_Sheet__c tempRS: this.rateSheets){
               mapExtIDToRS.put(tempRS.ext_ratesheet_id__c, tempRS);
            }

            for (Rate_Sheet__c tempRS: recentRS){
                 Rate_Sheet__c oldRS = mapExtIDToRS.get(tempRS.ext_ratesheet_id__c);
                 if (oldRS != null && oldRS.Deal_Summary__c == null) {
                    tempRS.Include_In_Quote__c = oldRS.Include_In_Quote__c;
                 }
                 updatedRS.add(tempRS);
            }

            if (updatedRS.size() > 0) {
                update updatedRS;
                this.rateSheets = updatedRS;
            }

            //refresh the DS and RS
            getDSAndRS();
           }
        //return page;
        PageReference pageref = new PageReference('/apex/OpptyDetail2?id=' + this.opptyId);
        pageref.setRedirect(true);
        return pageref;
    }

    public List<Rate_Sheet__c> getRateSheetAsscoiatedToDS(String dsId) {
        System.debug(LoggingLevel.INFO, '++++++++++++++++++++ start of getRateSheetAsscoiatedToDS');
        List<Rate_Sheet__c> result = new List<Rate_Sheet__c>();
        return result;
    }

    private boolean editable = null;

    public boolean getCanEditRecord(){
        //return true;
        //return (ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP')=='65.244.148.222');
        if (this.editable == null){
            innertester it = new innertester();
            List<String> editResults = it.testObject('Opportunity', this.oppty.Id);

            if (editResults.size()> 0 && editResults[0] == this.oppty.Id)
                this.editable = true;
            else
                this.editable = false;

        }

        return this.editable;
    }

    public boolean showRecord = false;
    public boolean getCanBeShown(){

        if(this.editable && (this.oppty.StageName != RyderGlobalVariables.OpportunitySatgeName.Booked.name() && this.oppty.StageName != RyderGlobalVariables.OpportunitySatgeName.Signed.name()
                                   && this.oppty.StageName != RyderGlobalVariables.OpportunitySatgeName.Lost.name())){
     		this.showRecord = true;
        }
        return this.showRecord;
    }

    //    public boolean getCanBeShown(){
    //    if(getCanEditRecord() && (this.oppty.StageName != RyderGlobalVariables.OpportunitySatgeName.Booked.name() && this.oppty.StageName != RyderGlobalVariables.OpportunitySatgeName.Signed.name()
    //                               && this.oppty.StageName != RyderGlobalVariables.OpportunitySatgeName.Lost.name())){
    // 		this.showRecord = true;
    //    }
    //    return this.showRecord;
    //}


    public with sharing class innertester {
    public String[] testObject(String objectName, Id ida){
    Map<String, String> ids_map = new Map<String, String>();
    String []editableIds = null;
    List<ID> lid = new List<ID>();

    String soql = 'select id from ' + objectName + ' where id in (\'' + ida + '\')';
    system.debug(soql);

    sobject []so = database.query(soql);

    Savepoint sp = Database.setSavepoint();

    database.saveresult []sr = null;
    try{
    sr = database.update(so, false);
    system.debug('++++SR++++: '+sr);
    }catch(exception e){
    system.debug('++++SR++++: '+sr);
    }

    if (sr!= null){
        for(integer x=0;x<sr.size();x++){
            if (sr[x].isSuccess())
                lid.add(sr[x].getId());
        }

    editableIds = new string[lid.size()];
    for(integer x=0;x<editableIds.size();x++)
        editableIds[x] = lid.get(x);
    }
    System.debug('++++EditableIds++++: '+editableIds);
    Database.rollback(sp);
    return editableIds;
 }
    }

 }