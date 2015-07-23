/*******************************************************************
Name  : AddProductsCustomControllerTest
Author: Gaurav Gupta (Appirio)
Date  : October 16, 2014
Discription: Test Class for the Helper class AddProductsCustomController
*************************************************************************/
@isTest(seealldata = true)
private class AddProductsCustomControllerTest {
  static testMethod void testAfterUpdate(){
      User sysAdmin = TestUtilUvs.createAdminUser(True);

      System.runAs ( sysAdmin ) {
        //RyderConfig__c rydConf = new RyderConfig__c();
        //rydConf = TestUtilUVS.createRyderConfig(true);
      Account acc =TestUtilUVS.createAccount('Vendor','FMS',false);
      acc.Transaction_Type__c = 'Retail';
      acc.Accountsource = 'Advertisement';
      acc.SAM_Cust_ID__c = 'abc';
      insert acc;
         test.startTest();
      Opportunity opp = TestUtilUVS.createOpportunity('UVS Opportunity',acc , False, null);
      opp.CloseDate = date.today();
      opp.CurrencyISOCode = 'USD';
      insert opp;

            list<Product2> lstProd = new list<Product2>();
            Product2 prod = new Product2();
            prod.Name = 'UVS-DEF-Used';
            prod.CurrencyIsoCode = 'USD';
            lstProd.add(prod);

            Product2 prod1 = new Product2();
            prod1.Name = 'UVS-ABc-Used';
            lstProd.add(prod1);

            Product2 prod3 = new Product2();
            prod3.Name = 'UVS-UVW-Used';
            prod3.CurrencyIsoCode = 'USD';
            lstProd.add(prod3);
            insert lstProd;
        test.stopTest();

        Pricebook2 stdpb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
            PriceBookEntry pbe = [SELECT Id
                                FROM PriceBookEntry
                                WHERE Product2Id = :prod.Id
                                LIMIT 1];
              pbe.isActive = true;

            update pbe;

      Ryder_Branch__c rb = new Ryder_Branch__c();
      rb.Branch_Code__c = '123';
      insert rb;
      Customer_Branch__c cstB = new Customer_Branch__c();
      cstB.Ryder_branch__c = rb.id;
      cstB.Ryder_HQ_Account__c = acc.id;
      insert cstB;
          //**************************************************
          // Create a custom price book
          //Pricebook2 customPB = new Pricebook2(Name='UVS', isActive=true);
          PriceBook2 UVSPriceBook = [Select Id from PriceBook2 where Name = 'UVS' limit 1];
         // insert customPB;

       PricebookEntry PBE1 = new PricebookEntry();
       PBE1.Product2Id = prod1.Id;
       PBE1.Pricebook2Id = UVSPriceBook.Id;
       PBE1.UnitPrice = 100.00;
       PBE1.IsActive = true;
      insert PBE1;



      list<Vehicle__c> lstvehicle = new list<Vehicle__c>();
      Vehicle__c v1 = new Vehicle__c(Name='12');
      v1.CUSTOMER_BRANCH__c = cstB.id;
      v1.Is_Available_For_Sale__c = true;
      v1.Sold_Flag__c = false ;
      v1.Sam_Class__c = 'UVW';
      v1.Ask_Price__c = 20000.0;
      lstvehicle.add(v1);
      Vehicle__c v = new Vehicle__c(Name='12');
      v.CUSTOMER_BRANCH__c = cstB.id;
      v.Is_Available_For_Sale__c = true;
      v.Sold_Flag__c = false ;
      v.Sam_Class__c = 'DEF';
      v.Ask_Price__c = 20000.0;
      v.Ask_Price__c = 20000.0;
      lstvehicle.add(v);

      insert lstvehicle;

      //**************************************************


        /*Quote q = TestUtilUVS.createQuote('UVS', false);
        //q.contactId = newCon.id;
        q.OpportunityId = opp.id;
      insert q;*/






      PageReference tpageRef = Page.AddProductsCustom;
      Test.setCurrentPage(tpageRef);

      ApexPages.currentPage().getParameters().put('oppId', opp.Id);
      //ApexPages.currentPage().getParameters().put('quoteId', q.Id);

    AddProductsCustomController apcc = new AddProductsCustomController();
    apcc.unitNumber = '12';

    AddProductsCustomController.getQuery();
    apcc.search();
    List<AddProductsCustomController.VehicleSelection> searchResults_test = new List<AddProductsCustomController.VehicleSelection>();
    searchResults_test = apcc.searchResults;
    boolean selectOne = false;
    For(AddProductsCustomController.VehicleSelection vc : searchResults_test){
      String vehicleSameClass = vc.vehicle.Sam_Class__c;
      if(vehicleSameClass != null && vehicleSameClass.contains('-') ){
         vc.isSelected = true;
      }
    }
    apcc.searchResults[0].isSelected = true;
    //system.assert(false , apcc.searchResults);
    // Set vehicle.isSelected to true
    apcc.selectVehicles();

    apcc.cancel();
    }
  }
static testMethod void ExecutePastClosedOpportunityUseCase(){
      User sysAdmin = TestUtilUvs.createAdminUser(True);

      System.runAs ( sysAdmin ) {
        //RyderConfig__c rydConf = new RyderConfig__c();
        //rydConf = TestUtilUVS.createRyderConfig(true);
      Account acc =TestUtilUVS.createAccount('Vendor','FMS',false);
      acc.Transaction_Type__c = 'Retail';
      acc.Accountsource = 'Advertisement';
      acc.SAM_Cust_ID__c = 'abc';
      insert acc;
         test.startTest();
      Opportunity opp = TestUtilUVS.createOpportunity('UVS Opportunity',acc , False, null);
      // Update the Close date to 2 days early so the Validation Rule can be tested by forcing the Opportunity to be in the past.
      opp.CloseDate = date.today().addDays(-2);
      opp.CurrencyISOCode = 'USD';
      insert opp;

            list<Product2> lstProd = new list<Product2>();
            Product2 prod = new Product2();
            prod.Name = 'UVS-DEF-Used';
            prod.CurrencyIsoCode = 'USD';
            lstProd.add(prod);

            Product2 prod1 = new Product2();
            prod1.Name = 'UVS-ABc-Used';
            lstProd.add(prod1);

            Product2 prod3 = new Product2();
            prod3.Name = 'UVS-UVW-Used';
            prod3.CurrencyIsoCode = 'USD';
            lstProd.add(prod3);
            insert lstProd;
        test.stopTest();

        Pricebook2 stdpb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
            PriceBookEntry pbe = [SELECT Id
                                FROM PriceBookEntry
                                WHERE Product2Id = :prod.Id
                                LIMIT 1];
              pbe.isActive = true;

            update pbe;

      Ryder_Branch__c rb = new Ryder_Branch__c();
      rb.Branch_Code__c = '123';
      insert rb;
      Customer_Branch__c cstB = new Customer_Branch__c();
      cstB.Ryder_branch__c = rb.id;
      cstB.Ryder_HQ_Account__c = acc.id;
      insert cstB;
          //**************************************************
          // Create a custom price book
          //Pricebook2 customPB = new Pricebook2(Name='UVS', isActive=true);
          PriceBook2 UVSPriceBook = [Select Id from PriceBook2 where Name = 'UVS' limit 1];
         // insert customPB;

       PricebookEntry PBE1 = new PricebookEntry();
       PBE1.Product2Id = prod1.Id;
       PBE1.Pricebook2Id = UVSPriceBook.Id;
       PBE1.UnitPrice = 100.00;
       PBE1.IsActive = true;
      insert PBE1;



      list<Vehicle__c> lstvehicle = new list<Vehicle__c>();
      Vehicle__c v1 = new Vehicle__c(Name='12');
      v1.CUSTOMER_BRANCH__c = cstB.id;
      v1.Is_Available_For_Sale__c = true;
      v1.Sold_Flag__c = false ;
      v1.Sam_Class__c = 'UVW';
      v1.Ask_Price__c = 20000.0;
      lstvehicle.add(v1);
      Vehicle__c v = new Vehicle__c(Name='12');
      v.CUSTOMER_BRANCH__c = cstB.id;
      v.Is_Available_For_Sale__c = true;
      v.Sold_Flag__c = false ;
      v.Sam_Class__c = 'DEF';
      v.Ask_Price__c = 20000.0;
      v.Ask_Price__c = 20000.0;
      lstvehicle.add(v);

      insert lstvehicle;

      //**************************************************


        /*Quote q = TestUtilUVS.createQuote('UVS', false);
        //q.contactId = newCon.id;
        q.OpportunityId = opp.id;
      insert q;*/






      PageReference tpageRef = Page.AddProductsCustom;
      Test.setCurrentPage(tpageRef);

      ApexPages.currentPage().getParameters().put('oppId', opp.Id);
      //ApexPages.currentPage().getParameters().put('quoteId', q.Id);

    AddProductsCustomController apcc = new AddProductsCustomController();
    apcc.unitNumber = '12';

    AddProductsCustomController.getQuery();
    apcc.search();
    List<AddProductsCustomController.VehicleSelection> searchResults_test = new List<AddProductsCustomController.VehicleSelection>();
    searchResults_test = apcc.searchResults;
    boolean selectOne = false;
    For(AddProductsCustomController.VehicleSelection vc : searchResults_test){
      String vehicleSameClass = vc.vehicle.Sam_Class__c;
      if(vehicleSameClass != null && vehicleSameClass.contains('-') ){
         vc.isSelected = true;
      }
    }
    apcc.searchResults[0].isSelected = true;
    //system.assert(false , apcc.searchResults);
    // Set vehicle.isSelected to true
    apcc.selectVehicles();

    apcc.cancel();
    }
  }
  static testMethod void testAddCustomController(){
      User sysAdmin = TestUtilUvs.createAdminUser(True);

      System.runAs ( sysAdmin ) {
        //RyderConfig__c rydConf = new RyderConfig__c();
        //rydConf = TestUtilUVS.createRyderConfig(true);
      Account acc =TestUtilUVS.createAccount('Vendor','FMS',false);
      acc.Transaction_Type__c = 'Retail';
      acc.Accountsource = 'Advertisement';
      acc.SAM_Cust_ID__c = 'abc';
      insert acc;


      Test.StartTest();
      Opportunity opp = TestUtilUVS.createOpportunity('UVS Opportunity',acc , False, null);
      opp.CloseDate = date.today().addDays(-5);
      opp.CurrencyISOCode = 'USD';
      insert opp;
      Test.StopTest();
        Quote q = TestUtilUVS.createQuote('UVS', false);
        //q.contactId = newCon.id;
        q.OpportunityId = opp.id;
      insert q;

      PageReference tpageRef = Page.AddProductsCustom;
      Test.setCurrentPage(tpageRef);

      //ApexPages.currentPage().getParameters().put('oppId', opp.Id);
      ApexPages.currentPage().getParameters().put('quoteId', q.Id);

      AddProductsCustomController apcc = new AddProductsCustomController();
      AddProductsCustomController.getQuery();
      apcc.search();
      // Set vehicle.isSelected to true
      apcc.selectVehicles();

      apcc.cancel();
  }
  }
  
  
  
  static testMethod void testAddCustomController2(){
    User sysAdmin = TestUtilUvs.createAdminUser(True);
    System.runAs ( sysAdmin ) {
      Account acc =TestUtilUVS.createAccount('Vendor','FMS',false);
      acc.Transaction_Type__c = 'Retail';
      acc.Accountsource = 'Advertisement';
      acc.SAM_Cust_ID__c = 'abc';
      insert acc;

      Test.StartTest();
      Opportunity opp = TestUtilUVS.createOpportunity('UVS Opportunity',acc , False, null);
      opp.CloseDate = date.today().addDays(-5);
      opp.CurrencyISOCode = 'USD';
      insert opp;
      Test.StopTest();
      
      Quote q = TestUtilUVS.createQuote('UVS', false);
      //q.contactId = newCon.id;
      q.OpportunityId = opp.id;
      insert q;
      
      Product2 prod1 = new Product2();
      prod1.Name = 'UVS-UVW-Used';
      prod1.CurrencyIsoCode = 'USD';
      insert prod1;
      
      
      PriceBook2 UVSPriceBook = [Select Id from PriceBook2 where Name = 'UVS' limit 1];
      
      Ryder_Branch__c rb = new Ryder_Branch__c();
      rb.Branch_Code__c = '123';
      insert rb;
      Customer_Branch__c cstB = new Customer_Branch__c();
      cstB.Ryder_branch__c = rb.id;
      cstB.Ryder_HQ_Account__c = acc.id;
      insert cstB;
      
      list<Vehicle__c> lstvehicle = new list<Vehicle__c>();
      Vehicle__c v1 = new Vehicle__c(Name='12');
      v1.CUSTOMER_BRANCH__c = cstB.id;
      v1.Is_Available_For_Sale__c = true;
      v1.Sold_Flag__c = false ;
      v1.Sam_Class__c = 'UVW';
      v1.Ask_Price__c = 20000.0;
      lstvehicle.add(v1);
      Vehicle__c v = new Vehicle__c(Name='12');
      v.CUSTOMER_BRANCH__c = cstB.id;
      v.Is_Available_For_Sale__c = true;
      v.Sold_Flag__c = false ;
      v.Sam_Class__c = 'DEF';
      v.Ask_Price__c = 20000.0;
      v.Ask_Price__c = 20000.0;
      lstvehicle.add(v);

      insert lstvehicle;
      
      PricebookEntry PBE1 = new PricebookEntry();
      PBE1.Product2Id = prod1.Id;
      PBE1.Pricebook2Id = UVSPriceBook.Id;
      PBE1.UnitPrice = 100.00;
      PBE1.IsActive = true;
      PBE1.CurrencyIsoCode = 'USD';
      insert PBE1;

      PageReference tpageRef = Page.AddProductsCustom;
      Test.setCurrentPage(tpageRef);

      //ApexPages.currentPage().getParameters().put('oppId', opp.Id);
      ApexPages.currentPage().getParameters().put('quoteId', q.Id);

      AddProductsCustomController objController = new AddProductsCustomController();
      AddProductsCustomController.getQuery();
      objController.unitNumber = '12';
      objController.search();
      objController.searchResults[0].isSelected = true;
      objController.selectVehicles();
    }
  }
}