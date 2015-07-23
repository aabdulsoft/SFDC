public with sharing class SearchMasterInventoryController {

  // for Tractor
  public string daysAtUTCStartTractor{get;set;}
  public string daysAtUTCEndTractor{get;set;}
  public string odomSamStartTractor{get;set;}
  public string odomSamEndTractor{get;set;}
  public string salesPriceStartTractor{get;set;}
  public string salesPriceEndTractor{get;set;}
  public string modelYearStartTractor{get;set;}
  public string modelYearEndTractor{get;set;}

  // for Truck
  public string daysAtUTCStartTruck{get;set;}
  public string daysAtUTCEndTruck{get;set;}
  public string odomSamStartTruck{get;set;}
  public string odomSamEndTruck{get;set;}
  public string salesPriceStartTruck{get;set;}
  public string salesPriceEndTruck{get;set;}
  public string modelYearStartTruck{get;set;}
  public string modelYearEndTruck{get;set;}

  // for Trailer
  public string daysAtUTCStartTrailer{get;set;}
  public string daysAtUTCEndTrailer{get;set;}
  public string odomSamStartTrailer{get;set;}
  public string odomSamEndTrailer{get;set;}
  public string salesPriceStartTrailer{get;set;}
  public string salesPriceEndTrailer{get;set;}
  public string modelYearStartTrailer{get;set;}
  public string modelYearEndTrailer{get;set;}
  
  public Vehicle__c tractorToSearch{get;set;} // Virendra need to confirm with manisha why it was  missing from controller 
  public Vehicle__c trailerToSearch {get;set;}
  public Vehicle__c truckToSearch {get;set;}
   
  transient private Map<String, Schema.SObjectField> objectFieldMap;

    public String selectedTab {get;set;}
    public VehicleSearchSetting__c searchObjTruck{get;set;}
    public VehicleSearchSetting__c searchObjTractor{get;set;}
    public VehicleSearchSetting__c searchObjTrailer{get;set;}
    transient private String vehicleSOQL;

    transient public Integer tractorsAvailableForSale{get;set;}
    transient public Integer tractorsSalesInProcess{get;set;}
    transient public Integer tractorsOsInProcess{get;set;}

    transient public Integer trucksAvailableForSale{get;set;}
    transient public Integer trucksSalesInProcess{get;set;}
    transient public Integer trucksOsInProcess{get;set;}

    transient public Integer trailersAvailableForSale{get;set;}
    transient public Integer trailersSalesInProcess{get;set;}
    transient public Integer trailersOsInProcess{get;set;}

    transient public List<Vehicle__c> searchResultTrucks{get;set;}
    transient public List<Vehicle__c> searchResultTrailers{get;set;}
    transient public List<Vehicle__c> searchResultTractors{get;set;}

    transient public List<List<Vehicle__c>> searchResultTrucksExcel{get;set;}
    transient public List<List<Vehicle__c>> searchResultTrailersExcel{get;set;}
    transient public List<List<Vehicle__c>> searchResultTractorsExcel{get;set;}
    transient public map<String, Sam_Class_Limits__c> samClassLimitMap;

    transient public String resultSizeError_Truck{get;set;}
    transient public String resultSizeError_Tractor{get;set;}
    transient public String resultSizeError_Trailer{get;set;}
    // the current sort direction. defaults to asc
  public String sortDir {
    get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
    set;
  }
  private string previousSortField;
    private string sortOrder;
    public string sortField{set;get;}
    public boolean isAsc{set; get;}

  public SearchMasterInventoryController(){
    initialize();
  }
    public SearchMasterInventoryController(ApexPages.StandardController sc){
        initialize();
    }

    private void initialize(){
    selectedTab = 'Truck';
    searchObjTruck = new VehicleSearchSetting__c();
    searchObjTractor = new VehicleSearchSetting__c();
    searchObjTrailer = new VehicleSearchSetting__c();
    searchResultTrucks = new list<Vehicle__c>();
    searchResultTrailers = new list<Vehicle__c>();
    searchResultTractors = new list<Vehicle__c>();
    samClassLimitMap = getSAMClassLimits();
    previousSortField = sortField = 'SAM_Desc__c';
    sortOrder = 'Asc';
    isAsc = true;

    tractorsAvailableForSale = 0;
    tractorsSalesInProcess = 0;
    tractorsOsInProcess = 0;

    trucksAvailableForSale = 0;
    trucksSalesInProcess = 0;
    trucksOsInProcess = 0;

    trailersAvailableForSale = 0;
    trailersSalesInProcess = 0;
    trailersOsInProcess = 0;
  }

  // method to get field set
  public List<Schema.FieldSetMember> getFieldSet(String fieldSetName){
    Schema.DescribeSObjectResult describeSobject = getDescribeSearchInput();
    Schema.FieldSet fieldset = describeSobject.FieldSets.getMap().get(fieldSetName);
    return fieldset.getFields();
  }

  // method to get describe sObject result for object
  public Schema.DescribeSObjectResult getDescribeSObject(){
    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Vehicle__c');
    Schema.DescribeSObjectResult describeSobject = SObjectTypeObj.getDescribe();
    //objectFieldMap = Schema.sObjectType.Vehicle__c.fields.getMap();
    return describeSobject;
  }

  public Schema.DescribeSObjectResult getDescribeSearchInput(){
    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('VehicleSearchSetting__c');
    Schema.DescribeSObjectResult describeSobject = SObjectTypeObj.getDescribe();
    //objectFieldMap = Schema.sObjectType.VehicleSearchSetting__c.fields.getMap();
    return describeSobject;
  }
  // method to get filter field set
  public List<Schema.FieldSetMember> getResultFieldSet(String fieldSetName){
    return getFieldSet(fieldSetName);
  }

  public String createQuery() {
    Map<String, String> searchFieldMap = populateFieldMapping();
    Set<String> numberFields = new Set<String>{'Gear_Ratio__c',
                                             'Model_Year__c',
                                             'Wheel_Base__c',
                                             'Body_Height__c',
                                             'Body_Length__c',
                                             'Body_Width__c',
                                             'ENG_HP__c',
                                             'GVW_SAM__c'};
    Set<String> fields = new Set<String>();
    fields.add('Id');
    fields.add('Name');
    objectFieldMap = Schema.sObjectType.VehicleSearchSetting__c.fields.getMap();
    for(Schema.FieldSetMember f : Schema.getGlobalDescribe().get('Vehicle__c').getDescribe().FieldSets.getMap().get('VehicleMasterInventorySearchResult_Field').getFields()) {
        fields.add(f.getFieldPath());
    }
    if(!fields.contains('Availability__c')) fields.add('Availability__c');
    String query = 'Select '+String.join(new List<String>(fields),',')+' From Vehicle__c' ;

    String filterCriteria = ' Where Sold_Flag__c = false AND Availability__c <> null AND Availability__c <> \'NA\''; // Hari K(2014-11-21): Removed the 'Is_Available_For_Sale__c = True' condition based on the feedback from Franklin.
    System.debug('$$$: query = ' + query + filterCriteria);
    String SEARCH_FIELD_SET = selectedTab + '_Filter_Fields';
    //System.debug(':::SEARCH_FIELD_SET--------::' + SEARCH_FIELD_SET);
    //System.debug(':::searchFieldMap--------::' + searchFieldMap);
    boolean isFilterSelected = false;
    boolean isSamClassSelected = false;
    for(Schema.FieldSetMember f : Schema.getGlobalDescribe().get('VehicleSearchSetting__c').getDescribe().FieldSets.getMap().get(SEARCH_FIELD_SET).getFields()) {
        //System.debug(':::f.getFieldPath()--------::' + f.getFieldPath());
        String fieldName = searchFieldMap.get(f.getFieldPath());
        //System.debug(':::fieldName--------::' + fieldName);
        if(fieldName <> null) {
            //if(objectFieldMap.get(f.getFieldPath()).getDescribe().isFilterable() && .get(f.getFieldPath()) != null){
                 String dtm = String.valueOf(objectFieldMap.get(f.getFieldPath()).getDescribe().getType()).toUpperCase();
                 String value = '';
                 // Basedon selected tab, Search filter values get change based on search field set instance
                 if(selectedTab == 'Truck') {
                    value = String.valueOf(searchObjTruck.get(f.getFieldPath()));
                 }else if(selectedTab == 'Tractor') {
                    value = String.valueOf(searchObjTractor.get(f.getFieldPath()));
                }else if(selectedTab == 'Trailer') {
                 value = String.valueOf(searchObjTrailer.get(f.getFieldPath()));
                 }
                 if(value == null || value == '') continue;
                 if (dtm.equals('BOOLEAN')) {
                  //  isFilterSelected = true;
                    filterCriteria += ' and ' + fieldName + '='+ value;
                 } else if (dtm.equals('STRING')) {
                    filterCriteria += ' and ' + fieldName + ' like \'%' + value + '%\'';
                 //   isFilterSelected = true;
                 } else if(numberFields.contains(fieldName)){
                    isFilterSelected = true;
                    filterCriteria += ' and ' + fieldName + '='+ value;
                 }else if(fieldName == 'SAM_Class__c'){
                    filterCriteria += ' and (' + fieldName + ' like \'' + value + ' %\' OR ' + fieldName + ' = \'' + value + '\')';
                    isFilterSelected = true;
                    isSamClassSelected = true;
                 } else {
                    filterCriteria += ' and ' + fieldName + '=\''+value+'\'';
                    isFilterSelected = true;
                 }
        }
    }
	try{
	    if(selectedTab == 'Truck') {
	        if(daysAtUTCStartTruck <> null && daysAtUTCStartTruck != ''){
	            filterCriteria += ' and Days_At_Utc__c >= '+Integer.ValueOf(daysAtUTCStartTruck.trim()) ;
	            isFilterSelected = true;
	        }
	        if(daysAtUTCEndTruck <> null && daysAtUTCEndTruck != ''){
	          filterCriteria += ' and Days_At_Utc__c <= '+Integer.ValueOf(daysAtUTCEndTruck.trim()) ;
	          isFilterSelected = true;
	        }

	        if(odomSAMStartTruck <> null && odomSAMStartTruck != ''){
	          filterCriteria += ' and SAM_Odom__c >= '+Integer.ValueOf(odomSAMStartTruck.trim()) ;
	          isFilterSelected = true;
	        }
	        if(odomSAMEndTruck <> null && odomSAMEndTruck != ''){
	          filterCriteria += ' and SAM_Odom__c <= '+Integer.ValueOf(odomSAMEndTruck.trim()) ;
	          isFilterSelected = true;
	        }

	        if(salesPriceStartTruck <> null && salesPriceStartTruck != ''){
	          filterCriteria += ' and Sales_Price__c >= '+Integer.ValueOf(salesPriceStartTruck.trim()) ;
	          isFilterSelected = true;
	        }
	        if(salesPriceEndTruck <> null && salesPriceEndTruck != ''){
	          filterCriteria += ' and Sales_Price__c <= '+Integer.ValueOf(salesPriceEndTruck.trim()) ;
	          isFilterSelected = true;
	        }

	        if(modelYearStartTruck <> null && modelYearStartTruck != ''){
	          filterCriteria += ' and Model_Year__c >= '+Integer.ValueOf(modelYearStartTruck.trim()) ;
	          isFilterSelected = true;
	        }
	        if(modelYearEndTruck <> null && modelYearEndTruck != ''){
	          filterCriteria += ' and Model_Year__c <= '+Integer.ValueOf(modelYearEndTruck.trim()) ;
	          isFilterSelected = true;
	        }
	    }else if(selectedTab == 'Tractor') {
	        if(daysAtUTCStartTractor <> null && daysAtUTCStartTractor != ''){
	            filterCriteria += ' and Days_At_Utc__c >= '+Integer.ValueOf(daysAtUTCStartTractor.trim()) ;
	            isFilterSelected = true;
	        }
	        if(daysAtUTCEndTractor <> null && daysAtUTCEndTractor != ''){
	          filterCriteria += ' and Days_At_Utc__c <= '+Integer.ValueOf(daysAtUTCEndTractor.trim()) ;
	          isFilterSelected = true;
	        }

	        if(odomSAMStartTractor <> null && odomSAMStartTractor != ''){
	          filterCriteria += ' and SAM_Odom__c >= '+Integer.ValueOf(odomSAMStartTractor.trim()) ;
	          isFilterSelected = true;
	        }
	        if(odomSAMEndTractor <> null && odomSAMEndTractor != ''){
	          filterCriteria += ' and SAM_Odom__c <= '+Integer.ValueOf(odomSAMEndTractor.trim()) ;
	          isFilterSelected = true;
	        }

	        if(salesPriceStartTractor <> null && salesPriceStartTractor != ''){
	          filterCriteria += ' and Sales_Price__c >= '+Integer.ValueOf(salesPriceStartTractor.trim()) ;
	          isFilterSelected = true;
	        }
	        if(salesPriceEndTractor <> null && salesPriceEndTractor != ''){
	          filterCriteria += ' and Sales_Price__c <= '+Integer.ValueOf(salesPriceEndTractor.trim()) ;
	          isFilterSelected = true;
	        }

	        if(modelYearStartTractor <> null && modelYearStartTractor != ''){
	          filterCriteria += ' and Model_Year__c >= '+Integer.ValueOf(modelYearStartTractor.trim()) ;
	          isFilterSelected = true;
	        }
	        if(modelYearEndTractor <> null && modelYearEndTractor != ''){
	          filterCriteria += ' and Model_Year__c <= '+Integer.ValueOf(modelYearEndTractor.trim()) ;
	          isFilterSelected = true;
	        }
	    }else if(selectedTab == 'Trailer') {
	        if(daysAtUTCStartTrailer <> null && daysAtUTCStartTrailer != ''){
	            filterCriteria += ' and Days_At_Utc__c >= '+Integer.ValueOf(daysAtUTCStartTrailer.trim()) ;
	            isFilterSelected = true;
	        }
	        if(daysAtUTCEndTrailer <> null && daysAtUTCEndTrailer != ''){
	          filterCriteria += ' and Days_At_Utc__c <= '+Integer.ValueOf(daysAtUTCEndTrailer.trim()) ;
	          isFilterSelected = true;
	        }

	        if(odomSAMStartTrailer <> null && odomSAMStartTrailer != ''){
	          filterCriteria += ' and SAM_Odom__c >= '+Integer.ValueOf(odomSAMStartTrailer.trim()) ;
	          isFilterSelected = true;
	        }
	        if(odomSAMEndTrailer <> null && odomSAMEndTrailer != ''){
	          filterCriteria += ' and SAM_Odom__c <= '+Integer.ValueOf(odomSAMEndTrailer.trim()) ;
	          isFilterSelected = true;
	        }

	        if(salesPriceStartTrailer <> null && salesPriceStartTrailer != ''){
	          filterCriteria += ' and Sales_Price__c >= '+Integer.ValueOf(salesPriceStartTrailer.trim()) ;
	          isFilterSelected = true;
	        }
	        if(salesPriceEndTrailer <> null && salesPriceEndTrailer != ''){
	          filterCriteria += ' and Sales_Price__c <= '+Integer.ValueOf(salesPriceEndTrailer.trim()) ;
	          isFilterSelected = true;
	        }

	         if(modelYearStartTrailer <> null && modelYearStartTrailer != ''){
	          filterCriteria += ' and Model_Year__c >= '+Integer.ValueOf(modelYearStartTrailer.trim()) ;
	          isFilterSelected = true;
	        }
	        if(modelYearEndTrailer <> null && modelYearEndTrailer != ''){
	          filterCriteria += ' and Model_Year__c <= '+Integer.ValueOf(modelYearEndTrailer.trim());
	          isFilterSelected = true;
	        }
	    }
	}
	catch(exception ex){
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Days At UTC, ODOM SAM, Sales Price and Model Year can contains only numeric values.' + ex.getmessage()));
		return null;
	}


    if(!isFilterSelected) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select at least one filter criteria.'));
        return null;
    }
    samClassLimitMap = getSAMClassLimits();
    if((!isSamClassSelected) && samClassLimitMap.containsKey(selectedTab)) {
        filterCriteria += ' and SAM_Class__c > \'' + samClassLimitMap.get(selectedTab).Lower_Limit__c + '%\'  AND SAM_Class__c < \'' + samClassLimitMap.get(selectedTab).Upper_Limit__c + '%\'' ;
    }
    //System.debug(':::query:after condition::' + query + filterCriteria);
    query += filterCriteria + ' order by ' + sortField + ' ' + sortOrder + ' nulls last';// + (Limits.getLimitQueryRows() - Limits.getQueryRows())  ;
    System.debug(':::query:after condition:::::::::::' + query );
    return query;
  }

  public PageReference selectTab() {
    return null;
  }

    public void searchVehicleInventory_Truck(){
        vehicleSOQL = createQuery();
        if(vehicleSOQL == null) return;
        vehicleSOQL += ' Limit 100';

        selectedTab = 'Truck';
        searchResultTrucks = new list<Vehicle__c>();
        trucksAvailableForSale = 0;
        trucksSalesInProcess = 0;
        trucksOsInProcess = 0;
        System.debug('$$$: SearchMasterInventoryController.searchVehicleInventory_Truck(): vehicleSOQL = ' + vehicleSOQL);
        try {
            searchResultTrucks = database.query(vehicleSOQL);
        } catch(Exception ex) {
            System.debug('$$$: SearchMasterInventoryController.searchVehicleInventory_Truck(): Exception message: ' + ex.getMessage() + ', stackTrace: ' + ex.getStackTraceString());
            throw ex;
        }
      if(searchResultTrucks.size() == 100){
        resultSizeError_Truck = 'Your search returned more than 100 rows. Only the first 100 are displayed. Please refine search criteria.';
      }else{
        resultSizeError_Truck = '';
      }
      for(Vehicle__c v : searchResultTrucks) {
        if(v.Availability__c == 'Available for Sale') {
          trucksAvailableForSale++;
        } else if(v.Availability__c == 'OS in Process') {
          trucksOsInProcess++;
        } else if(v.Availability__c == 'Sale in Process') {
          trucksSalesInProcess++;
        }
      }
    }

    public void searchVehicleInventory_Tractor(){
      selectedTab = 'Tractor';
      vehicleSOQL = createQuery();
      // if no filter is selected then do nothing.
        if(vehicleSOQL == null) return;
        vehicleSOQL += ' Limit 100';

        searchResultTractors = new list<Vehicle__c>();
        tractorsAvailableForSale = 0;
        tractorsSalesInProcess = 0;
        tractorsOsInProcess = 0;
        searchResultTractors = database.query(vehicleSOQL);
        if(searchResultTractors.size() == 100){
          resultSizeError_Tractor = 'Your search returned more than 100 rows. Only the first 100 are displayed. Please refine search criteria.';
        }else{
          resultSizeError_Tractor = '';
        }
        for(Vehicle__c v : searchResultTractors) {
        //searchResultTractors.add(v);
        if(v.Availability__c == 'Available for Sale') {
            tractorsAvailableForSale++;
        } else if(v.Availability__c == 'OS in Process') {
            tractorsOsInProcess++;
        } else if(v.Availability__c == 'Sale in Process') {
            tractorsSalesInProcess++;
        }
        }
    }
    public void searchVehicleInventory_Trailer(){
      selectedTab = 'Trailer';
      vehicleSOQL = createQuery();
      // if no filter is selected then do nothing.
        if(vehicleSOQL == null) return;
        vehicleSOQL += ' Limit 100';
        //System.debug('selectedTab---------:::' + selectedTab);

        searchResultTrailers = new list<Vehicle__c>();
        trailersAvailableForSale = 0;
        trailersSalesInProcess = 0;
        trailersOsInProcess = 0;
        searchResultTrailers = database.query(vehicleSOQL);
        if(searchResultTrailers.size() == 100){
          resultSizeError_Trailer = 'Your search returned more than 100 rows. Only the first 100 are displayed. Please refine search criteria.';
        }else{
          resultSizeError_Trailer = '';
        }
        for(Vehicle__c v : searchResultTrailers) {
            //searchResultTractors.add(v);
            if(v.Availability__c == 'Available for Sale') {
                trailersAvailableForSale++;
            } else if(v.Availability__c == 'OS in Process') {
                trailersOsInProcess++;
            } else if(v.Availability__c == 'Sale in Process') {
                trailersSalesInProcess++;
            }
        }
    }

    //used to sort
    public void sortData(){
        if (previousSortField.equals(sortField)){
          isAsc = !isAsc;
        }else{
          isAsc = true;
        }
        sortOrder = isAsc ? ' ASC ' : ' DESC ';
        previousSortField = sortField;
      if(selectedTab == 'Truck'){
        searchVehicleInventory_Truck();
      }else if(selectedTab == 'Tractor'){
        searchVehicleInventory_Tractor();
      }else if(selectedTab == 'Trailer'){
        searchVehicleInventory_Trailer();
      }
    }

    public map<String, String> populateFieldMapping() {
        map<String, String>  fieldMapping = new map<String, String>();
        for(Vehicle_And_Search_Input_Fields_Mapping__c mapping : Vehicle_And_Search_Input_Fields_Mapping__c.getAll().values()) {
            fieldMapping.put(mapping.Search_Input_Field__c, mapping.Vehilcle_Field__c);
        }
        return fieldMapping;
    }

    public map<String,Sam_Class_Limits__c> getSAMClassLimits() {
        map<String, Sam_Class_Limits__c>  scLimitMap = new map<String, Sam_Class_Limits__c>();
        for(Sam_Class_Limits__c limits : Sam_Class_Limits__c.getAll().values()) {
            scLimitMap.put(limits.Name, limits);
        }
        return scLimitMap;
    }

    /*public Pagereference exportToExcel() {
      vehicleSOQL = createQuery();
      vehicleSOQL += ' Limit ' + (limits.getLimitQueryRows() - limits.getQueryRows());
        if(selectedTab.equalsIgnoreCase('Truck')){
            searchResultTrucksExcel = database.query(vehicleSOQL);
        }else if(selectedTab.equalsIgnoreCase('Tractor')){
            searchResultTractorsExcel = database.query(vehicleSOQL);
        }else if(selectedTab.equalsIgnoreCase('Trailer')){
            searchResultTrailersExcel = database.query(vehicleSOQL);
        }
        return Page.SearchMasterInventoryPDF;
    }*/


    public Pagereference exportToExcel() {
        // 11/25/2014 : Manisha : Added to resolve Heap size issue.
        /*searchResultTrucksExcel = null;
        searchResultTractorsExcel = null;
        searchResultTrailersExcel = null; */
      Integer index = 0;
      Integer counter = 0;
      vehicleSOQL = createQuery();
      // 11/25/2014: Hari : Adding debug statements to troubleshoot the heap size issue. - need to remove these statements and comments once the issue is fixed.
      //System.debug('$$$: SearchMasterInventoryController.exportToExcel(): vehicleSOQL: ' + vehicleSOQL);
      vehicleSOQL += ' Limit 25000';// + (limits.getLimitQueryRows() - limits.getQueryRows());
      //System.debug('$$$: SearchMasterInventoryController.exportToExcel(): getLimitQueryRows(): ' + Limits.getLimitQueryRows() + ', getQueryRows(): ' + Limits.getQueryRows());
        if(selectedTab.equalsIgnoreCase('Truck')){
          searchResultTrucksExcel = new List<List<Vehicle__c>>();
          for(Vehicle__c truck : database.query(vehicleSOQL)){
            if(counter == 0){
              searchResultTrucksExcel.add(new List<Vehicle__c>{truck});
              counter++;
            }else if(counter == 999){
              searchResultTrucksExcel.get(index).add(truck);
              index++;
              counter = 0;
            }else{
              searchResultTrucksExcel.get(index).add(truck);
              counter++;
            }

          }

        }else if(selectedTab.equalsIgnoreCase('Tractor')){
          searchResultTractorsExcel = new List<List<Vehicle__c>>();
          for(Vehicle__c truck : database.query(vehicleSOQL)){
            if(counter == 0){
              searchResultTractorsExcel.add(new List<Vehicle__c>{truck});
              counter++;
            }else if(counter == 999){
              searchResultTractorsExcel.get(index).add(truck);
              index++;
              counter = 0;
            }else{
                //system.debug('------------'+  searchResultTractorsExcel);
                //system.debug('--------Counter----'+  counter);
                //system.debug('--------Index----'+  index);
                //system.debug('------- searchResultTractorsExcel.get(' + index + ')----'+  searchResultTractorsExcel.get(index));
              searchResultTractorsExcel.get(index).add(truck);
              counter++;
            }

          }
        }else if(selectedTab.equalsIgnoreCase('Trailer')){
          searchResultTrailersExcel = new List<List<Vehicle__c>>();
          for(Vehicle__c truck : database.query(vehicleSOQL)){
            if(counter == 0){
              searchResultTrailersExcel.add(new List<Vehicle__c>{truck});
              counter++;
            }else if(counter == 999){
              searchResultTrailersExcel.get(index).add(truck);
              index++;
              counter = 0;
            }else{
              searchResultTrailersExcel.get(index).add(truck);
              counter++;
            }

          }
        }
        index=null;
        counter=null;
        vehicleSOQL=null;
      return Page.SearchMasterInventoryPDF;
    }

    public Pagereference resetTruck(){
      searchResultTrucks = new List<Vehicle__c>();
      searchObjTruck = new VehicleSearchSetting__c();
      trucksAvailableForSale =  null;
      trucksSalesInProcess =  null;
      trucksOsInProcess =  null;
      daysAtUTCStartTruck =  null;
      daysAtUTCEndTruck =  null;
      odomSamStartTruck =  null;
      odomSamEndTruck =  null;
      salesPriceStartTruck =  null;
      salesPriceEndTruck =  null;
      modelYearStartTruck =  null;
      modelYearEndTruck =  null;
      return null;
    }

    public Pagereference resetTrailer(){
      searchResultTrailers = new List<Vehicle__c>();
      searchObjTrailer = new VehicleSearchSetting__c();
      trailersAvailableForSale =  null;
      trailersSalesInProcess =  null;
      trailersOsInProcess =  null;
      daysAtUTCStartTrailer =  null;
      daysAtUTCEndTrailer =  null;
      odomSamStartTrailer =  null;
      odomSamEndTrailer =  null;
      salesPriceStartTrailer =  null;
      salesPriceEndTrailer =  null;
      modelYearStartTrailer =  null;
      modelYearEndTrailer =  null;
      return null;
    }

    public Pagereference resetTractor(){
      searchResultTractors = new List<Vehicle__c>();
      searchObjTractor = new VehicleSearchSetting__c();
      tractorsAvailableForSale =  null;
      tractorsSalesInProcess =  null;
      tractorsOsInProcess =  null;
      daysAtUTCStartTractor =  null;
      daysAtUTCEndTractor =  null;
      odomSamStartTractor =  null;
      odomSamEndTractor =  null;
      salesPriceStartTractor =  null;
      salesPriceEndTractor =  null;
      modelYearStartTractor =  null;
      modelYearEndTractor =  null;
      return null;
    }

}