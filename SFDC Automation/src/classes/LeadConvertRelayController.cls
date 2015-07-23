public with sharing class LeadConvertRelayController 
{
    
    public String leadId {get; set;}
    public String pageTitle {get; set;}
    
    /**
     * LeadConvertRelayController acts as a relay to move information to newAccount page
     * 
     * @param        controller        
     * @return       void              
     */
    public LeadConvertRelayController(ApexPages.StandardController controller) 
    {
    }
    
    public PageReference init()
    {
        PageReference pageRef = null;
        pageTitle = RyderGlobalVariables.LEAD_CONVERSION_PAGE_TITLE;
        // Retrieve lead id
        leadId = ApexPages.currentPage().getParameters().get('id');
        
        // sunil; 9-19-2014
        if(isSolutionInterestDetailRecordExist(leadId) == false){
            ApexPages.Message msgError = new ApexPages.Message(ApexPages.Severity.Error, 'At least one item must be selected at customer needs section.');  
          ApexPages.addMessage(msgError);
        }
        
        else if (canConvertLead(leadId)) {
            // Page reference variable
            pageRef = new PageReference('/apex/newAccount?fromLead=true&leadId=' + leadId);
            pageRef.setRedirect(true);
        } else {
            ApexPages.Message msgError = new ApexPages.Message(ApexPages.Severity.Error, RyderGlobalVariables.LEAD_MUST_BE_IN_QUALIFIED_STATUS);  
            ApexPages.addMessage(msgError);
        }
        return pageRef;
    }
    
    private boolean canConvertLead(String leadId) {
        boolean result = false;
        List<Lead> leadList = [select id, status from Lead where id =: leadId];
        if (leadList != null && leadList.size() > 0) {
            //if (leadlist[0].status == RyderGlobalVariables.LEAD_STATUS_FOR_CONVERT) {
            //    result = true;
            //}
            for (String s:RyderGlobalVariables.LEAD_STATUS_FOR_CONVERT) {
                if (leadlist[0].status == s) {
                    result = true;
                    break;
                }
            }
        }
        return result;  
    }
    
  /****************************************************************************/
  // sunil; 9-19-2014; validation for UVS Lead Conversion
  // Return error message when there is no solution record detail record exists.
  /****************************************************************************/
  private boolean isSolutionInterestDetailRecordExist(String leadId) {
    
    if(UVS_Util.isUVSProfile == false){
      return true; // if user is not from UVS profile do not need to check solution interest.
    }
      
    
      
    List<Solution_Interest_Detail__c> lstDetails = [SELECT Id FROM Solution_Interest_Detail__c
                                                   WHERE Solutions_Interest__r.Lead_Id__c = :leadId LIMIT 1];
    if(lstDetails != null && lstDetails.size() > 0){
      return true;
    }
    return false;
  }
  
   
    static testMethod void test_LeadConvertRelayController(){
        Lead lead = new Lead();
        lead.FirstName = RyderGlobalVariables.TEST_FIRST_NAME;
        lead.LastName = RyderGlobalVariables.TEST_LAST_NAME;
        lead.Company = RyderGlobalVariables.TEST_PRIMARY_NAME;
        lead.Status = RyderGlobalVariables.TEST_STATUS;
        lead.LeadSource = RyderGlobalVariables.TEST_SOURCE;
        lead.Street = RyderGlobalVariables.TEST_ADDRESS_LINE;
        lead.City = RyderGlobalVariables.TEST_CITY;
        lead.State = RyderGlobalVariables.TEST_STATE;
        lead.PostalCode = RyderGlobalVariables.TEST_POST_CODE;
        lead.Country = RyderGlobalVariables.COUNTRIES_USA;
        
        lead.Customer_Type__c = RyderGlobalVariables.CustomerType.FMS.name();
        // lead.Country = 'US';
        insert lead;
        
        Test.startTest();
                    
        RyderGlobalVariables.IS_TEST = true;
       
        PageReference leadConvertPage = Page.LeadConvertRelay;
        Test.setCurrentPage(leadConvertPage);
                    
        // Set the model action
        ApexPages.currentPage().getParameters().put('id', lead.Id);

        // Create a standard controller 
        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(lead); 
        
        //create instance of pages controller
        LeadConvertRelayController leadConvertRelayController = new LeadConvertRelayController(controller);
        leadConvertRelayController.init();
        Test.stopTest();
    }
}