/**=============================================================================
 * Created By: Manisha, Sunil (Appirio, Inc)
 * Created Date: [08/21/2014]
 * Description: Controller class for page Vehicle Selection on Lead detail page.

 Date		Modified By				Description
09/16/2014  Manisha Gupta  			Order of vehicle type must be 'Trucks', 'Tractors', 'Trailers', 'Other' (T-319845)
==============================================================================*/
global with sharing class VehicleSelectionController {
  //private Id leadId;
  private String selectedVehicles;
  private Solutions_Interest__c solutionInterest;
  public Lead currentLead{get;set;}
  public Contact currentContact{get;set;}
  private Solutions_Interest__c relatedSI;
  public Map<String, List<VehicleWrapper>> mapVehicleTypeVehicleList{get;set;}
  private Set<String> setAlreadySelectedItems;
  public List<String> sortedVehicleTypeList{get;set;}
  list<Solution_Interest_Detail__c> existingSelections;
  public boolean isError{get;set;}

  // check if page message already exists
  public Boolean isPageMessageFound{
    get{
        return ApexPages.hasMessages();
    }
  }

  // Constructor
  public VehicleSelectionController(ApexPages.StandardController sc){
    Id ownerId;
    String recordId = sc.getId();
     // 09/16/2014 : MG : Order fo vehicle type must be 'Trucks', 'Tractors', 'Trailers', 'Other' (T-319845)
    sortedVehicleTypeList = new List<String>{'Trucks', 'Tractors', 'Trailers', 'Other'};
    isError = false;
    // check the record type (either lead or contact)
    if(recordId.startsWith('00Q')){
        if(!test.isRunningTest()){
        	sc.addFields(new List<String>{'Id', 'Source_Comment__c', 'OwnerId'});
    	}
        currentLead = (Lead)sc.getRecord();
        ownerId = currentLead.ownerId;

    }else if(recordId.startsWith('003')){
      if(!test.isRunningTest()){
      	sc.addFields(new List<String>{'Id', 'Additional_Comments__c', 'OwnerId'});
      }
      currentContact = (Contact)sc.getRecord();
      ownerId = currentContact.ownerId;
    }

    // get product line and based on that get existing solution interest record
    List<User> lstUser = [SELECT Profile.Name FROM USER WHERE Id = :ownerId];
    if(lstUser.size() > 0){
      String profileName = lstUser.get(0).Profile.Name;
      Profile_Default_Products__c defaultProductSetting = Profile_Default_Products__c.getAll().get(profileName);
      if(defaultProductSetting == null){
      	isError = true;
      	Apexpages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'No default product exists for ' + profileName + ' Profile.'));
      	return;
      }
      String productLine = defaultProductSetting.Default_Product__c;
      String query = 'SELECT Id, Lead_Id__c, Product_Line__c, Contact_Id__c';
      query +=  ' FROM Solutions_Interest__c ';
      query +=  ' WHERE ';
      query +=  currentLead != null ? ' Lead_Id__c =\''+currentLead.Id+'\'' : '';
      query +=  currentContact != null ? ' Contact_Id__c =\''+currentContact.Id+'\'' : '' ;
      query +=  ' AND Product_Line__c = :productLine ';

      system.debug('=============' + query);
      List<Solutions_Interest__c> lstSI = database.query(query);

      if(lstSI.size() > 0){
        relatedSI = lstSI.get(0);
      }
      if(relatedSI == null || relatedSI.Id == null){
	      isError = true;
	      Apexpages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'No solution interest record exists.'));
	      return;
	    }
    }
    System.debug('@@@' + relatedSI);
    mapVehicleTypeVehicleList = new Map<String, List<VehicleWrapper>>();

    // get List of all the vehicles from custom setting Vehicle List
    for(Vehicle_List__c vehicle : Vehicle_List__c.getAll().values()){
      if(mapVehicleTypeVehicleList.containsKey(vehicle.Vehicle_Type__c)){
        mapVehicleTypeVehicleList.get(vehicle.Vehicle_Type__c).add(new VehicleWrapper(false, vehicle.Vehicle_Name__c));
      }
      else{
        mapVehicleTypeVehicleList.put(vehicle.Vehicle_Type__c, new List<VehicleWrapper>{new vehicleWrapper(false, vehicle.Vehicle_Name__c)});
      }

    }

    // sort list based on vehicle names.
    for(String s :mapVehicleTypeVehicleList.keySet()){
    	List<VehicleWrapper> objWrapper = mapVehicleTypeVehicleList.get(s);
    	objWrapper.sort();
    }
    if(relatedSI != null){
      fillAlreadySelectedItems();
    }


  }

  // Mehtod to fetch existing solution interest detail records and check the checkboxes for them
  private void fillAlreadySelectedItems(){
    existingSelections = new List<Solution_Interest_Detail__c>();
    setAlreadySelectedItems = new Set<String>();
    for(Solution_Interest_Detail__c detail :[SELECT Vehicle_Type__c, Vehicle_Name__c
                                                 FROM Solution_Interest_Detail__c
                                                 WHERE Solutions_Interest__c = :relatedSI.Id]){

      if(detail.Vehicle_Name__c != null && detail.Vehicle_Type__c != null){
        existingSelections.add(detail);
        setAlreadySelectedItems.add(String.valueOf(detail.Vehicle_Name__c) + String.valueOf(detail.Vehicle_Type__c));
      }
    }

    for(String vType :mapVehicleTypeVehicleList.keyset()){
      for(VehicleWrapper objWrapper :mapVehicleTypeVehicleList.get(vType)){
        String key = objWrapper.vehicleName + vType;
        if(setAlreadySelectedItems.contains(key)){
          objWrapper.isSelected = true;
        }
      }
    }

  }

  // Save Action Method
  public pageReference save(){


      savePoint sp;
      try{
        sp = Database.setSavepoint();
        if(!existingSelections.isEmpty()){
        	delete existingSelections;
        }
        List<Solution_Interest_Detail__c> lstToBeInsert = new List<Solution_Interest_Detail__c>();
        boolean oneItemSelected = false;
        for(String t :mapVehicleTypeVehicleList.keySet()){
          List<VehicleWrapper> lstWrapper = mapVehicleTypeVehicleList.get(t);
          for(VehicleWrapper wrapObj :lstWrapper){
            if(wrapObj.isSelected == true){// && !setAlreadySelectedItems.contains(String.valueOf(wrapObj.vehicleName) + String.valueOf(t))){
                oneItemSelected = true;
                Solution_Interest_Detail__c detailObj = new Solution_Interest_Detail__c();
                detailObj.Vehicle_Type__c = t;
                detailObj.Vehicle_Name__c = wrapObj.vehicleName;
                detailObj.Solutions_Interest__c = relatedSI.Id;
                lstToBeInsert.add(detailObj);
            }/*else if(setAlreadySelectedItems.contains(String.valueOf(wrapObj.vehicleName) + String.valueOf(t))){
            	oneItemSelected = true;
            }*/
          }
        }

        if(!oneItemSelected){
        	Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'At least one item must be selected.'));
        }

        system.debug('@@@' + lstToBeInsert);

        if(lstToBeInsert.size() > 0){
          insert lstToBeInsert;
          Apexpages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Your interest has been updated successully.'));
        }
        fillAlreadySelectedItems();
      }
      catch(exception ex){
        Database.rollback(sp);
        ApexPages.addMessages(ex);
        System.debug('@@@');
      }

    return null;
  }

  // Cancel Action Method
  //public pageReference cancel(){
  //  return null;
 // }


  global class VehicleWrapper implements Comparable{
    public boolean isSelected{get;set;}
    public String vehicleName{get;set;}

    public vehicleWrapper(boolean isSelected, String vehicleName){
      this.isSelected = isSelected;
      this.vehicleName = vehicleName;
    }

    global Integer compareTo(Object other) {
     String otherName = other != null ? ((VehicleWrapper)other).vehicleName : '';
     if(otherName == '') {
     	return -1;
     }
     try {
       Integer i = Integer.valueOf(this.vehicleName.substring(0, this.vehicleName.indexOf('-')).trim());
       Integer j = Integer.valueOf(otherName.substring(0, otherName.indexOf('-')).trim());
       return i - j;
     }
     catch (Exception e) {
       return 1;
     }
    }
  }



}