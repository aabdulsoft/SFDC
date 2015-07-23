/******************************************************************************************
 *  Name    : AddProductsCustomController
 *  Purpose : Controller for custom Add Products Functionality (T-317748)
 *  Author  : Manisha Gupta
 *  Date    : 2014-09-05
 *  Version : 1.0
 *
 *  Modification History
 *  Date  Who   Description
 *
 ********************************************************************************************/
public with sharing class AddProductsCustomController {

  private static List<Schema.FieldSetMember> resultFieldSet;//
  private static Schema.DescribeSObjectResult describeSobject;
  public Id recordId{get;set;}
  private id oppId;
  private Id quoteId;
  public boolean isError{get;set;}


  public String unitNumber{get;set;}
  //search result
  public List<VehicleSelection> searchResults{get;set;}
  String currencyCode;
  // Constructor
  public AddProductsCustomController(){
    isError = false;
    oppId = ApexPages.CurrentPage().getParameters().get('oppId');
    quoteId = ApexPages.CurrentPage().getParameters().get('quoteId');
    Date oppEstimatedCloseDate;
    describeSobject = getDescribeSObject();
    this.searchResults = new List<VehicleSelection>();
    resultFieldset = getresultFieldSet();

    if(oppId <> null){
        recordId = oppId;
            for(Opportunity opp : [Select CloseDate, CurrencyISOCode from Opportunity where Id = :oppId]){
                if(opp.CloseDate <> null){
                  oppEstimatedCloseDate = opp.CloseDate;
                }
                currencyCode = opp.CurrencyISOCode;

            }
    }else if(quoteId <> null){
        recordId = quoteId;
            for(Quote q : [Select Opportunity.CloseDate, Opportunity.CurrencyISOCode from Quote where Id = :quoteId]){
          if(q.Opportunity.CloseDate <> null){
           oppEstimatedCloseDate = q.Opportunity.CloseDate;
          }
          currencyCode = q.opportunity.CurrencyISOCode;
        }
    }
  }

  // method to get filter field set
  public static List<Schema.FieldSetMember> getResultFieldSet(){
    return getFieldSet('AddProducts_ResultFieldSet');
  }

  // method to get field set
  public static List<Schema.FieldSetMember> getFieldSet(String fieldSetName){
    describeSobject = getDescribeSObject();
    Schema.FieldSet fieldset = describeSobject.FieldSets.getMap().get(fieldSetName);
    return fieldset.getFields();
  }

  // method to get describe sObject result for object
  public static Schema.DescribeSObjectResult getDescribeSObject(){
    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Vehicle__c');
    describeSobject = SObjectTypeObj.getDescribe();
    return describeSobject;
  }

  // method to get query string using result field set
  public static String getQuery(){
    Set<String> fields = new Set<String>();
    fields.add('Id');
    fields.add('Name');
    fields.add('PRODUCT_LINE__c');
    fields.add('NBV__c');
    for(Schema.FieldSetMember f : getResultFieldSet()) {
      //no base64 strings or textarea
      if(f.getType()== Schema.DisplayType.TextArea || f.getType()== Schema.DisplayType.base64) continue;
      fields.add(f.getFieldPath());
    }
    String query = 'Select convertCurrency(Take_Price__c), convertCurrency(Ask_Price__c), '+String.join(new List<String>(fields),',')+' From Vehicle__c';
    return query;
  }


  // method to seach records
  public void search(){
    try{
      if(unitNumber == null || unitNumber == ''){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Vehicle Unit Number to search'));
          return;
      }
      searchResults = new List<VehicleSelection>();
      for(Vehicle__c vehicle : getRecords()){
        searchResults.add(new VehicleSelection(false, vehicle));
      }
    }
    catch(Exception e){
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage() + 'Stack Trace' + e.getStackTraceString()));
    }
  }

  // method to get records
  private List<Vehicle__c> getRecords(){
    String query = getQuery();
    query += ' Where Name Like \''+ unitNumber + '%\' Order by Name asc limit 100';
    system.debug('=====Query============' + query);
    List<Vehicle__c> listVehicles = database.query(query);
    return listVehicles;
  }

  public PageReference selectVehicles(){
    Map<String,List<Vehicle__c>> mapProducts = new Map<String, List<Vehicle__c>>();
    List<Vehicle__c> listSelectedVehicle = new List<Vehicle__c>();
    Set<String> prodNamesForSlectedVehicles = new Set<String>();
    // create map of selected vehicles
    String prodName;
    for(VehicleSelection vehicle : searchResults){
      if(vehicle.isSelected){
        prodName = 'UVS-' + vehicle.vehicle.Sam_Class__c.split('-')[0].trim() + '-Used';
        listSelectedVehicle.add(vehicle.Vehicle);
        if(mapProducts.containsKey(prodName)){
            mapProducts.get(prodName).add(vehicle.Vehicle);
        }else{
            mapProducts.put(prodName,new List<Vehicle__c>{vehicle.Vehicle});
        }
      }
      /*if(vehicle.isSelected){
        mapProducts.put('UVS-' + vehicle.vehicle.Sam_Class__c.split('-')[0].trim() + '-Used', vehicle.Vehicle);
      }*/
    }
    system.debug('=========listSelectedVehicle=========' + listSelectedVehicle);

    if(listSelectedVehicle.isEmpty()){
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select at least one vehicle' ));
      return null;
    }

    // get price books for both UVS and Standard
    // In order to create price book entry for custom price books, first we need to create price book entries for standard price books
    PriceBook2 UVSPriceBook = [Select Id from PriceBook2 where Name = 'UVS' limit 1];
    PriceBook2 StdPriceBook = [Select Id from PriceBook2 where IsStandard = true limit 1];
    set<Id> existingItemVehicleIds = new Set<Id>();
    if(oppId <> null){
    // remove vehicle name from map if that vehicle is already added as an opplineitem
      for(OpportunityLineItem oppLineItem : [Select PriceBookEntry.Product2.Name, Unit_Number__c
                                            from OpportunityLineItem
                                            where Unit_Number__c in :listSelectedVehicle
                                            and OpportunityId = :oppId]){
        existingItemVehicleIds.add(oppLineItem.Unit_Number__c);
        //mapProducts.remove(oppLineItem.PriceBookEntry.Product2.Name);
      }

    }
    if(quoteId <> null){
      // remove vehicle name from map if that vehicle is already added as a quote line item
      for(QuoteLineItem quoteLineItem : [Select PriceBookEntry.Product2.Name, Vehicle__c
                                         from QuoteLineItem
                                         where QuoteId = :QuoteId
                                         and Vehicle__c in :listSelectedVehicle]){
        existingItemVehicleIds.add(quoteLineItem.Vehicle__c);
        //mapProducts.remove(quoteLineItem.PriceBookEntry.Product2.Name);
      }
    }
    // list of opportunity line items to be inserted
    List<OpportunityLineItem> listNewOppLineItem = new List<OpportunityLineItem>();
    List<QuoteLineItem> listNewQuoteLineItem = new List<QuoteLineItem>();
    Set<Id> setExistingUVSPBEIds = new Set<Id>();
    //Vehicle__c vehicle;
    for(PriceBookEntry pbe :[Select Name, Product2.Name, Product2Id,Product2.Family from PriceBookEntry
                              where PriceBook2Id = :UVSPriceBook.Id and
                              Product2.Name in : mapProducts.keySet()
                              and CurrencyIsoCode = :currencyCode]){
      setExistingUVSPBEIds.add(pbe.Product2Id);
      if(oppId <> null){
        for(Vehicle__c vehicle : mapProducts.get(pbe.Product2.Name)){
          if(!existingItemVehicleIds.contains(vehicle.Id)){
            listNewOppLineItem.add(createOpportunityLineItem(vehicle, pbe.Id,pbe.Product2.Family));
            existingItemVehicleIds.add(vehicle.Id);
          }

        }
      }
      if(quoteId <> null){
        for(Vehicle__c vehicle : mapProducts.get(pbe.Product2.Name)){
          if(!existingItemVehicleIds.contains(vehicle.Id)){
            listNewQuoteLineItem.add(createQuoteLineItem(vehicle, pbe.Id));
            existingItemVehicleIds.add(vehicle.Id);
          }
        }
      }
    }



    List<PriceBookEntry> listNewPriceBookEntries_UVS = new list<PriceBookEntry>();

    List<PriceBookEntry> listNewPriceBookEntries_Std = new list<PriceBookEntry>();

    // get existing products for selected vehicles
    Map<String,Product2> mapExistingProduct = new Map<String, Product2>();
    for(Product2 existingProduct : [Select Id, Name from Product2 where Name in : mapProducts.keySet() and isActive = true]){
      mapExistingProduct.put(existingProduct.Name, existingProduct);

    }

    set<Id> setExistingStdPBEProdIds = new set<id>();
    for(PriceBookEntry pbe : [Select Id, Product2Id from PriceBookEntry
                              where Product2Id in :mapExistingProduct.values()
                              and PriceBook2.IsStandard = true
                              and CurrencyIsoCode = :currencyCode])   {
      setExistingStdPBEProdIds.add(pbe.Product2Id);
    }

    for(Product2 existingProduct : mapExistingProduct.values()){
        if(!setExistingStdPBEProdIds.contains(existingProduct.Id)){
          listNewPriceBookEntries_Std.add(new PriceBookEntry(Product2Id = existingProduct.Id,
                                                           PriceBook2Id = StdPriceBook.Id,
                                                           UnitPrice = 0.0,
                                                           CurrencyIsoCode = currencyCode));
        }
    }

    if(!listNewPriceBookEntries_Std.isEmpty()){
        insert listNewPriceBookEntries_Std;
    }

    /*
    List<Product2> listNewProducts = new List<Product2>();
    for(String productName : mapProducts.keySet()){
      if(!mapExistingProduct.containsKey(productName)){
        listNewProducts.add(new Product2(Name=productName, isActive=True));
      }
    }
    if(!listNewProducts.isEmpty()){
      insert listNewProducts;
    }*/
    // update the Opportunity and Quote Price Book to UVS
    Opportunity opp;
    if(oppId <> null){
      opp = [Select Id,PriceBook2Id from Opportunity where Id = :oppId];
    }
    if(quoteId <> null){
      Quote quote = [Select OpportunityId, Opportunity.PriceBook2Id, PriceBook2Id from Quote where Id = :quoteId];
      if(quote.PriceBook2Id <> UVSPriceBook.Id){
        quote.Pricebook2Id = UVSPriceBook.Id;
        update quote;
      }
      opp = new Opportunity(Id = quote.OpportunityId, PriceBook2Id = quote.Opportunity.PriceBook2Id );
    }

    if(opp.Pricebook2Id <> UVSPriceBook.Id){
      opp.Pricebook2Id = UVSPriceBook.Id;
      update opp;
    }
    // Create UVS Price book entries for existing products
    for(Product2 newProd : mapExistingProduct.values()){
      if(!setExistingUVSPBEIds.contains(newProd.Id)){
          listNewPriceBookEntries_UVS.add(new PriceBookEntry(Pricebook2Id = UVSPriceBook.Id,
                                    Product2Id = newProd.Id,
                                    UnitPrice = 0.00,
                                    UseStandardPrice = false,
                                    isActive = True,
                                    CurrencyIsoCode = currencyCode));
      }
    }
    if(!listNewPriceBookEntries_UVS.isEmpty()){
      insert listNewPriceBookEntries_UVS;
    }
    // Create Opportunity/Quote Line Items from Price Book Entries
    for(PriceBookEntry pbe :[Select Name, Product2.Name,Product2.Family
                             from PriceBookEntry
                             where Id in :listNewPriceBookEntries_UVS ]){
      if(oppId <> null){
        for(Vehicle__c vehicle : mapProducts.get(pbe.Product2.Name)){
          if(!existingItemVehicleIds.contains(vehicle.Id)){
            listNewOppLineItem.add(createOpportunityLineItem(vehicle, pbe.Id,pbe.Product2.Family));
            existingItemVehicleIds.add(vehicle.Id);
          }

        }
      }
      if(quoteId <> null){
        for(Vehicle__c vehicle : mapProducts.get(pbe.Product2.Name)){
          if(!existingItemVehicleIds.contains(vehicle.Id)){
            listNewQuoteLineItem.add(createQuoteLineItem(vehicle, pbe.Id));
            existingItemVehicleIds.add(vehicle.Id);
          }
        }
      }
    }
    if(!listNewOppLineItem.isEmpty()){
        system.debug('::INsert PLI >>>'+listNewOppLineItem);
      insert listNewOppLineItem;
    }

    if(!listNewQuoteLineItem.isEmpty()){
      insert listNewQuoteLineItem;
    }

    if(oppId <> null){
      return new Pagereference('/'+oppId);
    }else if(quoteId <> null){
      return new Pagereference('/'+quoteId);
    }
    return null;
  }

  // method to create quote line item
  // Vehicle : Vehicle Object record
  // pbeId : Id of price book entry record
  private QuoteLineItem createQuoteLineItem(Vehicle__c vehicle, Id pbeId){
    QuoteLineItem QLI = new QuoteLineItem(Quantity=1,
                                            Vehicle__c = vehicle.Id,
                                            Take_Price2__c = vehicle.Take_Price__c,
                                            UnitPrice = 0,                                          
                                            quoteId = quoteId,
                                            PriceBookEntryId = pbeId);
    if(Vehicle.Ask_Price__c != null)
        QLI.UnitPrice = Vehicle.Ask_Price__c;
    return QLI;
  }

  // method to create opportunity line item
  // Vehicle : Vehicle Object record
  // pbeId : Id of price book entry record
  private OpportunityLineItem createOpportunityLineItem(Vehicle__c vehicle, Id pbeId,String family){
    system.debug('::vehicle::::'+vehicle);
    OpportunityLineItem OLI = new OpportunityLineItem(Quantity=1,
                                                Unit_Number__c = vehicle.Id,
                                                Take_Price2__c = vehicle.Take_Price__c,
                                                //Book_Value__c = vehicle.NBV__c,
                                                UnitPrice = 0,
                                                OpportunityId = oppId,
                                                Product_Line__c  = family,
                                                PriceBookEntryId = pbeId);
    if(Vehicle.Ask_Price__c != null)
        OLI.UnitPrice = Vehicle.Ask_Price__c;    
    return OLI;
  }

  // On Cancel navigate to source opportunity
  public Pagereference cancel(){
    if(oppId <> null){
      return new Pagereference('/'+oppId);
    }else if(quoteId <> null){
      return new Pagereference('/'+quoteId);
    }
    return null;

  }

  //Wrapper class for vehicle selection
  public class VehicleSelection{
    public boolean isSelected{get;set;}
    public Vehicle__c vehicle{get;set;}

    public vehicleSelection(boolean isSelected, Vehicle__c vehicle){
      this.isSelected = isSelected;
      this.vehicle = vehicle;
    }
  }
}