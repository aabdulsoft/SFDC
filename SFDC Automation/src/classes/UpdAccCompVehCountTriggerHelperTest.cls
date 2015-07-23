@isTest
public class UpdAccCompVehCountTriggerHelperTest {

    //static User accUser = createUser(true);
    
    static testmethod void UnitTest() 
    {
        //system.runAs(accUser) 
        //{ 
            //RSMCreateTestData.GetCustomSettingsRecord();
            
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

        system.debug('UpdAcc0 - lTrucks = ' + RyderConfig__c.getOrgDefaults().TruckTypes__c.split(','));
        List<string> lTrucks = RyderConfig__c.getOrgDefaults().TruckTypes__c.split(',');

        Account pa = new Account();
        pa.name = 'Test Parent Account';    
        pa.ShippingState = RyderGlobalVariables.TEST_STATE_CANADA;        
        pa.ShippingCountry = RyderGlobalVariables.COUNTRIES_USA;        
        insert pa;
        
        Account ca = new Account();
        ca.name = 'Test Child Account';    
        ca.ShippingState = RyderGlobalVariables.TEST_STATE_CANADA;        
        ca.ShippingCountry = RyderGlobalVariables.COUNTRIES_USA;
        ca.ParentId = pa.id;        
        insert ca;        
        
        Competitor_Vehicle__c cv1 = New Competitor_Vehicle__c(); 
        cv1.Class__c = 'Stright Truck'; 
        cv1.Account__c = ca.Id;
        cv1.Vehicle_Count__c = 5;
        insert cv1;
        
        Competitor_Vehicle__c cv2 = New Competitor_Vehicle__c();  
        cv2.Class__c = 'Single Axle'; 
        cv2.Account__c = ca.Id;
        cv2.Vehicle_Count__c = 2;
        insert cv2;
        
        Competitor_Vehicle__c cv3 = New Competitor_Vehicle__c();  
        cv3.Class__c = 'Metro Van'; 
        cv3.Account__c = pa.Id;
        cv3.Vehicle_Count__c = 8;
        insert cv3;
        
        Competitor_Vehicle__c cv4 = New Competitor_Vehicle__c();  
        cv4.Class__c = 'Pick Up'; 
        cv4.Account__c = pa.Id;
        cv4.Vehicle_Count__c = 3;
        insert cv4;
        
        Test.startTest();
        
        Delete cv4;
        
        delete cv3;
            
        Test.stopTest();
    } 
    /*
    //create user
    private static User createUser(Boolean isInsert) {
        Profile p = [select p.id from Profile p LIMIT 1];

        //Creating the user
        User u = new User( Username = 'test@rydertest.com',
                                    Alias = 'test', FirstName = 'Ryder', LastName = 'Tester', Email = 'test@rydertest.com',
                                    EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocalesIdKey = 'en_US', 
                                    ProfileId = p.Id, TimeZonesIdKey = 'America/Los_Angeles', isActive = true);
        if(isInsert){
            insert u;
        }
        return u;
    }*/
}