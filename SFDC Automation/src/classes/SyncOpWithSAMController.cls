/***********************************************************************
 Class          : SyncOpWithSAMController
 Author         : Aditi Bharadwaj/Manisha Gupta
 Created Date   : August 9, 2014
 Descritption   : Functonality to sync Opportunity with SAM

 Date       Modified By         Description

 ************************************************************************/
public with sharing class SyncOpWithSAMController {
    public boolean alreadySynced{get;set;}
    public SAMResponse response{get;set;}
    public String selectedAccountBSNP{get;set;}
    private map<String, SAMResponse.PotentialDuplicate> mapAccountBSNPID;
    private Id accountId;
    public boolean isError{get;set;}
    List<CreateSAMCompany.DCSAMCompanyContact> companyContactList;
    List<CreateSAMCompany.DCSAMCompanyAddress> companyAddressList;
    List<CreateSAMCompany.DCSAMCompanyPhone> companyPhoneList;
    String accountName;
    String rideId;
    String sam_salesType;
    String sam_salesSource;
    String sicCode;
    //Added VirendraI-144303 IssueQA_ For the Existing SAM_Cust_ID Account, the New location in not creating in SAM.
    String samCustID;
    public boolean isForceInsert{get;set;}
    public Quote quote{get;set;}

  public SyncOpWithSAMController(ApexPages.StandardController stdController){
    try{
      response = new SAMResponse();
      isError = false;
      CreateSAMCompany.DCSAMCompanyContact dcsCon;
      CreateSAMCompany.DCSAMCompanyAddress dcsAdd;
      CreateSAMCompany.DCSAMCompanyPhone   dcsPhn;
      companyContactList = new List<CreateSAMCompany.DCSAMCompanyContact>();
      companyAddressList = new List<CreateSAMCompany.DCSAMCompanyAddress>();
      companyPhoneList = new List<CreateSAMCompany.DCSAMCompanyPhone> ();
      Id quoteId = stdController.getId();
      // get required data from quote, related Opportunity, Account and Contact
      quote = [Select Id, OpportunityId, Opportunity.AccountId, Opportunity.Account.BillingStreet,  Opportunity.Account.BillingCity,
                       Opportunity.Account.BillingState,  Opportunity.Account.BillingCountry,  Opportunity.Account.ShippingStreet,
                       Opportunity.Account.ShippingCity,
                       Opportunity.Account.ShippingState,  Opportunity.Account.ShippingCountry, Opportunity.Account.Phone, Contact.LastName, Contact.FirstName,
                       Contact.Title, Contact.Fax, Contact.Email, Opportunity.Account.BSNP_ID__c, Contact.Marketing_Country__c,
                       Opportunity.Account.Transaction_Type__c,
                       Opportunity.Account.SAM_Account_Source__c, Opportunity.Account.Name, Opportunity.Account.SIC_Code__r.Name, Opportunity.Type,
                       Contact.Phone, Contact.BUSS_PHONE1_EXTN__c, Opportunity.Account.ShippingPostalCode, Opportunity.Account.SAM_Cust_ID__c ,
                       Opportunity.Account.SIC_Code__r.SIC_Code_Description__c
                       from Quote
                       where Id = :quoteId];
                       
      alreadySynced = false;
      
       //Modified by Albert Miranda 02/27/2015 - Added a check for BSNP ID and modified SAM Cust ID to check if 'true'.
      if(String.isBlank(quote.Opportunity.Account.SAM_Cust_ID__c) == true 
              && String.isBlank(quote.Opportunity.Account.BSNP_ID__c)  == false){
          
          alreadySynced = true;
      }
      accountId = quote.Opportunity.AccountId;
      accountName = quote.Opportunity.Account.Name;
      
      //Added 02/16/2015 Virendra I-144303 IssueQA_ For the Existing SAM_Cust_ID Account, the New location in not creating in SAM.
      //samCustID = quote.Opportunity.Account.SAM_Cust_ID__c; //commented out 02/27/2015 by Albert Miranda - This line is causing a null error when reaching the web services.
      //Modified 02/27/2015 by Albert Miranda - Check for null value
      samCustID = quote.Opportunity.Account.SAM_Cust_ID__c <> null ? quote.Opportunity.Account.SAM_Cust_ID__c : '';
      
      //Modified 3/23/2015 by Alber Miranda - Added a default SIC code if one doesn't exist. This default will not update SF field.
      sicCode = quote.Opportunity.Account.SIC_Code__c <> null ? quote.Opportunity.Account.SIC_Code__r.Name : LABEL.UVS_SIC_Code;
      
      if(quote.Opportunity.Account.SAM_Account_Source__c == null){
        ApexPages.AddMessage(new Apexpages.Message(ApexPages.SEVERITY.ERROR, 'Please populate SAM Account Source Field on Account.'));
        isError = true;
      }

      if(quote.Opportunity.Account.Transaction_Type__c == null){
        ApexPages.AddMessage(new Apexpages.Message(ApexPages.SEVERITY.ERROR, 'Please populate Transaction Type Field on Account.'));
        isError = true;
      }

      // get user's Ride Id
      User user = [SELECT Id, Ride_ID__c, UTC__c FROM User WHERE id = :UserInfo.getUserId()];
      rideId = user.Ride_ID__c <> null ? user.Ride_ID__c : '';
      String location = user.UTC__c <> null ? user.UTC__c : '';
      if(location == ''){
        ApexPages.AddMessage(new Apexpages.Message(ApexPages.SEVERITY.ERROR, 'Please populate UTC Field on User.'));
        isError = true;
      }

      if(isError){
        return;
      }

      sam_salesType = ' ';
      sam_salesSource = ' ';

      for(UVS_SAM_Sales_Type__c salesType_customSetting : [Select Sales_Type__c
                        from UVS_SAM_Sales_Type__c
                        where Name = :quote.Opportunity.Account.Transaction_Type__c limit 1]){
        sam_salesType = salesType_customSetting.Sales_Type__c;
      }

      for(UVS_SAM_Sales_Source__c salesSource_customSetting : [Select Sales_Source__c
                        from UVS_SAM_Sales_Source__c
                        where Name = :quote.Opportunity.Account.SAM_Account_Source__c limit 1]){
        sam_salesSource = salesSource_customSetting.Sales_Source__c;
      }


      // Account Shipping Address
      dcsAdd = new CreateSAMCompany.DCSAMCompanyAddress();
      dcsAdd.Line1 = quote.Opportunity.Account.ShippingStreet.substring(0, 30) <> null ? quote.Opportunity.Account.ShippingStreet.substring(0, 30) : '';
      dcsAdd.Line2 = '';
      dcsAdd.City = quote.Opportunity.Account.ShippingCity.substring(0, 30) <> null ? quote.Opportunity.Account.ShippingCity.substring(0, 30) : '';
      dcsAdd.State = quote.Opportunity.Account.ShippingState <> null ? quote.Opportunity.Account.ShippingState : '';
      dcsAdd.CountryName = quote.Opportunity.Account.ShippingCountry <> null ? quote.Opportunity.Account.ShippingCountry : '';
      dcsAdd.Location = location <> null ? location : '';
      dcsAdd.Type_x = '20';
      //Modified by Albert M. 3/24/2015 - Account object only has one Zip Code field. SAM accepts two. Use this logic to differentiate (for SAM) if the Zip Code is Non US.
      if(quote.Opportunity.Account.ShippingCountry == 'US')
      {
          dcsAdd.PostalZipCode = quote.Opportunity.Account.ShippingPostalCode <> null ? quote.Opportunity.Account.ShippingPostalCode : '';
          dcsAdd.ZipNonUS = '';
      }else{
          dcsAdd.PostalZipCode = '';
          dcsAdd.ZipNonUS = quote.Opportunity.Account.ShippingPostalCode <> null ? quote.Opportunity.Account.ShippingPostalCode : '';
      }
      
      companyAddressList.add(dcsAdd);

      // Account Phone
      dcsPhn = getPhoneDetail(''+quote.Opportunity.Account.Phone);
      dcsPhn.Location = location <> null ? location : '';
      dcsPhn.CountryName = dcsAdd.CountryName;
      companyPhoneList.add(dcsPhn);

      dcsPhn = getPhoneDetail(''+quote.Contact.Phone);

      // contact details
      dcsCon = new CreateSAMCompany.DCSAMCompanyContact();
      dcsCon.Name = quote.Contact.FirstName + ' ' + quote.Contact.LastName; //Modified by Albert Miranda 02/27/2015 - added First Name
      dcsCon.JobTitle = quote.Contact.Title <> null ? quote.Contact.Title  : '';
      dcsCon.CountryName = quote.Contact.Marketing_Country__c <> null ? quote.Contact.Marketing_Country__c : '';
      dcsCon.EmailAddress = quote.Contact.Email <> null ? quote.Contact.Email : '';
      dcsCon.Location = location <> null ? location : '';
      String faxnumber=quote.Contact.Fax;

      if(faxnumber!=null){
          faxnumber=faxnumber.replaceAll('[^0-9]', '');
          dcsCon.FaxAreaCode = faxnumber.substring(0,3);
          dcsCon.FaxExchange =faxnumber.substring(3,6);
          dcsCon.FaxLineNumber =faxnumber.substring(6,10);
      }
      dcsCon.Extension = quote.Contact.BUSS_PHONE1_EXTN__c <> null ? quote.Contact.BUSS_PHONE1_EXTN__c : '';
      dcsCon.AreaCode = dcsPhn.AreaCode <> null ? dcsPhn.AreaCode : '';
      dcsCon.Exchange = dcsPhn.Exchange <> null ? dcsPhn.Exchange : '';
      dcsCon.LineNumber = dcsPhn.LineNumber <> null ? dcsPhn.LineNumber : '';
      dcsCon.InternationalNumber = dcsPhn.InternationalNumber <> null ? dcsPhn.InternationalNumber : '';
      companyContactList.add(dcsCon);
    }catch(Exception ex){
      System.debug('Stack Trace = : ' + ex.getStackTraceString());
      isError = true;
      ApexPages.AddMessage(new Apexpages.Message(ApexPages.SEVERITY.ERROR, 'An exception occured in the service. ' + ex.getMessage()));
    }
  }

  public boolean getHasPageMessage(){
    return Apexpages.hasMessages();
  }

  private CreateSAMCompany.DCSAMCompanyPhone getPhoneDetail(String phone){
        //if no of characters=10, areacode(first 3), exchange(middle 3), line number(last 3)
        // if no of characters>10, line number(last 3), exchange(substring(length-6,length-4), line number(substring(length-9,length-7),
        //international number(substring(lenth-10))

    CreateSAMCompany.DCSAMCompanyPhone dcsPhone = new CreateSAMCompany.DCSAMCompanyPhone();
    String numericData = phone.replaceAll('[^0-9]', '');
    Integer length = numericData.length();
    if(length == 10){
      dcsPhone.AreaCode = numericData.substring(0,3);
      dcsPhone.Exchange = numericData.substring(3,6);
      dcsPhone.LineNumber = numericData.substring(6, 10);
    }else if(length > 10){
      dcsPhone.InternationalNumber = numericData.substring(0, length-10);
      dcsPhone.AreaCode = numericData.substring(length-10,length-7);
      dcsPhone.Exchange = numericData.substring(length-7, length-4);
      dcsPhone.LineNumber = numericData.substring(length-4, length);
    }
    dcsPhone.Type_x = '10';

    return dcsPhone;
  }

  // method to invoke when user clicks on Select Button to update SAM CUSTOMER NO on Account
  public void selectAccount(){
    try
    {
      if(quote.Opportunity.Account.SAM_Cust_ID__c  == null || quote.Opportunity.Account.SAM_Cust_ID__c == ''){
        update new Account(Id=accountId, SAM_Cust_ID__c = selectedAccountBSNP.split('~')[1]);
        response = new SAMResponse();
      }
      ApexPages.AddMessage(new Apexpages.Message(ApexPages.SEVERITY.INFO, 'Account has been synced with SAM'));
    }catch(Exception ex){
      system.debug('SyncOpWithSAMController.selectAccount An exception occurred while processing the request. Exception message = : ' + ex.getMessage() +
                     'Stack Trace = : ' + ex.getStackTraceString() );
     ApexPages.AddMessage(new Apexpages.Message(ApexPages.SEVERITY.ERROR, 'An exception occured in the service. ' + ex.getMessage()));
    }
  }

  public void callWS(){
    try{
      system.debug('==========================' + isFOrceInsert);

      if(alreadySynced == true){
        ApexPages.AddMessage(new Apexpages.Message(ApexPages.SEVERITY.INFO, 'Account is already synced with SAM'));
        // doing nothing in the case when Already Synced and isForceInsert = false;
        return; //Added by Albert Miranda 02/27/2015 - return to make sure webservice is not called.
      }

      callWS(isForceInsert);
      if(response.lstError.isEmpty() && (isForceInsert || response.listPotentialDuplicates.isEmpty() )){
        //if(quote.Opportunity.Account.SAM_Cust_ID__c == null || quote.Opportunity.Account.SAM_Cust_ID__c == ''){
          update new Account(Id=accountId, BSNP_ID__c = response.newAccountBSNP);
        //}
        ApexPages.AddMessage(new Apexpages.Message(ApexPages.SEVERITY.INFO, 'Account has been synced with SAM'));
      }
    }catch(exception ex){
      isError = true;
      system.debug('SyncOpWithSAMController.callWS An exception occurred while processing the request. Exception message = : ' + ex.getMessage() +
                   'Stack Trace = : ' + ex.getStackTraceString() );
      ApexPages.AddMessage(new Apexpages.Message(ApexPages.SEVERITY.ERROR, 'An exception occured in the service. ' + ex.getMessage()));
    }
  }

  private void callWS(boolean isForceInsert){
    system.debug('===============WS CALLED======== ' + isForceInsert);
    String responseXML = UVS_CreateSAMCompany_WS.CallWS ( '',
                                                        accountName,
                                                        sam_SalesSource ,sam_SalesType,sicCode,
                                                        rideId,isForceInsert,
                                                        companyContactList, companyAddressList, companyPhoneList,samCustID);
    System.debug(responseXML);
    Dom.Document domDoc = new Dom.Document();
    domDoc.load(responseXML);
    Dom.XMLNode rootNode = domDoc.getRootElement();
    response = new SAMResponse();
    ParsingUtility.mapClassFields(rootNode, response);
    system.debug('========MANSIHA response.listPotentialDuplicates========' + response);
    System.debug(response);
    //Added by Virendra 19 Feb 2015 to show Response Errors ::
    if(!response.lstError.isEmpty()){
        for(SAMResponse.ResponseError rError:response.lstError){
            ApexPages.AddMessage(new Apexpages.Message(ApexPages.SEVERITY.ERROR, 'Response Error Code::' + rError.code+'  Error Message ::'+rError.message));
        }
    }
  }
}