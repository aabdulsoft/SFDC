/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class RSMCreateTestData
{
    public static testMethod void GetCustomSettingsRecord()
    {
    	// TO DO: implement unit test
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
		RyderConfig.RYDERSMART_RSS__C = 'etluser@ryder.com';
		RyderConfig.RYDERSMART_Billing__c = 'etluser@ryder.com';
		insert RyderConfig;
    }
}