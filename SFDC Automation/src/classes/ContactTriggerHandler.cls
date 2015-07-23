/*************************************************************************************************
Created By:    Sunil Gupta
Date:          August 28, 2014
Description  : Handler class for Contact Trigger
**************************************************************************************************/
public class ContactTriggerHandler {

  // Create Solution Interest record.
  public static void createSolutionInterest(Map<Id, Contact> mapNew) {
    // prepare map for profile names.
    Set<Id> ownerIds = new Set<Id>();
    Map<Id, String> mapProfiles = new Map<Id, String>();
    for(Contact c :mapNew.values()){
      if(String.valueOf(c.OwnerId).startsWith('005')){
        ownerIds.add(c.OwnerId);
      }
    }

    Map<Id, String> mapProfileNames = new Map<Id, String>();
    for(User u :[SELECT Profile.Name FROM User WHERE Id IN :ownerIds]){
      mapProfileNames.put(u.Id, u.Profile.Name);
    }

    Map<String, Profile_Default_Products__c> mapPDP = Profile_Default_Products__c.getAll();


    // Existing Solution Interest record for available contacts.
    Set<Id> existingContacts = new Set<Id>();
    for(Solutions_Interest__c si :[SELECT Id, Lead_Id__c, Product_Line__c
                                                 FROM Solutions_Interest__c
                                                 WHERE Contact_Id__c IN :mapNew.keySet()]){
      if(si.Contact_Id__c != null){
      	existingContacts.add(si.Contact_Id__c);
      }
    }
    System.debug('@@@' + existingContacts);



    // create solution interest record.
    List<Solutions_Interest__c> lstSI = new List<Solutions_Interest__c>();
    for(Contact c :mapNew.values()){
    	if(existingContacts.contains(c.Id) == false){
        	Solutions_Interest__c si = new Solutions_Interest__c();
        	si.Contact_Id__c = c.Id;
        	si.Stage__c = 'Qualified';
        	if(String.valueOf(c.OwnerId).startsWith('005')){ // RA: We can ignore this condition
          		if(mapProfileNames.get(c.OwnerId) != null){
            		if(mapPDP.get(mapProfileNames.get(c.OwnerId)) != null){
              			si.Product_Line__c = mapPDP.get(mapProfileNames.get(c.OwnerId)).Default_Product__c;
            		}
          		}
        	}
        	lstSI.add(si);
      	}

    }
    System.debug('@@@' + lstSI);
    insert lstSI;
  }



}