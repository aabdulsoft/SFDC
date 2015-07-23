/*************************************************************************************************
Created By:    Sunil Gupta
Date:          August 25, 2014
Description  : Handler class for Lead Trigger
**************************************************************************************************/
public class LeadTriggerHandler {
  private static final String UVS_QUEUE = 'UVS Lead Assignment';
  // Create Solution Interest record.
  public static void createSolutionInterest(Map<Id, Lead> mapNew) { 
    
    // prepare map for profile names.
    Set<Id> ownerIds = new Set<Id>();
    Map<Id, String> mapProfiles = new Map<Id, String>();
    for(Lead l :mapNew.values()){
        if(String.valueOf(l.OwnerId).startsWith('005')){
        ownerIds.add(l.OwnerId);
        }
    }

    Map<Id, String> mapProfileNames = new Map<Id, String>();
    for(User u :[SELECT Profile.Name FROM User WHERE Id IN :ownerIds]){
      mapProfileNames.put(u.Id, u.Profile.Name);
    }

    Map<String, Profile_Default_Products__c> mapPDP = Profile_Default_Products__c.getAll();



    // create solution interest record.
    List<Solutions_Interest__c> lstSI = new List<Solutions_Interest__c>();
    
    for(Lead l :mapNew.values()){
    	//AAK 04/10/2015 Start QC 891 - excluded lead coming from eloqua
	    Solutions_Interest__c si = new Solutions_Interest__c();
		if(!l.Is_UVS__c){
		//AAK 04/10/2015 End
	        si.Lead_Id__c = l.Id;
	        si.Latest_Source__c = l.LeadSource;
	        si.Original_Source__c = l.LeadSource;
	        si.Stage__c = 'Qualified';
	        //AAK 04/10/2015 Start QC 891 - defaulting to Lease 
	        si.Product_Line__c = 'Lease';
	        //AAK 04/10/2015 End
	        if(String.valueOf(l.OwnerId).startsWith('005')){
	          
	            if(mapProfileNames.get(l.OwnerId) != null){
	                if(mapPDP.get(mapProfileNames.get(l.OwnerId)) != null){
	                  si.Product_Line__c = mapPDP.get(mapProfileNames.get(l.OwnerId)).Default_Product__c;
	                }
	            }
	        }
		}
        lstSI.add(si);
    }
    
   
    
    System.debug('@@@' + lstSI);
    if(!lstSI.isEmpty()){
      insert lstSI;
    }
    
    
  }

  // RA: Please provide Comenting in below method for each block

  // Create Solution Interest record When Lead Owner Profile is changed.
  public static void createSolutionInterestOnProfileChanged(Map<Id, Lead> mapOld, List<Lead> lstNew, Map<Id, Lead> mapNew) {
    Set<Id> setOwnerIds = new Set<Id>();
    for(Lead l :lstNew){
        if(mapOld.get(l.Id).OwnerId != l.OwnerId){
            setOwnerIds.add(l.OwnerId);
        }
    }
    System.debug('@@@' + setOwnerIds);

    Map<Id, String> mapProfileNames = new Map<Id, String>();
    for(User u :[SELECT Profile.Name FROM User WHERE Id IN :setOwnerIds]){
      mapProfileNames.put(u.Id, u.Profile.Name);
    }

    Map<String, Profile_Default_Products__c> mapPDP = Profile_Default_Products__c.getAll();


    // prepare map for  Lead Id vs Product Line
    Map<Id, String> mapProductLine = new Map<Id, String>();
  
    for(Lead l :lstNew){
      if(mapOld.get(l.Id).OwnerId != l.OwnerId){
        String newProductLine;
        if(String.valueOf(l.OwnerId).startsWith('005')){
          if(mapProfileNames.get(l.OwnerId) != null){
            if(mapPDP.get(mapProfileNames.get(l.OwnerId)) != null){
              newProductLine = mapPDP.get(mapProfileNames.get(l.OwnerId)).Default_Product__c;
            }
          }
        }
         //AAK 04/10/2015 Start QC 891 - defaulting to Lease
        //if(newProductLine == null){
        //	mapProductLine.put(l.Id, 'Lease');
        //} else { //AAK 04/10/2015 End
        	mapProductLine.put(l.Id, newProductLine);
       // }
      }
    }
    System.debug('@@@' + mapProductLine);
	System.debug('@@@' + mapProductLine.keySet());
    Map<Id, List<Solutions_Interest__c>> mapExistingSI = new Map<Id, List<Solutions_Interest__c>>();
    for(Solutions_Interest__c si : [SELECT Id, Stage__c, Lead_Id__c, Product_Line__c
                                                 FROM Solutions_Interest__c
                                                 WHERE Lead_Id__c IN :mapProductLine.KeySet()]){
      if(si.Lead_Id__c != null){
      	  system.debug('enter');
          if(mapExistingSI.containsKey(si.Lead_Id__c) == false){
            mapExistingSI.put(si.Lead_Id__c, new List<Solutions_Interest__c>());
          }
          mapExistingSI.get(si.Lead_Id__c).add(si);
      }
    }
    System.debug('@@@' + mapExistingSI);


    Set<Id> eligibleLeadIds = new Set<Id>();
    for(Id leadId :mapProductLine.keySet()){
        List<Solutions_Interest__c> lst = mapExistingSI.get(leadId);
        String newProductLine = mapProductLine.get(leadId);
        if(newProductLine != null){
            Boolean isMatched = false;
         if(lst!=null && lst.size()>0) {
              for(Solutions_Interest__c si :lst){
                if(si.Product_Line__c == newProductLine){
                  isMatched = true;
                }
              }
          }
          if(isMatched == false){
            eligibleLeadIds.add(leadId);
          }
        }
    }
    System.debug('@@@' + eligibleLeadIds);


    List<Solutions_Interest__c> lstSI = new List<Solutions_Interest__c>();
    for(Id leadId :eligibleLeadIds){ 
        Solutions_Interest__c si = new Solutions_Interest__c();
          si.Lead_Id__c = leadId;
          si.Latest_Source__c = mapNew.get(leadId).LeadSource;
          si.Original_Source__c = mapNew.get(leadId).LeadSource;
          if(mapProductLine.get(leadId) != null){
            si.Product_Line__c = mapProductLine.get(leadId);
          }
          lstSI.add(si);
        }

    System.debug('@@@' + lstSI);
   
    if(!lstSI.isEmpty()){
      insert lstSI;
      createSolutionInterestDetail(lstSI);
    }
   
  }
  
  
    // Sunil: Appirio 10/11/2014: Assign UVS Lead T-323926
    // If Lead is from Employee then fetch Postal Code from Postal Code 
    // and assign it to the user of that postal code object
  public static void assignEmployeeLeads(List<Lead> newList){
    System.debug('@@@' + newList);  
    Set<String> postalCodeSet = new Set<String>();
    for(Lead lead :newList){
        if(lead.OwnerId != null && (lead.LeadSource == 'Employee Referral')){
         if(lead.Employee_Zipcode__c !=null)
          {
           System.debug('@@@Zip code : ' + lead.Employee_Zipcode__c);
           postalCodeSet.add(lead.Employee_Zipcode__c);           
          }
        }
      }        
       System.debug('@@@' + postalCodeSet);   
      map<String,Postal_Code__c> postalCodeSelfMap = new map<String,Postal_Code__c>();
      for(Postal_Code__c postCode : [SELECT Postal_Code__c,UVS_Assignee__c FROM Postal_Code__c WHERE Postal_Code__c IN : postalCodeSet]){
        if(postCode.UVS_Assignee__c !=null){
            if(postCode.Postal_Code__c != null){
            postalCodeSelfMap.put(postCode.Postal_Code__c ,postCode);
            }            
        }
      }
      System.debug('@@@' + postalCodeSelfMap);
     
      List<Lead> leadsToUpdate = new List<Lead>();
      
      for(lead lead :newList){   
        if(postalCodeSelfMap.containskey(lead.Employee_Zipcode__c))     
         {
          lead.OwnerId = postalCodeSelfMap.get(lead.Employee_Zipcode__c).UVS_Assignee__c;
        //  setNewLeadOwners.add(lead.OwnerId);
          lead.Send_Email_to_VSR_VSM__c = true; // to send the notification email.        
           }}
         
        }
    
    
  
    // Hari Krishnan (12/29/2014): This method populates the UTC_Assigned__c field.
    //Update By Virendra to populate UTC Assigned Field For I-148716 on 18 Feb 2015
    public static void updateUTC(List<Lead> listLeads,Map<Id, Lead> mapOld,boolean isInsert) {
        String utcId = null;
        map<id,id> leadOweners = new map<id,id>();
        map<Id,User> ownersUTCs = new map<Id,User>();
     
        for(lead ld:listLeads){
            leadOweners.put(ld.id,ld.ownerId);
        }
        
        map<id,String> ownersRelatedBranchCode = new map<id,String>();
        for(User u:[SELECT id,UTC__c,Profile.Name, Profile.Id, ProfileId  FROM USER WHERE Id in :leadOweners.values()] ){
            ownersUTCs.put(u.id,u);
            ownersRelatedBranchCode.put(u.id,u.UTC__c);
        }
        
        Set<String> uvsProfiles = new Set<String>();
        
        if(UVS_Profiles__c.getOrgDefaults() != null && UVS_Profiles__c.getOrgDefaults().Profile_Name__c != null)
        {
            for(String str : UVS_Profiles__c.getOrgDefaults().Profile_Name__c.split(';')){
              uvsProfiles.add(str);
            }
        }
        Map<String,id> mapRB = new Map<String,id>();
        for(Ryder_Branch__c rb:[SELECT Id,Branch_Code__c FROM Ryder_Branch__c WHERE Branch_Code__c in : ownersRelatedBranchCode.values()]){
            mapRB.put(rb.Branch_Code__c,rb.Id);
        }
        
        // Update or Assigned UTC Assigned Field only if Owner belongs to UVS Profiles 
        for(lead ld:listLeads){
            if(ownersUTCs.containsKey(ld.ownerId)){ 
               String leadOwenerProfile = ownersUTCs.get(ld.ownerId).Profile.Name;
               if((uvsProfiles.contains(leadOwenerProfile) &&  ownersRelatedBranchCode.containsKey(ld.ownerId))
                  &&(isInsert || (!isInsert && ld.ownerId != mapOld.get(ld.id).ownerId))){
                 String  ownerUTC = ownersRelatedBranchCode.get(ld.ownerId);
                 if(mapRB.containsKey(ownerUTC)){
                   ld.UTC_Assigned__c = mapRB.get(ownerUTC);
                 }
               }else {
                   ld.UTC_Assigned__c = null;
               }
           }
        }
        
    }
    
  	//AAK 04/09/2015 QC 891 Ryder.com Lead to Salesforce (Web to Lead Part 1)   
	public static void createSolutionInterestDetail(List<Solutions_Interest__c> paramlstSI) { 
	
		//Preparing Map for the LeadIds and SolutionInterests. It will be used to pull SI for a lead
		Map<Id, Solutions_Interest__c> mapleadIds = new Map<Id, Solutions_Interest__c>();
	    for(Solutions_Interest__c SI : paramlstSI){
			mapleadIds.put(SI.Lead_Id__c, SI);
	    }
	    system.debug('LeadTriggerHandler --> mapleadIds ' + mapleadIds);	    
	    
	    //Preparing Map for VehicleListType
		Map<Integer, Vehicle_List__c> mapVehicleTypeVehicleList = new Map<Integer, Vehicle_List__c>();
	    for(Vehicle_List__c vehicle : Vehicle_List__c.getAll().values()){
	    	//if (integer.valueOf(vehicle.Vehicle_Name__c.substring(0,3).trim()) < 100)
	        //	mapVehicleTypeVehicleList.put(vehicle.Vehicle_Name__c.substring(0,2),vehicle);
	        //else
	        	mapVehicleTypeVehicleList.put(integer.valueOf(vehicle.Vehicle_Name__c.substring(0,3).trim()),vehicle);	        
	    }
		system.debug('LeadTriggerHandler --> mapVehicleTypeVehicleList ' + mapVehicleTypeVehicleList);	    


		List<String> lstLeadOwnerIds = new List<String>();
	    for(Lead l : [SELECT id, OwnerId  FROM Lead WHERE Id in :mapleadIds.KeySet()]){
			lstLeadOwnerIds.add(l.OwnerId);
	    }
	    system.debug('LeadTriggerHandler --> lstLeadOwnerIds ' + lstLeadOwnerIds);	    

		//To set the profile for a leadowner. The profile will be used to identify UVS related user
		map<id,User> mapleadownersProfile = new map<id,User>();
        for(User u:[SELECT id,UTC__c,Profile.Name, Profile.Id, ProfileId  FROM USER WHERE Id in :lstLeadOwnerIds] ){
            mapleadownersProfile.put(u.id,u);
        }
		system.debug('LeadTriggerHandler --> mapleadownersProfile ' + mapleadownersProfile);		

		//To get the profile exists in the system stored in the Custom Settings for UVS. It will be used to match with the user profile
        Set<String> uvsProfiles = new Set<String>();
        if(UVS_Profiles__c.getOrgDefaults() != null && UVS_Profiles__c.getOrgDefaults().Profile_Name__c != null){
            for(String str : UVS_Profiles__c.getOrgDefaults().Profile_Name__c.split(';')){
              uvsProfiles.add(str);
            }
        }
		system.debug('LeadTriggerHandler --> uvsProfiles ' + uvsProfiles);
		
/*		//Map the information of the lead per unit
		Map<String, Lead> mapLeadUnit = new Map<String, Lead>();
		for(Lead l : [SELECT Id, Is_UVS__c, Unit__c, OwnerId FROM Lead WHERE Id IN :mapleadIds.KeySet()]){
			//system.debug('LeadTriggerHandler --> uvsProfiles contains' + uvsProfiles.contains(mapleadownersProfile.get(l.ownerId).Profile.Name));
			if(mapleadownersProfile.get(l.ownerId).Profile.Name != null)
			{
				if((l.Is_UVS__c == true) && (l.Unit__c != null) && (uvsProfiles.contains(mapleadownersProfile.get(l.ownerId).Profile.Name))){
					mapLeadUnit.put(l.Unit__c, l);
				}
			}
		}
		system.debug('LeadTriggerHandler --> mapLeadUnit ' + mapLeadUnit);
*/

		//Map the information of the lead per unit
		Set<String> setUnits = new Set<String>();
		for(Lead l : [SELECT Id, Is_UVS__c, Unit__c, OwnerId FROM Lead WHERE Id IN :mapleadIds.KeySet()]){
			if(l.Unit__c != null && !setUnits.contains(l.Unit__c)){
				setUnits.add(l.Unit__c);
			}
		}
		system.debug('LeadTriggerHandler --> setUnits ' + setUnits);
		
		//Map the vehicle informatio per unit, the SAM Class info will used to generated SI Detail
		Map<String,Vehicle__c> mapVehList = new Map<String,Vehicle__c>();
		for (Vehicle__c Veh :[SELECT Id, unit__c, SAM_CLASS__c FROM Vehicle__c WHERE Unit__c IN :setUnits]){
			mapVehList.put(Veh.unit__c, Veh);
		}
		system.debug('mapVehList --> mapVehList ' + mapVehList);		
		
		List<Solution_Interest_Detail__c> lstSIDetToBeInsert = new List<Solution_Interest_Detail__c>();
		for(Lead l : [SELECT Id, Is_UVS__c, Unit__c, OwnerId FROM Lead WHERE Id IN :mapleadIds.KeySet() And Is_UVS__c = true AND unit__c != null]){
			Solutions_Interest__c SI =  mapleadIds.get(l.Id);
			integer samClass;
			if(mapVehList.get(l.unit__c).SAM_CLASS__c.isNumeric())
				samClass = integer.valueOf(mapVehList.get(l.unit__c).SAM_CLASS__c);
			else
				samClass = integer.valueOf(mapVehList.get(l.unit__c).SAM_CLASS__c.substring(0,3).trim());			
			system.debug('samClass : ' + samClass);
			Vehicle_List__c vehList = mapVehicleTypeVehicleList.get(samClass);
	        
	        Solution_Interest_Detail__c detailObj = new Solution_Interest_Detail__c();
	        detailObj.Vehicle_Type__c = vehList.Vehicle_Type__c;
	        detailObj.Vehicle_Name__c = vehList.Vehicle_Name__c;
	        detailObj.Solutions_Interest__c = SI.Id;
	        lstSIDetToBeInsert.add(detailObj);		
		}
		system.debug('LeadTriggerHandler --> lstSIDetToBeInsert ' + lstSIDetToBeInsert);		
		
		if(lstSIDetToBeInsert.size() > 0)
			insert lstSIDetToBeInsert;

	}
    
}