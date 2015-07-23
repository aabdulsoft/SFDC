/**=============================================================================
 * Created By: Nimisha (Appirio, Inc)
 * Created Date: [09/18/2014]
 * Description: Test Util for UVS.

 Date   Modified By       Description
20-09-2014 Nimisha        Added create system Admin User + ProfileDefaultProduct Custom Setting + Opportunity
==============================================================================*/
public with sharing class TestUtilUVS {
     public static final String USER_EMAIL_ENCODING = 'UTF-8';
   public static final String USER_TIMEZONE = 'America/Los_Angeles';
     //get RecordType values as list
     public static Map<String, Id> getRecordType(String sObjType){
        Map<String, Id> recordTypeMap = new Map<String, Id>();
        for(RecordType r : [Select r.SobjectType, r.Name, r.IsActive, r.Id From RecordType r where  r.SobjectType=:sObjType AND r.IsActive=true]){
            recordTypeMap.put(r.Name, r.Id);
        }
        return recordTypeMap;
    }
    //create Solution Interest
    public static Solutions_Interest__c createSolutionInterest(Contact newCon, Lead newLead, Boolean isInsert) {
        Solutions_Interest__c test_SolutionsInterest = new Solutions_Interest__c(Name = 'test value1');
        if(newCon <> null){
            test_SolutionsInterest.Contact_Id__c = newCon.Id;
        }
      if(newLead <> null){
        test_SolutionsInterest.Lead_Id__c = newLead.Id;
      }

      test_SolutionsInterest.Product_Line__c = Profile_Default_Products__c.getAll().get('VSM/VSR UVS').Default_Product__c;
      if(isInsert) {
        insert test_SolutionsInterest;
      }
      return test_SolutionsInterest;
    }

    //create Solution Interest Detail records.
    public static Solution_Interest_Detail__c createSolutionInterestDetail(Solutions_Interest__c si, Boolean isInsert) {
      Solution_Interest_Detail__c objDetail = new Solution_Interest_Detail__c();
      objDetail.Solutions_Interest__c = si.Id;
      if(isInsert) {
        insert objDetail;
      }
      return objDetail;
    }


    //create Account
     public  static Map<String, Id> accRecordTypeMap = getRecordType('Account');
     public static Account createAccount(String rt, String custType, Boolean isInsert){
          Account a = new Account();
          a.Name='Abc Group Inc';
          a.Type='Customer';
          a.BillingStreet='13335 Seventh Concession';
          a.BillingCity='Miami';
          a.ShippingState='FL';
          a.ShippingCountry='US';
          a.CustomerTypeID__c=custType;
          a.BillingPostalCode = '33378';
          if(accRecordTypeMap!=null)
             a.RecordTypeId=accRecordTypeMap.get(rt);
          if(isInsert){
             insert a;
          }
          return a;


     }

     //create Quote
    public  static Map<String, Id> qtRecordTypeMap = getRecordType('Quote');
  public static Quote createQuote(String rt,Boolean isInsert) {
    Account acc = createAccount('Vendor', 'FMS', true);
    Opportunity opp = createOpportunity('UVS Opportunity',acc , true, null);
    Quote q = new Quote();
    q.Name='Test Quote';
    q.OpportunityId = createOpportunity('UVS Opportunity',acc , true, null).id;
    q.Status = 'In Review';
    if(qtRecordTypeMap!=null)
    q.RecordTypeId=qtRecordTypeMap.get(rt);
    if(isInsert){
      insert q;
    }
    return q;
  }

  /*
  // create QuoteLineItem List
 public  static Map<String, Id> qliRecordTypeMap = getRecordType('QuoteLineItem');
 static List<QuoteLineItem> createQuoteLineItem(String rt,Boolean isInsert) {
    Product2 prod = new Product2();
    prod.Name = 'Standard Price Book UVS';
    prod.CurrencyIsoCode = 'CAD';
    insert prod;
    Quote newQuote = QLIOLISyncManager.createQuote( 'UVS', True);
    list <QuoteLineItem> lstQuoteLineItem = new List< QuoteLineItem>();
    lstQuoteLineItem.add(new QuoteLineItem( Approved_to_take__c = 0.0, As_Is_Vehicle__c = false ,BankOfAmerica__c = false,
                                            Book_Value__c = 9100.0, Branch_Name__c = 'RVS BALT WASH UTC Test',
                                            CurrencyIsoCode = 'USD',Days_held__c = 258.0, Display_Code__c = False,
                                            Gain_Loss__c = 0.0,Quantity = 1.0 ,Vehicle__c = prod.id,  quotuid= newQuote.id,
                                            UnitPrice = 21951.0 , TotalPrice = 21951.0 , Take_Price2__c = 18951.0,
                                            RecordTypeId = qliRecordTypeMap.get(rt),Sales_Price__c = 21951.0,
                                            SAM_Description__c = 'Truck > 26K GVW > 20 ft', SAM_Class__c = '81 - Truck (No Body) >26K <=33K GVW'
                                            ));  // Need to change Vehicle__c

    if(isInsert){
      insert lstQuoteLineItem;
    }
    return lstQuoteLineItem;
  }

  //  */
    //create contact
    public static Contact createContact(Id accountId, Boolean isInsert) {
        Contact c = new Contact();
        c.accountId = accountId;
        c.FirstName = 'Test contact';
        c.LastName = 'Sample';
        c.Email = 'test8979123@rydertest.com';
        c.Phone = '(123) 456-8789';
        c.Contact_Source__c = 'Lead Conversion';
        if(isInsert){
            insert c;
        }
        return c;
    }
    //create Lead
    public static Lead createLead(Boolean isInsert) {
        lead test_Lead = new lead (
            LastName = 'test value',
            FirstName = 'test value',
            Company = 'test value'
        );
        test_Lead.Entity_Type__c = 'Incorporated';
        test_Lead.Country = 'US';
        test_Lead.State = 'FL';
        test_Lead.Phone = '(123) 456-8789';
        if(isInsert) {
            insert test_Lead;
        }
        return test_Lead;
    }
    //create Opportunity
    public  static Map<String, Id> oppRecordTypeMap = getRecordType('Opportunity');
    public static Opportunity createOpportunity(String rt, Account a, Boolean isInsert, Contact con ){
        //Account acc = createAccount('Vendor', 'FMS', true);
        if(con == null){
            con = createContact(a.Id, true);
        }
        Opportunity opp = new Opportunity();
        opp.Name = 'test Opp';
        opp.Original_Decision_Maker__c = con.Id;
        opp.AccountId = a.Id;
        opp.Estimated_Proposal_Date__c = system.today();
        opp.CloseDate = system.today().addDays(10);
        opp.StageName = 'Solution Hypothesis';
        opp.Purchase_Reason__c = 'End of Lease Sale';
        opp.CurrencyIsoCode = 'USD';
        if(oppRecordTypeMap!=null)
      opp.RecordTypeId=oppRecordTypeMap.get(rt);
      if(isInsert){
       insert opp;
       system.debug('============MANISHA : OPP ==============' + opp);

      }
      return opp;
    }

 static Boolean isExecuting = false;
    //create Admin uvs user
    public static User createAdminUser(Boolean isInsert) {
        Profile p = [select p.id from Profile p where p.Name in ('System Administrator') LIMIT 1];

        //Creating the user
        User u = new User( Username = 'uvs@rydertest.com',
                                    Alias = 'autocln', FirstName = 'Ryder', LastName = 'Tester', Email = 'uvs@rydertest.com',
                                    EmailEncodingKey = USER_EMAIL_ENCODING, LanguageLocaleKey = 'en_US',
                                    LocalesIdKey = 'en_US', ProfileId = p.Id, TimeZonesIdKey = USER_TIMEZONE,
                                    isActive = true);
        if(isInsert && isExecuting == false ){
            isExecuting = true;
            System.debug('@@@@@' + u);
            insert u;
        }
        return u;
    }

    //create uvs user
    public static User createUser(Boolean isInsert) {
        Profile p = [select p.id from Profile p where p.Name in ('VSM_VSR') LIMIT 1];

        //Creating the user
        User u = new User( Username = 'uvs@rydertest.com',
                                    Alias = 'autocln', FirstName = 'Ryder', LastName = 'Tester', Email = 'uvs@rydertest.com',
                                    EmailEncodingKey = USER_EMAIL_ENCODING, LanguageLocaleKey = 'en_US',
                                    LocalesIdKey = 'en_US', ProfileId = p.Id, TimeZonesIdKey = USER_TIMEZONE,
                                    isActive = true);
        if(isInsert){
            insert u;
        }
        return u;
    }
    //create sys admin - Appirio User
    public static User createSysAdmin(Boolean isInsert) {
        Profile p = [Select Id From Profile Where Name = 'System Administrator' Limit 1];
        User u = new User();
        u.Username = 'sysAdmin@rydertest.com';
        u.Alias = 'sysAdmin';
        u.FirstName = 'TestFN';
        u.LastName = 'TestLN';
        u.Email = 'sysAdmin@rydertest.com';
        u.EmailEncodingKey = USER_EMAIL_ENCODING;
        u.LanguageLocaleKey = 'en_US';
        u.LocalesIdKey = 'en_US';
        u.ProfileId = p.Id;
        u.TimeZonesIdKey = USER_TIMEZONE;
        u.isActive = true;
        if(isInsert){
          insert u;
        }
        return u;
    }
    //create Profile Default Products
    public static Profile_Default_Products__c createProfileDefaultProduct(String ProfileName, Boolean isInsert) {
        Profile_Default_Products__c custSetting = new Profile_Default_Products__c();
    custSetting.Name = ProfileName;
    custSetting.Default_Product__c = 'Used Vehicles';
    if(isInsert) {
        insert custSetting;
    }
    return custSetting;
    }

    //create RyderConfig__c
    public static RyderConfig__c createRyderConfig(Boolean isInsert) {
        RyderConfig__c rydConf = new RyderConfig__c();
        rydConf.Name = 'test';
        rydConf.Accuracy_Mapping__c = '10=0.994,9=0.985,8=0.973,7=0.963,6=0.943,5=0.803,4=0.453,3=0.403,2=0.253,1=0.0344';
        rydConf.DNB_Password__c = 'rtr2006z';
        rydConf.DNB_UserId__c = 'ryderprod';
        rydConf.NumberOfRecordsToDisplay__c = 20;
        rydConf.Ryder_WS_EndPoint__c = 'https://salesforce.ryder.com/sfdc_fulldev/';
        rydConf.Contact_HTMLID__c = 'CF00N600000029MZg';
        rydConf.Contact_HTML_LKID__c = 'CF00N600000029MZg_lkid';
        rydConf.Customer_Branch_HTMLID__c = 'CF00N600000029MVq';
        rydConf.Customer_Branch_HTML_LKID__c = 'CF00N600000029MVq_lkid';
        rydConf.ContactToCustomerBranchs_rlid__c = '00N600000029MZg';
        rydConf.CustomerBranchKeyContact_rlid__c = '00N600000029MVq';
        rydConf.ETL_Username__c = 'etluser@ryder.com.test';
        rydConf.Lead_Status_For_Convert__c = 'Qualified,SQL';
        rydConf.RADAR_DS_New_Link__c = 'http://testdotnet/Ryder/Applications/Bluesky_Staging/DealSummary/CreateDealSummary.aspx?tabindex=3&tabid=4&ComingFromSearch=True&ViewModeRequested=0';
        rydConf.RADAR_RS_Edit_Link__c = 'http://testdotnet/Ryder/Applications/Bluesky_Staging/RateSheet/ProductSelection.aspx?tabindex=2&tabid=3&ComingFromSearch=True&ViewModeRequested=0';
        rydConf.RADAR_RS_New_Link__c = 'http://testdotnet/Ryder/Applications/Bluesky_Staging/RateSheet/CreateRateSheet.aspx?tabindex=2&tabid=3&ComingFromSearch=True&ViewModeRequested=0';
        rydConf.Duplicate_Case_Email_Recipient__c = 'Gregory_Blitz@ryder.com';
        rydConf.Data_comcleanuser__c = 'automatedclean';
        if(isInsert){
            insert rydConf;
        }
        return rydConf;
    }
    public static List<vehicle_list__c> createVehicleList(Boolean isInsert) {
        List<vehicle_list__c> lst = new List<vehicle_list__c>();
        lst.add(new vehicle_list__c(Name='1', Vehicle_Name__c = '10 - Panel Van or Pickup', vehicle_type__c = 'Trucks'));
        lst.add(new vehicle_list__c(Name='2', Vehicle_Name__c = '20 - Parcel Van', vehicle_type__c = 'Trucks'));
        lst.add(new vehicle_list__c(Name='3', Vehicle_Name__c = '21 - Metro Van/Sprinter ', vehicle_type__c = 'Trucks'));
        lst.add(new vehicle_list__c(Name='4', Vehicle_Name__c = '30 - Truck >=8K <=16K GVW', vehicle_type__c = 'Trucks'));
        lst.add(new vehicle_list__c(Name='5', Vehicle_Name__c = '31 - Reefer Truck <=16K ', vehicle_type__c = 'Trucks'));
        lst.add(new vehicle_list__c(Name='6', Vehicle_Name__c = '40 - Gas Straight Truck', vehicle_type__c = 'Trucks'));
        lst.add(new vehicle_list__c(Name='7', Vehicle_Name__c = '50 -Truck >16K <=26K GVW & <=20ft ', vehicle_type__c = 'Trucks'));
        lst.add(new vehicle_list__c(Name='8', Vehicle_Name__c = '51 -Truck [No Body] >16K <=26K GVW', vehicle_type__c = 'Trucks'));
        lst.add(new vehicle_list__c(Name='9', Vehicle_Name__c = '60 -Truck >16K <=26K GVW & >20ft', vehicle_type__c = 'Trucks'));
        lst.add(new vehicle_list__c(Name='10', Vehicle_Name__c = '61 -Tank Truck >16K <=26K GVW', vehicle_type__c = 'Trucks'));
        lst.add(new vehicle_list__c(Name='11', Vehicle_Name__c = '70 - Reefer Truck >16K <=26K GVW', vehicle_type__c = 'Trucks'));
        lst.add(new vehicle_list__c(Name='12', Vehicle_Name__c = '80 -Truck >26K GVW & <=20ft', vehicle_type__c = 'Trucks'));
        lst.add(new vehicle_list__c(Name='13', Vehicle_Name__c = '81 -Truck [No Body] >26K <=33K GVW', vehicle_type__c = 'Trucks'));
        lst.add(new vehicle_list__c(Name='14', Vehicle_Name__c = '90 -Truck >26K GVW & >20ft', vehicle_type__c = 'Trucks'));
        lst.add(new vehicle_list__c(Name='15', Vehicle_Name__c = '91 -Tank Truck >26K <=33K GVW', vehicle_type__c = 'Trucks'));
        lst.add(new vehicle_list__c(Name='16', Vehicle_Name__c = '100 - Stake or Flatbed Truck', vehicle_type__c = 'Trucks'));
        lst.add(new vehicle_list__c(Name='17', Vehicle_Name__c = '110 - Reefer Truck >26K GVW', vehicle_type__c = 'Trucks'));
        lst.add(new vehicle_list__c(Name='18', Vehicle_Name__c = '120 - T/A Big Bore Truck', vehicle_type__c = 'Trucks'));
        lst.add(new vehicle_list__c(Name='19', Vehicle_Name__c = '121 - S/A Big Bore Truck', vehicle_type__c = 'Trucks'));
        lst.add(new vehicle_list__c(Name='20', Vehicle_Name__c = '122 -Tank Truck >33K GVW', vehicle_type__c = 'Trucks'));
        lst.add(new vehicle_list__c(Name='21', Vehicle_Name__c = '125 - Unidentifiable Truck', vehicle_type__c = 'Trucks'));
        lst.add(new vehicle_list__c(Name='22', Vehicle_Name__c = '130 - S/A Tractor', vehicle_type__c = 'Tractors'));
        lst.add(new vehicle_list__c(Name='23', Vehicle_Name__c = '131 - S/A Yard Tractor ', vehicle_type__c = 'Tractors'));
        lst.add(new vehicle_list__c(Name='24', Vehicle_Name__c = '132 - S/A Pick-up & Delivery Tractor ', vehicle_type__c = 'Tractors'));
        lst.add(new vehicle_list__c(Name='25', Vehicle_Name__c = '140 - T/A Tractor', vehicle_type__c = 'Tractors'));
        lst.add(new vehicle_list__c(Name='26', Vehicle_Name__c = '141 - T/A Yard Tractor', vehicle_type__c = 'Tractors'));
        lst.add(new vehicle_list__c(Name='27', Vehicle_Name__c = '150 - S/A Sleeper Tractor', vehicle_type__c = 'Tractors'));
        lst.add(new vehicle_list__c(Name='28', Vehicle_Name__c = '160 - T/A COE Sleeper Tractor', vehicle_type__c = 'Tractors'));
        lst.add(new vehicle_list__c(Name='29', Vehicle_Name__c = '170 - T/A Conv Sleeper Tractor', vehicle_type__c = 'Tractors'));
        lst.add(new vehicle_list__c(Name='30', Vehicle_Name__c = '175 - Unidentifiable Tractor', vehicle_type__c = 'Tractors'));
        lst.add(new vehicle_list__c(Name='31', Vehicle_Name__c = '180 - Dry Trailer', vehicle_type__c = 'Trailers'));
        lst.add(new vehicle_list__c(Name='32', Vehicle_Name__c = '181 - Tanker Trailer ', vehicle_type__c = 'Trailers'));
        lst.add(new vehicle_list__c(Name='33', Vehicle_Name__c = '190 - Flatbed Trailer', vehicle_type__c = 'Trailers'));
        lst.add(new vehicle_list__c(Name='34', Vehicle_Name__c = '200 - Reefer Trailer', vehicle_type__c = 'Trailers'));
        lst.add(new vehicle_list__c(Name='35', Vehicle_Name__c = '205 - Unidentifiable Trailer', vehicle_type__c = 'Trailers'));
        lst.add(new vehicle_list__c(Name='36', Vehicle_Name__c = '210 ? Bus', vehicle_type__c = 'Other'));
        lst.add(new vehicle_list__c(Name='37', Vehicle_Name__c = '211 - School Bus >15K <=39K GVW ', vehicle_type__c = 'Other'));
        lst.add(new vehicle_list__c(Name='38', Vehicle_Name__c = '212 - Inter-City Bus >40K GVW', vehicle_type__c = 'Other'));
        lst.add(new vehicle_list__c(Name='39', Vehicle_Name__c = '213 - Charter Coach Bus >50K GVW ', vehicle_type__c = 'Other'));
        lst.add(new vehicle_list__c(Name='40', Vehicle_Name__c = '220 ? Car', vehicle_type__c = 'Other'));
        lst.add(new vehicle_list__c(Name='41', Vehicle_Name__c = '230 - Converter Dolly', vehicle_type__c = 'Other'));
        lst.add(new vehicle_list__c(Name='42', Vehicle_Name__c = '240 - Non-Vehicle', vehicle_type__c = 'Other'));
        lst.add(new vehicle_list__c(Name='43', Vehicle_Name__c = '250 ? Forklift', vehicle_type__c = 'Other'));
        lst.add(new vehicle_list__c(Name='44', Vehicle_Name__c = '260 - Pallett Jack', vehicle_type__c = 'Other'));
        lst.add(new vehicle_list__c(Name='45', Vehicle_Name__c = '270 - Fire-Fan', vehicle_type__c = 'Other'));
        lst.add(new vehicle_list__c(Name='46', Vehicle_Name__c = '295 - Unidentifiable Vehicle', vehicle_type__c = 'Other'));
        if(isInsert) {
            insert lst;
        }
        return lst;
    }

    public static Vehicle__c createUVSVehicle(Account acc, Boolean isInsert){
        Vehicle__c veh1 = new Vehicle__c();
        veh1.Name = '1';
        veh1.Account__c = acc.Id;
        veh1.Ask_Price__c = 11;
        veh1.Take_Price__c = 11;
        veh1.NBV__c = 11;
        if(isInsert){
            insert veh1;
        }
        return veh1;
    }

    public static List<vehicle__c> createVehList(Boolean isInsert) {
        List<Vehicle__c> vehList = new List<Vehicle__c>();
        Account acc = TestUtilUVS.createAccount('Vendor', 'FMS', true);
        Vehicle__c veh1 = new Vehicle__c();
        veh1.Name = '1';
        veh1.Account__c = acc.Id;
        veh1.Ask_Price__c = 11;
        veh1.Take_Price__c = 11;
        veh1.NBV__c = 11;
        vehList.add(veh1);
        Vehicle__c veh2 = new Vehicle__c();
        veh2.Name = '2';
        veh2.Account__c = acc.Id;
        veh2.Ask_Price__c = 22;
        veh2.Take_Price__c = 22;
        veh2.NBV__c = 22;
        vehList.add(veh2);
        Vehicle__c veh3 = new Vehicle__c();
        veh3.Name = '3';
        veh3.Account__c = acc.Id;
        veh3.Ask_Price__c = 33;
        veh3.Take_Price__c = 33;
        veh3.NBV__c = 33;
        vehList.add(veh3);
        Vehicle__c veh4 = new Vehicle__c();
        veh4.Name = '4';
        veh4.Account__c = acc.Id;
        veh4.Ask_Price__c = 44;
        veh4.Take_Price__c = 44;
        veh4.NBV__c = 44;
        vehList.add(veh4);
        if(isInsert){
            insert vehList;
        }
        return vehList;
    }
    public static Ryder_Account_Team_Role_Map__c createRyderAccountTeamRoleMap(Boolean isInsert) {
        Ryder_Account_Team_Role_Map__c ryAccTRM = new Ryder_Account_Team_Role_Map__c();
        ryAccTRM.Account_Team_Role__c = 'Local Account Manager';
        ryAccTRM.Name = 'Default';
        if(isInsert){
            insert ryAccTRM;
        }
        return ryAccTRM;
    }

    public static List<OpportunityLineItem> createOpportunityLineItemList(Account acc,List<Vehicle__C> vehList,Boolean isInsert) {
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();


        Contact newCon = TestUtilUVS.createContact(acc.Id,false);
        newCon.Additional_Comments__c = 'Test1';
        newCon.Email = 'test1@rydertest.com';
        newCon.OwnerId = UserInfo.getUserId();
       // String pname = UserInfo.getProfileName();
        newCon.Contact_Source__c = 'Lead Conversion';
        //User Up = [Select id, profile.Name from User where id =: newCon.OwnerId];
        //Ryder_Account_Team_Role_Map__c ratrm = createRyderAccountTeamRoleMap(false);
        //ratrm.Account_Team_Role__c = Up.profile.Name;
        //insert ratrm;
        insert newCon;
        
        Product2 prod = new Product2();
        prod.Name = 'Standard Price Book UVS';
        prod.CurrencyIsoCode = 'CAD';
        insert prod;
        Product2 prd2 = createProduct();
        //PriceBook2 pb2 = createPriceBook2();
        //PriceBookEntry pbe = createPriceBookEntry(prd2, pb2);
        PriceBookEntry pbe = [Select Name ,Product2.Family,Product2.Id, Pricebook2Id , Pricebook2.name , CurrencyIsoCode From PricebookEntry where Pricebook2.name= 'UVS' LIMIT 1];
        pbe.isActive = true;
        update pbe;
        
        system.debug('::PBE :::'+pbe);
        String productFamily = pbe.Product2.Family;
        
        Opportunity opp = createOpportunity('UVS Opportunity',acc , false, newCon);
        opp.Original_Decision_Maker__c = newCon.Id;
        opp.Pricebook2Id = pbe.Pricebook2Id;
        opp.CurrencyIsoCode = pbe.CurrencyIsoCode;
        insert opp;
        system.debug('==========MANSIHSA=========' + opp);
        /*Opportunity opp2 = createOpportunity('National Rental Opportunity',acc , false, newCon);
        opp2.Original_Decision_Maker__c = newCon.Id;
        insert opp2;
        system.debug('==========MANSIHSA : OPP2=========' + opp2);*/
        
        for(Vehicle__c veh : vehList){
        OpportunityLineItem oppLI1 = new OpportunityLineItem();
        oppLI1.OpportunityId = opp.Id;
        oppLI1.Unit_Number__c = veh.Id;
        oppLI1.PricebookEntryId = pbe.Id;
        oppLI1.Quantity = 1;
        oppLI1.UnitPrice = 123;
        oppLI1.Transaction_Type__c = 'Term Extension';
        oppLI1.Product_Line__c = 'Insurance';
        oppLI1.Product_Detail__c = 'Physical Damage';
        oppLI1.Product_Line__c= productFamily;
        //oppLI1.OppRecordTypeName__c = 'National Rental Opportunity';
        /*OpportunityLineItem oppLI2 = new OpportunityLineItem();
        oppLI2.OpportunityId = opp2.Id;
        oppLI2.Unit_Number__c = veh.Id;
        oppLI2.PricebookEntryId = pbe.Id;
        oppLI2.Quantity = 1;
        oppLI2.UnitPrice = 123;
        oppLI2.Transaction_Type__c = 'Term Extension';
        oppLI2.Product_Line__c = 'Insurance';
        oppLI2.Product_Detail__c = 'Physical Damage';
        //oppLI2.OppRecordTypeName__c = 'National Rental Opportunity';
        oppLineItemList.add(oppLI2);*/
        oppLineItemList.add(oppLI1);
        }
        if(isInsert){
            insert oppLineItemList;
        }
        return oppLineItemList;
    }
    //Creating custom setting for the use in test class
     public static void createCustomSettingData(){
        //fetches or creates a Custom Setting at the organization level
            RyderConfig__c setting = new RyderConfig__c(ETL_Username__c = 'etluser@ryder.com.test',Accuracy_Mapping__c ='10=0.994,9=0.985,8=0.973,7=0.963,6=0.943,5=0.803,4=0.453,3=0.403,2=0.253,1=0.0344',
            DNB_Password__c = 'rtr2006z',DNB_UserId__c = 'ryderprod', NumberOfRecordsToDisplay__c = 20, Ryder_WS_EndPoint__c = 'ryderprod', Contact_HTMLID__c = 'ryderprod',
            Contact_HTML_LKID__c = 'ryderprod', Customer_Branch_HTMLID__c = 'ryderprod', Customer_Branch_HTML_LKID__c = 'ryderprod',
            ContactToCustomerBranchs_rlid__c = 'ryderprod', CustomerBranchKeyContact_rlid__c = 'ryderprod',
            Lead_Status_For_Convert__c = 'ryderprod', RADAR_DS_New_Link__c = 'ryderprod', RADAR_RS_Edit_Link__c = 'ryderprod',
            RADAR_RS_New_Link__c = 'ryderprod', Duplicate_Case_Email_Recipient__c = 'ryderprod', Data_comcleanuser__c='uvs@rydertest.com');
            //update anything you want to update or add in the custom setting
            insert setting;
            Ryder_Account_Team_Role_Map__c setting2 = new Ryder_Account_Team_Role_Map__c(Name='Default', Account_Team_Role__c='Local Account Manager');
            insert setting2;
        system.debug(RyderConfig__c.getOrgDefaults());
    }
    
    /* @author Hari Krishnan
     * @date 01/12/2015
     * @description Creates a random integer between the given range (inclusive).
     */
    public static Integer getRandomInt (Integer lower, Integer upper){
        return Math.round(Math.random() * (upper - lower)) + lower;
    }

    /* @author Hari Krishnan
     * @date 01/12/2015
     * @description Creates a new ryder branch
    */
    public static Ryder_Branch__c createRyderBranch() {
        String branchCode = String.valueOf(getRandomInt(99000, 99999));
        Ryder_Branch__c ryderBranch = new Ryder_Branch__c(Name = 'Test RB 1', Branch_Code__c = branchCode);
        insert ryderBranch;
        return ryderBranch;
    }
    
    public static Product2 createProduct() {
        Product2 prd2 = new Product2();
        prd2.VHC_Type__c = 'Used';
        prd2.SAM_Class__c = '220-Car';
        prd2.Name = 'FSL-220-Used';
        prd2.IsActive = true;
        prd2.Family = 'FSL';
        prd2.CurrencyIsoCode = 'USD';
        insert prd2;
        return prd2;
    }
    
    public static PriceBook2 createPriceBook2() {
        PriceBook2 pb2 = new PriceBook2();
        pb2.Name = 'UVS';
        pb2.IsActive = true;
        pb2.Description = 'UVS Price Book';
        insert pb2;
        return pb2;
    }
    
    public static PriceBookEntry createPriceBookEntry(Product2 prd2, PriceBook2 pb2) {
        PriceBookEntry pbe = new PriceBookEntry();
        //pbe.Name = 'UVS-10 Used';
        pbe.Product2Id = prd2.Id;
        pbe.Pricebook2Id = pb2.Id;
        return pbe;
    }
}