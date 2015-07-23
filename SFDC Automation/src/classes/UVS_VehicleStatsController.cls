/***********************************************************************
 Class          : UVS_VehicleStatsController
 Author         : Manisha Gupta
 Descritption   : Controller class for Vehicle Stats Page on BTR Screen

 Date       Modified By         Description

 ************************************************************************/
public class UVS_VehicleStatsController {
  public String sellingAge{get;set;}
  public String country{get;set;}
  public Vehicle__c vehicle{get;set;}
  public list<SelectOption> sellingAgeList{get;set;}
  public List<SelectOption> countryList{get;set;}
  public List<CurrentInventory> currentInventoryList{get;set;}
  public List<SoldInventory> soldInventoryList{get;set;}
  public String btrId{get;set;}
  public String samClass{get;set;}

  public List<SelectOption> getListSAMClass() {
  	// create sam class picklist
    List<SelectOption> options = new List<SelectOption>();
    Schema.DescribeFieldResult fieldResult = VehicleSearchSetting__c.SAM_Truck__c.getDescribe();
    List<Schema.PicklistEntry> listPicklistEntry = fieldResult.getPicklistValues();
    for(Schema.PicklistEntry f : listPicklistEntry){
        options.add(new SelectOption(f.getLabel(), f.getValue()));
    }
    fieldResult = VehicleSearchSetting__c.SAM_Trailer__c.getDescribe();
    listPicklistEntry = fieldResult.getPicklistValues();
    for(Schema.PicklistEntry f : listPicklistEntry){
        options.add(new SelectOption(f.getLabel(), f.getValue()));
    }
    fieldResult = VehicleSearchSetting__c.SAM_Tractor__c.getDescribe();
    listPicklistEntry = fieldResult.getPicklistValues();
    for(Schema.PicklistEntry f : listPicklistEntry){
        options.add(new SelectOption(f.getLabel(), f.getValue()));
    }
    return options;
  }

  public UVS_VehicleStatsController(){
  	btrId = ApexPages.CurrentPage().getParameters().get('BTRId');
  	// get vehicle details and populate country, sam class and selling age
    for(Vehicle__c veh : [Select Sam_Class__c, Days_At_UTC__c, Customer_Branch__r.Ryder_Branch__r.Country_Name__c, Model_Year__c
               from Vehicle__c
               where Id = :ApexPages.currentPage().getParameters().get('Id')]){
      vehicle = veh;
    }
    if(vehicle <> null){
    	country = vehicle.Customer_Branch__c <> null && vehicle.Customer_Branch__r.Ryder_Branch__c <> null ?
    	             vehicle.Customer_Branch__r.Ryder_Branch__r.Country_Name__c : '';
	    samClass = vehicle.SAM_Class__c <> null ? vehicle.SAM_Class__c.split('-')[0].trim(): null;

	    if(vehicle.Days_At_UTC__c == null){
	      sellingAge = '0';
	    }
	    if(vehicle.Days_At_UTC__c <= 180){
	        sellingAge = '1';
	    }else if(vehicle.Days_At_UTC__c >= 181 && vehicle.Days_At_UTC__c <= 390){
	      sellingAge = '2';
	    }else{
	        sellingAge = '3';
	    }
    }


    // create selling age picklist
    sellingAgeList = new List<SelectOption>();
    sellingAgeList.add(new SelectOption('0', '--None--'));
    sellingAgeList.add(new SelectOption('1', '0 - 180 days'));
    sellingAgeList.add(new SelectOption('2', '181 - 390 days'));
    sellingAgeList.add(new SelectOption('3', '391 - older'));

    // create country picklist
    countryList = new List<SelectOption>();
    countryList.add(new SelectOption('CA', 'CA'));
    countryList.add(new SelectOption('US', 'US'));
    searchVehicles();

  }

  // method to search vehicles
  public Pagereference searchVehicles(){
    // query for current inventory
    String query = 'Select Make__c, Model__c, Sum(Unit_Count__c) UnitCount '+
                   ' from BTR_Stats__c ' +
                   ' Where Sam_Class__c Like \'' + samClass + '%\'' +
                   ' and Year__c = \'' + String.valueOf(vehicle.Model_Year__c) +'\''+
                   ' and Country__c = \'' + country + '\'' +
                   ' and Is_Current_Inventory__c = true ' +
                   ' group by Make__c, Model__c ';
    system.debug('==========QUERY===========' + query);
    currentInventoryList = new List<CurrentInventory>();
    for(AggregateResult agg : database.query(query)){
      currentInventoryList.add(new CurrentInventory((String)agg.get('Make__c'), (String)agg.get('Model__c'), Integer.valueOf(agg.get('UnitCount'))));
    }

    // get sold inventory
    soldInventoryList = new List<SoldInventory>();
    String samClassQueryString = samClass + '%';
    String soldInvQuery = 'Select Sum(Unit_Count__c) unitCount, Sum(Sales_Proceeds__c) salesProceeds, Make__c, Model__c, Mileage_Tier__c '+
                          'from BTR_Stats__c '+
                          'where SAM_Class__c Like :samClassQueryString '+
                          ' and Country__c = :country '+
                          ' and Year__c = \'' + String.valueOf(vehicle.Model_Year__c) + '\'' +
                          ' and Is_Current_Inventory__c = false '+
                          ' and selling_Age__c != null and Selling_Age__c = ' + Integer.valueOf(sellingAge) +
                          ' group by Make__c, Model__c, Mileage_Tier__c ' ;

    for(AggregateResult soldInv : database.query(soldInvQuery)){
      soldInventoryList.add(new SoldInventory((String)soldInv.get('Make__c'),
                                               (String)soldInv.get('Model__c'),
                                               (String)soldInv.get('Mileage_Tier__c'),
                                               Integer.valueOf(soldInv.get('salesProceeds')),
                                               Integer.valueOf(soldInv.get('unitCount'))));
    }

    return null;
  }

  // class to hold current inventory details
  public class CurrentInventory{
    public String make{get;set;}
    public String model{get;set;}
    public Integer unitCount{get;set;}

    public CurrentInventory(String make, String model, Integer unitCount){
        this.make = make;
        this.model = model;
        this.unitCount = unitCount;
    }
  }

  // class to hold sold inventory details
  public class SoldInventory{
    public String make{get;set;}
    public String model{get;set;}
    public String mileageTier{get;set;}
    public Integer salesProceeds{get;set;}
    public Integer unitCount{get;set;}

    public SoldInventory(String make, String model, String mileageTier, Integer salesProceeds, Integer unitCount){
        this.make = make;
        this.model = model;
        this.mileageTier = mileageTier;
        this.salesProceeds = salesProceeds;
        this.unitCount = unitCount;

    }

  }

}