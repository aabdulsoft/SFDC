@isTest
public class UpdOppDataOnLeadReferralHelperTest{
   
    static testmethod void UnitTest() 
    {
        RyderConfig__c RyderConfig = RyderConfig__c.getOrgDefaults();
    
        RyderConfig.NAME = 'a0OP00000008dJo';
        RyderConfig.CURRENCYISOCODE = 'USD';
        RyderConfig.ACCURACY_MAPPING__C = '10=0.994,9=0.985,8=0.973,7=0.963,6=0.943,5=0.803,4=0.453,3=0.403,2=0.253,1=0.0344';
        RyderConfig.DNB_PASSWORD__C = 'rtr2006z';
        RyderConfig.DNB_USERID__C = 'ryderprod';
        RyderConfig.NUMBEROFRECORDSTODISPLAY__C = 20;
        RyderConfig.RYDER_WS_ENDPOINT__C = 'https://salesforce.ryder.com/crmservices/';
        RyderConfig.CONTACT_HTMLID__C = 'CF00N600000029MZg';
        RyderConfig.CONTACT_HTML_LKID__C = 'CF00N600000029MZg_lkid';
        RyderConfig.CUSTOMER_BRANCH_HTMLID__C = 'CF00N600000029MVq';
        RyderConfig.CUSTOMER_BRANCH_HTML_LKID__C = 'CF00N600000029MVq_lkid';
        RyderConfig.CONTACTTOCUSTOMERBRANCHS_RLID__C = '00N600000029MZg';
        RyderConfig.CUSTOMERBRANCHKEYCONTACT_RLID__C = '00N600000029MVq';
        RyderConfig.CUTOFF_ACCURACY_PROBABILITY__C = 50;
        RyderConfig.ETL_USERNAME__C = 'etluser@ryder.com';
        RyderConfig.LEAD_STATUS_FOR_CONVERT__C = 'Qualified,SQL';
        RyderConfig.RADAR_DS_NEW_LINK__C = 'http://ride/Ryder/Applications/Bluesky/DealSummary/CreateDealSummary.aspx?tabindex=3&tabid=4&ComingFromSearch=True&ViewModeRequested=0';
        RyderConfig.RADAR_RS_EDIT_LINK__C = 'http://ride/Ryder/Applications/Bluesky/RateSheet/ProductSelection.aspx?tabindex=2&tabid=3&ComingFromSearch=True&ViewModeRequested=0';
        RyderConfig.RADAR_RS_NEW_LINK__C = 'http://ride/Ryder/Applications/Bluesky/RateSheet/CreateRateSheet.aspx?tabindex=2&tabid=3&ComingFromSearch=True&ViewModeRequested=0';
        RyderConfig.RYDER_AUTH_ENDPOINT__C = '/RyderAuthenticationService.asmx';
        RyderConfig.RYDER_SURVEY_PDF_ENDPOINT__C = 'https://na4-api.salesforce.com/services/Soap/class/RyderSurveyPDFContent';
        RyderConfig.RYDER_SURVEY_PDF_RECIPIENTS__C = 'rydercsi@ryder.com';
        RyderConfig.FOLLOWUPSURVEYUSER__C = '00560000001Ngkw';
        RyderConfig.DUPLICATE_CASE_EMAIL_RECIPIENT__C = 'Gregory_Blitz@ryder.com';
        RyderConfig.DUPLICATE_CASE_EXCLUDED_CUSTOMERS__C = 'CASH ONLY CUSTOMER - PURE RENTAL,RYDER';
        RyderConfig.PERFORM_NAME_CHECK__C = TRUE;
        RyderConfig.DATA_COMCLEANUSER__C = 'automatedclean';
        //RyderConfig.RYDERSMART_RSS__C = 'etluser@ryder.com';
        //RyderConfig.RYDERSMART_Billing__c = 'etluser@ryder.com';
        RyderConfig.TruckTypes__c = 'Dry Trailer,Flatbed Trailer,Refrigerated Trailer';
         
        if(RyderConfig.Id == null)
            insert RyderConfig;
        else
            update RyderConfig;

        Account acc = new Account();
        acc.name = 'Test Account';    
        acc.ShippingState = RyderGlobalVariables.TEST_STATE_CANADA;        
        acc.ShippingCountry = RyderGlobalVariables.COUNTRIES_USA;        
        insert acc;        
        
        Contact c = New Contact (); 
        c.FirstName = 'TestFirst'; 
        c.LastName = 'TestLast'; 
        c.email = 'TestContact@test.com';
        c.accountId = acc.Id;
        c.Contact_Source__c = 'Lead Conversion';
        insert c;
        
        Opportunity Opp1 = New Opportunity();
        Opp1.Name = 'Test Opp 1';
        Opp1.AccountId = Acc.id;
        Opp1.Original_Decision_Maker__c = c.Id;
        Opp1.StageName = 'Overcome Concerns';
        Opp1.CloseDate = Date.Today();
        insert Opp1;
        
        Opportunity Opp2 = New Opportunity();
        Opp2.Name = 'Test Opp 2';
        Opp2.AccountId = Acc.id;
        Opp2.Original_Decision_Maker__c = c.Id;
        Opp2.StageName = 'Overcome Concerns';
        Opp2.CloseDate = Date.Today();
        insert Opp2;
        
        Lead_Referral__c leadRef1 = New Lead_Referral__c();
        leadRef1.FMS_Account_Name_LU__c = acc.id;
        leadRef1.FMS_Opportunity_Name__c = Opp1.id;
        insert leadRef1;
        
        Lead_Referral__c leadRef2 = New Lead_Referral__c();
        leadRef2.FMS_Account_Name_LU__c = acc.id;  
        insert leadRef2;
        
        Test.startTest();
        
        leadRef1.FMS_Opportunity_Name__c = Opp2.id;
        update leadRef1;
        
        leadRef2.FMS_Opportunity_Name__c = Opp1.id;
        update leadRef2;
        
        Opp2.StageName = 'Weigh Solution Options';
        update Opp2;
            
        Test.stopTest();
    } 
}