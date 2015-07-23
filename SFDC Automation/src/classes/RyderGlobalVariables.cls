public with sharing class RyderGlobalVariables 
{
    public static Boolean IS_TEST = false;
    public static Boolean firstRun = true; 
    public static Boolean UPDATE_ACCOUNT_TRIGGER = true;
    public static final string RyderSmart_RSS = RyderConfig__c.getOrgDefaults().RyderSmart_RSS__c;
    public static final string RyderSmart_Billing = RyderConfig__c.getOrgDefaults().RyderSmart_Billing__c;
    // Custom Settings
    public static final String ACCURACY_MAPPING = RyderConfig__c.getOrgDefaults().Accuracy_Mapping__c;
    public static final String RYDER_Survey_PDF_ENDPOINT = RyderConfig__c.getOrgDefaults().Ryder_Survey_PDF_Endpoint__c;
    public static final String Ryder_Survey_PDF_Recipients = RyderConfig__c.getOrgDefaults().Ryder_Survey_PDF_Recipients__c;
    public static final Boolean PERFORM_NAME_CHECK = RyderConfig__c.getOrgDefaults().Perform_Name_Check__c;
    // Select options
    public static final String CREATE_NEW = 'CreateNew';
    public static final String CREATE_NEW_CONTACT = 'CreateNewContact';
    public static final String ATTACH_EXISTING = 'AttachExisting';
    public static final String FROM_DUNN_BRADSTREET = 'FromDunnAndBradstreet';
    
    public static final String CREATE_NEW_LABEL = 'Create New Account';
    public static final String CREATE_NEW_CONTACT_LABEL = 'Create New Contact';
    public static final String ATTACH_EXISTING_LABEL = 'Attach to existing';
    public static final String FROM_DUNN_BRADSTREET_LABEL = 'From Dunn And Brad street';

    // Converted status
   //public static final List<String> CONVERTED_STATUS = 'Qualified';
    public static final String ERROR_CONVERTING_LEADS = 'Error occurred while converting leads:\n\n';
    public static final String ERROR_SELECT_ACCOUNT = 'Please select an account to proceed!';
    public static final String EIGHT_AM = '480';
    public static final String TIME_NAME_VALUE = '0=12:00 AM,30=12:30 AM,60=1:00 AM,90=1:30 AM,120=2:00 AM,150=2:30 AM,180=3:00 AM,210=3:30 AM,240=4:00 AM,270=4:30 AM,300=5:00 AM'+
                                                 '330=5:30 AM,360=6:00 AM,390=6:30 AM,420=7:00 AM,450=7:30 AM,480=8:00 AM,510=8:30 AM,540=9:00 AM,570=9:30 AM,600=10:00 AM,630=10:30 AM'+
                                                 '660=11:00 AM,690=11:30 AM,720=12:00 PM,750=12:30 PM,780=1:00 PM,810=1:30 PM,840=2:00 PM,870=2:30 PM,900=3:00 PM,930=3:30 PM'+
                                                 '960=4:00 PM,990=4:30 PM,1020=5:00 PM,1050=5:30 PM,1080=6:00 PM,1110=6:30 PM,1140=7:00 PM,1170=7:30 PM,1200=8:00 PM,1230=8:30 PM'+
                                                 '1260=9:00 PM,1290=9:30 PM,1320=10:00 PM,1350=10:30 PM,1380=11:00 PM,1410=11:30 PM';
                                                 
    public static final String ACCOUNT_NAME = 'Name';
    public static final String ACCOUNT_TYPE = 'Type';
    public static final String ACCOUNT_LESSEE_NO = 'LesseeNo__c';
    public static final String ACCOUNT_INDUSTRY = 'Industry';
    public static final String ACCOUNT_CUST_TYPE_ID = 'CustomerTypeID__c';
    public static final String ACCOUNT_SITE_DUNS = 'Site_Duns__c';
    public static final String ACCOUNT_DUNS_HQ = 'DUNS_HQ__c';
    public static final String ACCOUNT_ULTIMATE_DUNS = 'Global_Ultimate_DUNS__c';
    public static final String ACCOUNT_NATL_RNTL_CUST_ID = 'NATL_RNTL_CUST_ID__c';

    public enum AccountRecordTypeName {Ryder_Parent_Account, Ryder_FMS_Branch_Account, Ryder_Rental_Account}
                                        
    public static final String COUNTRIES_USA = 'US';
    public static final String COUNTRIES_CANADA = 'CA';
    public static final String COUNTRIES_CANADA_TEXT = 'CANADA';
  
    public enum CustomerType {FMS, RIL, FMSRENTAL}

    public static final String DNB_USERID = RyderConfig__c.getOrgDefaults().DNB_UserId__c;  
    public static final String DNB_PASSWORD = RyderConfig__c.getOrgDefaults().DNB_Password__c;
    public static final Integer NUMBER_OF_RECORDS_PER_SEARCH = Math.round(RyderConfig__c.getOrgDefaults().NumberOfRecordsToDisplay__c);
    
    public static final String CUSTOMER_BRANCK_HTML_ID = RyderConfig__c.getOrgDefaults().Customer_Branch_HTMLID__c;
    public static final String CUSTOMER_BRANCK_HTML_LK_ID = RyderConfig__c.getOrgDefaults().Customer_Branch_HTML_LKID__c;
    
    public static final String CONTACT_BRANCK_HTML_ID = RyderConfig__c.getOrgDefaults().Contact_HTMLID__c;
    public static final String CONTACT_BRANCK_HTML_LK_ID = RyderConfig__c.getOrgDefaults().Contact_HTML_LKID__c;    
    
    // Business Verification web service calls 
    public static final String ORDER_PRODUCT_TYPE = 'D';
    public static final String ORDER_PRODUCT_BUSINESS_VERIFICATION = 'Business Verification';
    public static final String ORDER_USER_LANGUAGE = 'EN';
    public static final String ORDER_TRADE_UP_INDICATOR = 'N';
    public static final String IMMEDIATE_DELIVERY_MODE= 'DIRECT';
    public static final String IMMEDIATE_DELIVERY_FORMAT= 'XML';
    public static final String OK_STATUS_CODE = '0';
    
    // Corporate Linkage web service calls
    public static final String ORDER_PRODUCT_CORPORATE_LINKAGE = 'Corporate Linkage';
    
    //Worldbase Marketing Plus with Linkage calls
    public static final String ORDER_PRODUCT_WORLDBASE_MARKETING_PLUS_WITH_LINKAGE = 'Worldbase Marketing Plus with Linkage';
    
    //Vehical Rate Information
    public enum InfoType {Repair, Accident, Accomodation, Abuse, Special, Miscellaneous, Fuel}

    //Vehical Rate Information
    public static final String LOCATIONS_STATUS_HEADQUARTERS = 'HQ';
    public static final String LOCATIONS_STATUS_BRANCH = 'BR';
    public static final String BRANCH_INDICATOR_N = 'N';
    public static final String BRANCH_INDICATOR_Y = 'Y';
    public static final String CREATE_ACCOUNT = 'Create Account';
    public static final String CONVERT_LEAD = 'Convert Lead';
    
    // Account classifications
    public enum AccountClassification {Local, National, NationalCentralized, NationalDecentralized, Coordinated}
    //Amount Type Classification
    public static final String AMOUNT_TYPE_PERCENTAGE = 'P';
    public static final String AMOUNT_TYPE_FIXED = 'F';
    public static final String AMOUNT_TYPE_SET = 'S';
    // Test variables
    public static final String TEST_PRIMARY_NAME = 'Dade paper';
    public static final String TEST_PRIMARY_NAME_CANADA = 'ABC Group';
    public static final String TEST_DUNS_NUMBER = '12345678';
    public static final String TEST_CONF_CD = '1';
    public static final String TEST_ADDRESS_LINE = '123 Test drive';
    public static final String TEST_CITY = 'Test City';
    public static final String TEST_STATE = 'FL';
    public static final String TEST_STATE_CANADA = 'ON';
    public static final String TEST_TLCM_NBR = '1234';
    public static final String TEST_POST_CODE = '33378';
    public static final String TEST_CANADA_POST_CODE = 'A9A 9A9';
    public static final String TEST_COMPANY_TYPE = 'TEST';
    public static final String TEST_LESSEE_NO = '12345';
    public static final String TEST_INDUSTRY = 'Test Industry';
    public static final String TEST_CUST_PROSPECT_ID = '1234567890';
    public static final String TEST_SIC_CODE = '12345';
    public static final Integer TEST_COMPANY_ID = 12345;
    public static final String TEST_FIRST_NAME = 'Contact First Name'; 
    public static final String TEST_LAST_NAME = 'Contact Last Name'; 
    public static final String TEST_STATUS = 'Qualified';
    public static final String TEST_SOURCE = 'Advertisement';  
    public static final String TEST_TYPE_CUSTOMER = 'Customer';
    public static final String TEST_TYPE_PROSPECT = 'Prospect';
 
    // End Points for Ryder WS calls
    public static final String RYDER_WS_ENDPOINT = RyderConfig__c.getOrgDefaults().Ryder_WS_EndPoint__c;
    public static final String GET_RATE_SHEETS = 'GetRateSheets.asmx';
    public static final String GET_DEAL_SUMMARIES = 'GetDealSummaries.asmx';
    public static final String GET_COMPANIES = 'getCompanies.asmx';
    public static final String CREATE_COMPANIES = 'CreateCompany.asmx';
    public static final String UPDATE_COMPANIES = 'UpdateCompany.asmx';
    public static final String DELETE_COMPANY = 'DeleteCompany.asmx';
    public static final String GET_REBILLABLE_RATES = 'GetRebillableRates.asmx';
    public static final String GET_FUEL_RATES = 'GetFuelRates.asmx';
    public static final String GET_RENTAL_RATES = 'GetRentalRates.asmx';
    public static final String SEND_RYDER_EMAIL ='RyderEmailService.asmx';
    public static final String GET_OPPORTUNITY_LOCAL = 'GetOpportunityLocal.asmx';
    public static final String PW_RELOCATE_OPPORTUNITIES = 'PWRelocateOpportunities.asmx';    
    public static final String CREATE_SAM_COMPANY = 'CreateSAMCompany.asmx'; 
    public static final String GET_VEHICLE_REPAIR_REPORT = 'GetVehicleRepairReport.asmx'; 
    public static final Integer WS_TIMEOUT = 60000; //timeout for webservices call in milliseconds
    // cut-off accuracy probability
    public static final Double CUT_OFF_ACCURACY_PROBABILITY = RyderConfig__c.getOrgDefaults().Cutoff_Accuracy_Probability__c/100.00;   
    // Ryder Authrization Service End Point
    public static final String RYDER_AUTH_ENDPOINT = RyderConfig__c.getOrgDefaults().RYDER_AUTH_ENDPOINT__c;
    
    // Account Type
    public enum AccountType{Prospect, Customer}
    // Primary Contact Role 
    public enum PrimaryContactRole{CSI, Maintenance, Billing}
    
    //contact role Picklist values
    public static final String CSI_ROLE_TEXT = 'CSI Contact';
    public static final String MAINTENANCE_ROLE_TEXT = 'Maintenance Contact';
    public static final String BILLING_ROLE_TEXT = 'Billing';
    
    public static final String DUPLICATE_CUST_PROSPECT_ACCOUNT = 'Account with matching Customer Prospect Id found. Account Name - ';
    //Test Variables
    public static boolean rateSheetTest = false;
    
    public static final String EST_CLOSE_DATE_ERROR = 'Please select an Estimated Close Date in the future.';
    
    public static final String HQ_LOCATION = 'Headquarters';
    public static final String BR_LOCATION = 'Branch';
    public static final String SL_LOCATION = 'Single Location';
    
    public static final String I_WILL_UPDATE_LATER = 'I will update later';
    
    public enum LeadConversionAccountState{NewAccount,MatchFromDnB,ExistingSFDCAcct}
    public enum LeadConversionContactState{NewContact,ExistingSFDCContact,CreatedContact}
    
    
    // Related list ids
    public static final String CONTACT_TO_CUSTOMER_BRANCH_RLID = RyderConfig__c.getOrgDefaults().ContactToCustomerBranchs_rlid__c;
    public static final String CUSTOMER_BRANCH_TO_CONTACT_RLID = RyderConfig__c.getOrgDefaults().CustomerBranchKeyContact_rlid__c;
    
    //RADAR links
    public static final String NEW_RATE_SHEET_LINK = RyderConfig__c.getOrgDefaults().RADAR_RS_New_Link__c;
    public static final String EDIT_RATE_SHEET_LINK = RyderConfig__c.getOrgDefaults().RADAR_RS_Edit_Link__c;
    public static final String NEW_DEAL_SUMMARY_LINK = RyderConfig__c.getOrgDefaults().RADAR_DS_New_Link__c;
    
    // Oppty stagenames
    public enum OpportunitySatgeName{Booked, Signed, Lost}
    
    // Opportunity and Case Level Access
    public static final String READ_ACCESS = 'Read';
    public static final String WRITE_ACCESS = 'Edit';
    //AAK 03/10/2015 Start Added for Opportunity - UVS RCE
    public static final String PRIVATE_ACCESS = 'None';
    //AAK 03/10/2015 End
    
    // default key to use to get account role map
    public static final String DEFAULT_ACCOUNT_ROLE_MAP = 'Default';

    // default DnB Error Message
    public static final String DEFAULT_DnB_ERROR_MSG = 'Error calling D&B database. Please try again later or contact SalesAdmin@ryder.com to get this lead converted for you. Sorry for the inconvenience.';
    
    public static final String OUT_OF_BUS_ERROR_MSG = 'Lead cannot be converted because selected account is out of business. Please review the details of your lead or contact SalesAdmin@ryder.com to get this lead converted for you. Sorry for the inconvenience.';
    
    // Contact to Customer brach error messages
    public static final String UNIQUE_KEY_CONTACT_ERROR = 'Combination of Contact, Role and Branch must be unique. Another record with same Contact, Role, and Branch exists.';
        
    public static final String CONTACT_FOR_ALL_BRANCH_ERROR = 'Selected Contact Type for all Branches already exists. Please remove the existing Contact Type for all Branches before adding same contact type for an individual branch.';

    public static final String PRIMARY_CONTACT_FOR_BRANCH_ERROR = 'Another record with the same Role, Type and Branch exists.';
    
    public static final String CONTACT_DELETE_ACCESS_ERROR='Only administrators can delete all branch contacts. Please contact salesadmin.';
            
    public static final String LEAD_MUST_BE_IN_QUALIFIED_STATUS = 'Lead must be in Qualified or SQL status before it can be converted.';
    
    public static final List<String> LEAD_STATUS_FOR_CONVERT = RyderConfig__c.getOrgDefaults().Lead_Status_For_Convert__c.split(',');
    
    // Lead conversion page title
    public static final String LEAD_CONVERSION_PAGE_TITLE = 'Lead Conversion';
    public static final String CREATE_NEW_ACCOUNT_PAGE_TITLE = 'Create New';
    
    //BatchRenewals
    public static final Integer NATIONAL_CENTRALIZED_ACCOUNT_OWNER_SPLIT_PERCENTAGE = 50;
    
    // ETL User
    public static final string ETLUSER = RyderConfig__c.getOrgDefaults().ETL_Username__c;
    // neelima-april 12-2012- added contact source pick list values
    public enum ContactSource{Lead_Conversion,Manual}
     
    //FollowUpSurveyUser
    public static final string FOLLOWSURVEYUSER  = RyderConfig__c.getOrgDefaults().FollowUpSurveyUser__c;
    
    //Excluded Major Categories from Duplicate Case email alert
    public static final string EXCLUDED_MAJOR_CATEGORIES = 'Comdata Express Checks,Comdata / Comchecks,Fuel Billing/Fuel Tickets,Fuel Ticket Reprints,CS Research - Fuel Billing/Fuel Tickets,CS Research - Fuel Ticket Reprints,' + 
                                                            'Invoice Reprints,CS Research - Invoice Reprints,CS Research - Comdata Express Checks,Rebillables,Compliance Billing - Backup Request,CS Research - Rebillables';
    //Excluded Sub Categories from Duplicate Case email alert
    public static final string EXCLUDED_SUB_CATEGORIES ='Request for IFT (SHUT) Backup,Request for IFT Billing Backup,IFT/SHUT Backup Right Faxed,Fuel Ticket Reprints,Customer Requests Copies of Fuel Tickets,' +
                                                         'Fuel Billing/Fuel Tickets,Fuel Ticket Questions/Inquiries,Request copies of signed Fuel Tickets,Invoice Reprints,Comdata Express Checks,Comdata / Comchecks,' +
                                                         'Rebillables,Backup,Backup Requests,FHUT Backup,Invoice Backup,Invoice Backup Needed,Refund Check Backup Needed,Request for backup,Request for ID Billing Backup,' +
                                                         'Request for N.Y. or Oregon Mile Tax Backup,Request for SHUT Backup,Request Invoice Backup,Security Deposit Backup Needed,Canada - GST/PST-Backup Request';
    
    //AAK 05-20-2014 to get the current instance of the salesforce 
    public static string SFDC_CURRENT_INSTANCE_URL = System.url.getSalesforceBaseUrl().getHost().remove('-api');
       
    public static String getConvertedLeadStatus(String pLeadStatus)
    {
        String lRtnStatus = 'Qualified';
        if(pLeadStatus!=null && pLeadStatus=='SQL')
        {
           lRtnStatus = 'SQL'; 
        }
        return lRtnStatus;
    }
}