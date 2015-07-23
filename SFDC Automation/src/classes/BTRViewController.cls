/**=====================================================================
 * Appirio, Inc
 * Name: BTRViewController
 * Created Date: 9-24-2014
 * Created By: Sunil (Appirio)
 =====================================================================*/
public without sharing class BTRViewController {
  // Variables
  public List<BTRWrapper>lstBTRWrapper {get;set;} 
  public String selectedView{get;set;}
  public Boolean isApprovers{get;set;}
  public String currentUserType;
  public Boolean isVSM{get;set;}
   
   
  private Set<Id> currentUserSubOrdinatesRoles;
  //private Map<String, Group> queueMapByName;
  private Set<ID> btrIds;
  
  
  // Controller
  public BTRViewController() {
    currentUserType = UVS_Util.getBTRUserType();
    isApprovers = false;
    isVSM = false;
    System.debug('@@@' + currentUserType);
    
    if(currentUserType == 'FAM' || currentUserType == 'DAM' || currentUserType == 'VP'){
      selectedView = '0';
      isApprovers = true;
    }
    
    if(currentUserType == 'VSM'){ 
      isVSM = true;
    }
    
    //queueMapByName = new Map<String, Group>();
    //for(Group g :[Select Id, Name, DeveloperName from Group Where DeveloperName IN ('UVS_FAM', 'UVS_DAM', 'UVS_VP_AM')]){
    //  queueMapByName.put(g.DeveloperName, g);
    //}
    
    if(String.isBlank(currentUserType) == false){
      fillWrapper();
    }
    
  }
  
  // Fill list of Views
  public List<SelectOption> getItems() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('0', 'My Items'));
    if (currentUserType == 'FAM') {
      options.add(new SelectOption('1', 'All FAMs Items'));
    }
    else if(currentUserType == 'DAM') {
      options.add(new SelectOption('2', 'My Items and All FAMs Items'));
      options.add(new SelectOption('3', 'All DAMs Items'));
    }
    else if(currentUserType == 'VP') {
      options.add(new SelectOption('4', 'My Items and All DAMs Items'));
    }
    return options;
  }
  
  // Fill Wrapper List
  private void fillWrapper(){
    lstBTRWrapper = new List<BTRWrapper>();
    List<BTR__c> lstBTR = queryBTRRecords();
    System.debug('@@@' + lstBTR);
    
    Set<Id> owenerIds = new Set<Id>();
    for(BTR__c btr :lstBTR){
      owenerIds.add(btr.OwnerId);
    }
    
    Set<Id> allRoleIds = new Set<Id>();
        
    Map<Id, Id> mapUsers = new Map<Id, Id>();
    for(User u :[SELECT Id, UserRoleId FROM User WHERE Id = :owenerIds]){
      mapUsers.put(u.Id, u.UserRoleId);
      allRoleIds.add(u.UserRoleId);
    }
    
    
    Map<Id, Id> mapOwernId_FirstParent = new Map<Id, Id>();
    for(UserRole ur :[SELECT Id, ParentRoleId FROM UserRole WHERE Id IN :allRoleIds]){
      mapOwernId_FirstParent.put(ur.Id, ur.ParentRoleId);
      allRoleIds.add(ur.ParentRoleId);
    }
    System.debug('@@@ 1: ' + mapOwernId_FirstParent); 
    
    Map<Id, Id> mapOwernId_SecondParent = new Map<Id, Id>();
    for(UserRole ur :[SELECT Id, ParentRoleId FROM UserRole WHERE Id IN :mapOwernId_FirstParent.values()]){
      mapOwernId_SecondParent.put(ur.Id, ur.ParentRoleId);
      allRoleIds.add(ur.ParentRoleId);
    }
    System.debug('@@@ 2: ' + mapOwernId_SecondParent);
    
    Map<Id, Id> mapOwernId_ThirdParent = new Map<Id, Id>();
    for(UserRole ur :[SELECT Id, ParentRoleId FROM UserRole WHERE Id IN :mapOwernId_SecondParent.values()]){
      mapOwernId_ThirdParent.put(ur.Id, ur.ParentRoleId);
      allRoleIds.add(ur.ParentRoleId);
    }
    
    // obsolute below code written as earlier we were showing the Role name in current approver column
    /*
    Map<Id, String> mapRoleNames = new Map<Id, String>();   
    for(UserRole ur :[SELECT Id, Name FROM UserRole WHERE Id IN :allRoleIds]){
        mapRoleNames.put(ur.Id, ur.Name);
    }
    System.debug('@@@' + mapRoleNames);
    */
    
    
    Map<Id, User> mapRoleId_User = new Map<Id, User>();
    for(User u :[SELECT Id, Name, UserName, UserRoleId FROM User WHERE UserRoleId = :allRoleIds]){
      if(u.UserRoleId != null){
        mapRoleId_User.put(u.UserRoleId, u);
      }
    }
    
    for(BTR__c btr :lstBTR){
      BTRWrapper objWrapper = new BTRWrapper();
      objWrapper.btrObject = btr;
      
      Id firstParent = mapOwernId_FirstParent.get(mapUsers.get(btr.OwnerId));
      System.debug('@@@ 3: ' + firstParent);
      if(firstParent != null && mapRoleId_User.get(firstParent) != null){
            objWrapper.firstApprover = mapRoleId_User.get(firstParent).Name;                
            Id secondParent = mapOwernId_SecondParent.get(firstParent);
            System.debug('@@@ 4: ' + secondParent);
            if(secondParent != null && mapRoleId_User.get(secondParent) != null){
              if(mapRoleId_User.get(secondParent) != null){
                objWrapper.secondApprover = mapRoleId_User.get(secondParent).Name;
              }
              Id thirdParent = mapOwernId_ThirdParent.get(secondParent);
              if(thirdParent != null && mapRoleId_User.get(thirdParent) != null){
                objWrapper.thirdApprover = mapRoleId_User.get(thirdParent).Name;
              }
            }
      }
      lstBTRWrapper.add(objWrapper);
    }
    System.debug('@@@ 5: ' + lstBTRWrapper); 
    
    
    // Set current Approver.
    for(BTRWrapper objWrapper :lstBTRWrapper){
      if(objWrapper.btrObject.Status__c == 'Submitted - With FAM'){
        objWrapper.currentApprover = objWrapper.firstApprover;
      }
      else if(objWrapper.btrObject.Status__c == 'Submitted - With DAM'){
        objWrapper.currentApprover = objWrapper.secondApprover;
      }
      else if(objWrapper.btrObject.Status__c == 'Submitted - With VP AM'){
        objWrapper.currentApprover = objWrapper.thirdApprover;
      }
    }
    System.debug('@@@ 6:' + lstBTRWrapper);
  }
  
  
  // Helper method to get all Role Ids exists under the the current user Hierarchy
  private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
    Set<ID> currentRoleIds = new Set<ID>();
    // get all of the roles underneath the passed roles
    for(UserRole userRole :[SELECT Id FROM UserRole WHERE ParentRoleId IN :roleIds AND ParentRoleID != null]){
      currentRoleIds.add(userRole.Id);
    }
    // go fetch some more rolls!
    if(currentRoleIds.size() > 0){
      currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
    }
    return currentRoleIds;
  }
  
  // Action method when View is changed.
  public void selectView(){
    fillWrapper();
    System.debug('@@@' + lstBTRWrapper);
    System.debug('@@@' + lstBTRWrapper.size());
  }
  
  


  // Helper method to Query BTR Records
  // Hari K (2014-11-04): Added Quote__r.Opportunity.Account.Name to the SOQL query.
  private List<BTR__c> queryBTRRecords() {
    String qry = 'SELECT Id, First_Approver__c,Second_Approver__c, Third_Approver__c, Name, Quote__r.Opportunity.Account.Name, Quote__r.Opportunity.Original_Decision_Maker__c, Status__c, CreatedDate, OwnerId, Quote__c, Quote__r.Name, '+
                 'Quote__r.CreatedDate FROM BTR__c WHERE IsDeleted = false AND Quote__c != null';
        
    qry = qry + ' AND Status__c NOT IN (\'Approved\', \'Rejected\') ';
        
    if(currentUserType == 'ADMIN'){
      // no filter to do
    }
    
    else if(currentUserType == 'VSM'){
      Id currentUserId = UserInfo.getUserId();
      qry = qry + ' AND OwnerId = :currentUserId';
    }
    
    if(currentUserType == 'FAM' || currentUserType == 'DAM' || currentUserType == 'VP'){
      qry = qry + applyFilters();   
    }
    qry = qry + ' ORDER BY CreatedDate DESC';
        
    System.debug('@@@' + qry);
    return Database.query(qry);
    
  }
  
  
    
    // Helper method to apply filters
    private String applyFilters(){
      String filterStr = '';
      Set<ID> currentUserRole = new Set<ID>();
      currentUserRole.add(Userinfo.getUserRoleId());
      currentUserSubOrdinatesRoles = new Set<Id>();
      currentUserSubOrdinatesRoles = getAllSubRoleIds(currentUserRole);
        
      Set<ID> actorIds = new Set<Id>();
      System.debug('@@@' + selectedView);
      //System.debug('@@@' + queueMapByName);
      
      Map<String, List<User>> mapUsers = UVS_Util.getAllUsersOfAProfile();
      
      //if(selectedView == '0'){
      	actorIds.add(UserInfo.getUserId());
      	//System.debug('@@@' + actorids);  
      //}
      
      if(selectedView == '1' && currentUserType == 'FAM'){
        //actorIds.add(queueMapByName.get('UVS_FAM').Id);
        if(mapUsers.get('FAM') != null){
        	for(User u :mapUsers.get('FAM')){
        	  actorIds.add(u.Id);	
        	}
        }
        System.debug('@@@' + actorids);
      }
      
      else if(selectedView == '2' && currentUserType == 'DAM'){
        //actorIds.add(queueMapByName.get('UVS_DAM').Id);
        if(mapUsers.get('FAM') != null){
          for(User u :mapUsers.get('FAM')){
            actorIds.add(u.Id); 
          }
        }
        System.debug('@@@' + actorids);
      }
      
      else if(selectedView == '3' && currentUserType == 'DAM'){
        //actorIds.add(queueMapByName.get('UVS_DAM').Id);
        if(mapUsers.get('DAM') != null){
          for(User u :mapUsers.get('DAM')){
            actorIds.add(u.Id); 
          }
        }
        System.debug('@@@' + actorids);
      }
      
      else if(selectedView == '4' && currentUserType == 'VP'){
        //actorIds.add(queueMapByName.get('UVS_VP_AM').Id);
        if(mapUsers.get('DAM') != null){
          for(User u :mapUsers.get('DAM')){
            actorIds.add(u.Id); 
          }
        }
        System.debug('@@@' + actorids);
      }
      
      btrIds = new Set<ID>();
      for(ProcessInstanceWorkitem pendingProcess : [SELECT ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem 
                                                    WHERE ActorId IN :actorIds AND ProcessInstance.Status = 'Pending']) {
        btrIds.add(pendingProcess.ProcessInstance.TargetObjectId);
      }
      System.debug('@@@' + btrIds);
          
      filterStr = ' AND Id =:btrIds';
      
      //if(selectedView == '0') { // My Items's include where owner role is from one of my sub-ordinate
      //  filterStr = filterStr + ' AND Owner.UserRoleId IN :currentUserSubOrdinatesRoles ';
      //}
  
      //if(selectedView == '0' || selectedView == '2' || selectedView == '4') { // My Items's include where owner role is from one of my sub-ordinate
      //  filterStr = filterStr + ' AND Owner.UserRoleId IN :currentUserSubOrdinatesRoles ';
      //}
      
      //if(selectedView == '1') {
      //  filterStr = filterStr + ' AND Status__c = \'Submitted - With FAM\' ';
      //}
      
      //if(selectedView == '3') {
      //  filterStr = filterStr + ' AND Status__c = \'Submitted - With DAM\' ';
      //}
      System.debug('@@@' + currentUserSubOrdinatesRoles);
      return filterStr;
    }
    
  // Wrapper Class to display result on VF page
  public class BTRWrapper{
    public BTR__c btrObject{get;set;}
    public String currentApprover{get;set;}
    public String firstApprover{get;set;}
    public String secondApprover{get;set;}
    public String thirdApprover{get;set;}
  }
}