/********************************************************************************************************************************
Name : UVS_Util
Created By :
Date :
Description :

********************************************************************************************************************************/
public class UVS_Util {

  public static Id UVSRecordType_Opp{
	  get{
	    if(UVSRecordType_Opp == null){
	        UVSRecordType_Opp = getRecordType('Opportunity', 'UVS Opportunity');
	    }
	    return UVSRecordType_Opp;
	  }
  }

  //=============================================================//
  // Get the ID for a Record Type, given its Name. Note
  // that this is NOT the Developer Name but rather the Name.
  //Retrive RecordType Id for Specified sObject and RecordTypeName
  //=============================================================//
  public static Id getRecordType(String sObjectName, String recordTypeName) {
    Map<String,Map<String,RecordTypeInfo>> mpRecordType = new Map<String,Map<String,RecordTypeInfo>>();
    /** Update RecordType map**/
    if(!mpRecordType.containsKey(sObjectName)) {
      Schema.sObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectName);
      mpRecordType.put(sObjectName,sObjectType.getDescribe().getRecordTypeInfosByName());
    }
    //Get recordType based on name
    Map<String, RecordTypeInfo> allRecordTypes = mpRecordType.get(sObjectName);
    if(allRecordTypes != null && allRecordTypes.containsKey(recordTypeName)) {
      return allRecordTypes.get(recordTypeName).getRecordTypeId();
    }
    return null;
  }


	public static Boolean isUVSProfile{
    get{
	    String profileName = [SELECT Profile.Name FROM USER WHERE Id = :UserInfo.getUserId()].get(0).Profile.Name;

	    for(String str :UVS_Profiles__c.getOrgDefaults().Profile_Name__c.split(';')){
		    if(str == profileName){
		        return true;
		    }
      }
      return false;
    }
	}
	
	public static Boolean isUVSProfile(Id userId){
    
      String profileName = [SELECT Profile.Name FROM USER WHERE Id = :userId].get(0).Profile.Name;
      
      for(String str :UVS_Profiles__c.getOrgDefaults().Profile_Name__c.split(';')){
        if(str == profileName){
          return true;
        }
      }
      return false;
    
  }

    public static Map<String, List<User>> getAllUsersOfAProfile(){
        Set<String> profileNames = new Set<String>{'FAM', 'DAM', 'VP Asset Management'};

        Map<String, List<User>> mapUsers = new Map<String, List<User>>();

        for(User u :[SELECT Id, Profile.Name  FROM User Where Profile.Name IN :profileNames]){
          if(mapUsers.containsKey(u.Profile.Name) == false){
            mapUsers.put(u.Profile.Name, new List<User>());
          }
          mapUsers.get(u.Profile.Name).add(u);
        }
        return mapUsers;
    }



    public static String getBTRUserType(){
        String currentUserType;
    User u = [SELECT Profile.Name FROM User Where Id = :UserInfo.getUserId()].get(0);
    if(u.Profile.Name == 'System Administrator'){
      currentUserType = 'ADMIN';
    }
    else if(u.Profile.Name == 'VSM_VSR'){
      currentUserType =  'VSM';
    }
    else if (u.Profile.Name == 'FAM'){
        currentUserType =  'FAM';
    }
    else if (u.Profile.Name == 'DAM'){
      currentUserType =  'DAM';
    }
    else if (u.Profile.Name == 'VP Asset Management'){
      currentUserType =  'VP';
    }

    /*
    List<GroupMember> groupMembers = [SELECT Group.DeveloperName FROM GroupMember
                                          WHERE UserOrGroupId = :Userinfo.getUserId()];

    if(!groupMembers.isEmpty()) {
      String grpName = groupMembers.get(0).Group.DeveloperName;
      if(grpName == 'UVS_VP_AM'){
        currentUserType = 'VP';
      }
      else if(grpName == 'UVS_DAM'){
        currentUserType = 'DAM';
      }
      else if(grpName == 'UVS_FAM'){
        currentUserType =  'FAM';
      }
    }
    */
    return currentUserType;
  }

}