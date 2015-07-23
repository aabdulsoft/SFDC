/**=====================================================================
 * Appirio, Inc
 * Created Date: 9-24-2012
 * Created By: Sunil (Appirio)
 =====================================================================*/
public without sharing class BTRDetailController {
  public BTR__c currentBTR {get;set;}
  public String selectedView{get;set;}
  public String comments{get;set;}
  public String isSF1{get;set;}
  public List<QLIWrapper> lstWrapper{get;set;} 
  public UAT_Total uatTotal{get;set;}
  public QuoteLineItem totalOfAllItems{get;set;}
  public Vehicle__c vehicleTemp{get;set;}

  public Boolean getIsPageMesssage() {
    return ApexPages.hasMessages();
  }
  
  //Determine if this is SF1 app
public static Boolean isSalesForce1(){
    if(String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
        String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
        ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
        (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') )
    ){
        return true;
    }else{
        return false;
    }
}
  
  public String currentUserType;
  
  private List<ProcessInstance> objProcessInstance {get; set;}
  private List<ProcessInstanceHistory> stepOrWorkItem {get; set;}
  private Boolean hasProcess {get; set;}
  private Boolean hasStep {get; set;}
  private Boolean hasMyStep {get; set;}
  private Boolean isSysAdmin;
  public Boolean isApprovers{get;set;}
  
  
  public BTRDetailController(ApexPages.StandardController sc) {
    currentUserType = UVS_Util.getBTRUserType();
    uatTotal = new UAT_Total();
    vehicleTemp = new Vehicle__c();
    totalOfAllItems = new QuoteLineItem();
    
    if (isSalesForce1())
        isSF1 = 'In SalesForce 1';
    else
        isSF1 = 'In Desktop';
    
    if(String.isBlank(ApexPages.currentPage().getParameters().get('Id')) == false){
                 
        currentBTR = [SELECT Id,First_Approver__c, Second_Approver__c, Third_Approver__c, Quote__r.Opportunity.Account.Name, Name, Requester_Comments__c, Status__c,Is_Conditional_Approval__c, CreatedById, CreatedDate, OwnerId, Quote__c, Quote__r.Name, 
                      Quote__r.CreatedById, Quote__r.CreatedDate,Approver_Comments__c FROM BTR__c 
                      WHERE Id = :ApexPages.currentPage().getParameters().get('Id')];
        comments = currentBTR.Approver_Comments__c;
        
    }
    
    List<BTR__c> lstOtherBTRs = [SELECT Id, Name FROM BTR__c WHERE Quote__c = :currentBTR.Quote__c AND Status__c = 'Approved'];
    
    if(lstOtherBTRs.size() > 0){
      if(currentBTR.Id != lstOtherBTRs.get(0).Id){
        Apexpages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'The BTR record cannot be edited as <a target="_blank" href=/' + lstOtherBTRs.get(0).Id + '>' + lstOtherBTRs.get(0).Name +'</a> for this quote has been already approved.'));
      }
    }
        
    
    if(currentUserType == 'FAM' || currentUserType == 'DAM' || currentUserType == 'VP' || currentUserType == 'ADMIN'){
      isApprovers = true;
    }
    
    if(currentUserType == 'ADMIN'){ 
      isSysAdmin = true;
    }
    
    if(isApprovers == true){
      loadApprovalStep();
      
     
    }
    fillWrapper();
  }
    
  
  private Boolean validateCurrentUser(String actorQueue) {
    if(isSysAdmin == true){
        return true;
    }
    
    if(currentBTR.Status__c == 'Submitted - With FAM'){
      if(currentUserType == 'FAM' || currentUserType == 'DAM' || currentUserType == 'VP'){
        return true;
      }
    }
    
    if(currentBTR.Status__c == 'Submitted - With DAM'){
      if(currentUserType == 'DAM' || currentUserType == 'VP'){
        return true;
      }
    }
    
    if(currentBTR.Status__c == 'Submitted - With VP AM'){
      if(currentUserType == 'VP'){
        return true;
      }
    }
    
    if(currentBTR.Status__c == 'Approved' || currentBTR.Status__c == 'Rejected'){
      return true;
    }
    
    return false;
    
    /*


    Map<String, List<User>> mapUsers = UVS_Util.getAllUsersOfAProfile();
      
    
    Map<String, Integer> mapAllowedProfiles = new Map<String, Integer>();
    mapAllowedProfiles.put('UVS_FAM', 1);
    mapAllowedProfiles.put('UVS_DAM', 2);
    mapAllowedProfiles.put('UVS_VP_AM', 3);
    
    System.debug('@@@' + actorQueue);
    List<Group> lstGM = [SELECT Id, Name, DeveloperName from Group Where Id = :actorQueue];
    
    System.debug('@@@' + lstGM);
    if(lstGM.size() < 1){
        return false;
    }
    
    actorQueue = lstGM.get(0).DeveloperName;
        
    String currentQueue = currentUserQueueName();
    
    if(mapAllowedProfiles.get(currentQueue) != null){
      Integer scale = mapAllowedProfiles.get(currentQueue);
      
      if(scale >= mapAllowedProfiles.get(actorQueue)){
        return true;
      }  
    }
    return false;
    */
    
  }
  
  
  
  
  
  // Helper method to laod current Approval step
  private void loadApprovalStep(){
    objProcessInstance = [SELECT Id, TargetObjectId, isDeleted, Status, (SELECT Id, ProcessInstanceId, ActorId, Actor.Name, StepStatus, Comments 
               FROM StepsAndWorkItems WHERE StepStatus = 'Pending'  AND isDeleted = false ORDER BY Createddate Desc Limit 1)
               FROM ProcessInstance
               WHERE isDeleted = false AND TargetObjectId = :currentBTR.Id 
               AND Status = 'Pending' Limit 1];
               
    System.debug('@@@' + objProcessInstance);
    hasProcess = ! (objProcessInstance.isEmpty());
    System.debug('@@@' + hasProcess);
    if(hasProcess == false){
        // to do throw exception
        Apexpages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'There is no approval process is pending for this Quote.'));
    }
    
    hasStep = false;
    hasMyStep = false;
    if (hasProcess) {
      stepOrWorkItem = objProcessInstance[0].StepsAndWorkitems;
      
      if(validateCurrentUser(stepOrWorkItem[0].ActorId) == false){
        System.debug('@@@');
        Apexpages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Insufficient Priviledges.'));
      }
      System.debug('@@@');
      System.debug('@@@' + stepOrWorkItem);
      
      if(stepOrWorkItem.isEmpty() == true){
        Apexpages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'There is no approval step is pending for this Quote.'));
      }
      
      hasStep = ! (stepOrWorkItem.isEmpty()); 
      // if that step is for this user.
      hasMyStep = stepOrWorkItem[0].ActorId == UserInfo.getUserId(); 
    }
    System.debug('@@@' + hasMyStep);
    System.debug('@@@' + stepOrWorkItem);
    
  }
  
  private void fillWrapper(){
    
    Set<String> setVehicles = new Set<String>();
    lstWrapper = new List<QLIWrapper>();
    for(QuoteLineItem qli:[Select ServiceDate, NVI__c, NVI_Percent__c, Quantity, ListPrice, Description, Vosa__c, Make_Model__c, Branch_Name__c, Eng_Mdl__c, Vehicle__r.SAM_Odom__c, UnitPrice, Take_Price2__c, SAM_Class__c, 
                            Model_Year__c, Gain_Loss__c, Days_held__c, Book_Value__c, Approved_to_take__c, Approved_Price__c, BankOfAmerica__c, AS_IS_Vehicle__c, Take_Price_percent__c,
                            SpecialPrice__c, Display_Code__c, NonCompliantCAUnits__c, Overstock__c, Meq_sale_prc_am__c, Vehicle__c, Vehicle__r.Name, Vehicle__r.Sold_Flag__c From QuoteLineItem
                           WHERE QuoteId = :currentBTR.Quote__c]) {
      
      QLIWrapper objWrapper = new QLIWrapper(qli,false);
      if(qli.Vehicle__r.Name != null){
        setVehicles.add(qli.Vehicle__r.Name);
      }
      lstWrapper.add(objWrapper); 
      
      
      if(qli.Vehicle__r.Name != null){
        setVehicles.add(qli.Vehicle__r.Name);
      }
     
     
      if(qli.NVI_Percent__c != null){
        uatTotal.total_NVI += qli.NVI__c;
      }
      if(qli.Book_Value__c != null){
        uatTotal.total_BookValue += qli.Book_Value__c;
      }
      if(qli.UnitPrice != null){
        uatTotal.total_SalesPrice += qli.UnitPrice;
      }
      
      if(qli.Take_Price2__c != null){
        uatTotal.total_TakePrice += qli.Take_Price2__c;
      }
      
      
      if(qli.Gain_Loss__c != null){
        uatTotal.total_GainLoss += qli.Gain_Loss__c;
      }
      
      if(qli.Approved_Price__c != null){
        uatTotal.total_ApprovedPrice += qli.Approved_Price__c;
      }
    }
    
    QuoteLineItem lastRowDummyItem = new QuoteLineItem();
    lstWrapper.add(new QLIWrapper(lastRowDummyItem,true)); 
    
    vehicleTemp.NBV__c = uatTotal.total_BookValue;
    vehicleTemp.Ask_Price__c = uatTotal.total_SalesPrice;
    totalOfAllItems.Take_Price2__c =  uatTotal.total_TakePrice;
    totalOfAllItems.Customer_Offer_Price__c = uatTotal.total_GainLoss;
    totalOfAllItems.Approved_Price__c = uatTotal.total_ApprovedPrice;
    
    Decimal d= 0.0;
    
    if(uatTotal.total_NVI != 0){
      d = (uatTotal.total_SalesPrice/uatTotal.total_NVI)*100;
      uatTotal.total_NVIPer = d.setScale(2);
    }
    
    if(uatTotal.total_TakePrice != 0){
      d = (uatTotal.total_SalesPrice/uatTotal.total_TakePrice)*100;
      uatTotal.total_TakePricePer = d.setScale(2);
    }
    
    if(uatTotal.total_TakePrice != 0){
      d = (uatTotal.total_ApprovedPrice/uatTotal.total_TakePrice)*100;
      uatTotal.total_ApprovedPerofTake = d.setScale(2);
    }
    
    
    
    // Update show Previous BTR Boolean field
    Set<String> setFoundHistory = new Set<String>();
    for(BTR_History__c history :[SELECT Id, Vehicle_Number__c FROM BTR_History__c WHERE Vehicle_Number__c IN :setVehicles]){
      setFoundHistory.add(history.Vehicle_Number__c);
    }
    for(QLIWrapper obj :lstWrapper) {
      if(setFoundHistory.contains(obj.qliWrap.Vehicle__r.Name) == true){
        obj.showPreBTR = true;
      }
      else{
        obj.showPreBTR = false;
      }
      System.debug('@@@' + obj.showPreBTR);
   }
  }
  
  // Action method called upon Approve Button.
  public PageReference approve(){
    // Update Approved Price
    List<QuoteLineItem> lstQuoteItems = new List<QuoteLineItem>();
    
    Double approvedAmount = 0.0;
    
    for(QLIWrapper obj :lstWrapper){
      
       if(obj.qliWrap.id != null){
          lstQuoteItems.add(obj.qliWrap);
          if(obj.qliWrap.Approved_Price__c == null || obj.qliWrap.Approved_Price__c <= 0)
          {
          	Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please Enter Valid Approved Price (greater than 0)!'));
          	return null;
          }
          if(obj.qliWrap.Approved_Price__c != null){
            approvedAmount += obj.qliWrap.Approved_Price__c;
          }
       }
    }
    update lstQuoteItems;
    
   //Update Total Approved Amount 
    currentBTR.Approved_Amount__c =  approvedAmount;
    
    //Update Apporer Comment
    currentBTR.Approver_Comments__c = comments;
    update currentBTR;   
     
    
    // Approve Record.
    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
    req.setNextApproverIds(null);
    req.setWorkitemId(stepOrWorkItem.get(0).Id);
    req.setComments(comments);
    req.setAction('Approve');
    Approval.ProcessResult result = Approval.process(req);
    
    
    // Below logic is made for the functionality to provide the multi step approval if the current user is eligible for that.
    System.debug('@@@' + currentBTR.Status__c);
    if(currentUserType == 'VP'){
      if(currentBTR.Status__c == 'Submitted - With FAM' ){
          approveAStep();
          approveAStep();
      }
      if(currentBTR.Status__c == 'Submitted - With DAM' ){
        approveAStep();
      }
    }
    
    if(currentUserType == 'DAM'){
      if(currentBTR.Status__c == 'Submitted - With FAM' ){
        approveAStep();
      }
    }
    
    
    PageReference pg = new PageReference('/apex/BTRView');
    pg.setRedirect(true);
    return pg;
  }
  
  // Helper method to Approve Record.
  private void approveAStep(){
    objProcessInstance = [SELECT Id, (SELECT Id, ProcessInstanceId, ActorId, Actor.Name  
               FROM StepsAndWorkItems WHERE StepStatus = 'Pending'  ORDER BY Createddate Desc Limit 1)
               FROM ProcessInstance WHERE TargetObjectId = :currentBTR.Id 
               AND Status = 'Pending' Limit 1];
    
    
    if(objProcessInstance.isEmpty() == true){
        return;
    }
    
    stepOrWorkItem = objProcessInstance[0].StepsAndWorkitems;
      
    if(stepOrWorkItem.isEmpty() == true){
        return;
    }
      
    System.debug('@@@' + stepOrWorkItem);
    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
    req.setNextApproverIds(null);
    req.setWorkitemId(stepOrWorkItem.get(0).Id);
    req.setComments(comments);
    req.setAction('Approve');
    Approval.ProcessResult result = Approval.process(req);
    System.debug('@@@');
  }
  
  
  

  // Action method called upon Reject Button.
  public PageReference reject(){
    
     //Update Comment By Approver in case on Rejection 
    currentBTR.Approver_Comments__c = comments;
    update currentBTR;   
    
    
    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
    req.setNextApproverIds(null);  // No further approvals for this step needed. // To Do
    req.setWorkitemId(stepOrWorkItem.get(0).Id);
    req.setComments(comments);
    req.setAction('Reject');
    Approval.ProcessResult result = Approval.process(req); 
    
    PageReference pg = new PageReference('/apex/BTRView');
    pg.setRedirect(true);
    return pg;
  }
  
  // Action method called upon Reject Button.
  public PageReference cancel(){
    return new PageReference('/apex/BTRView');
  }
  
  
   
  // Wrapper Class
  public class QLIWrapper{
    public Boolean showPreBTR{get;set;}
    public QuoteLineItem qliWrap{get;set;}
    public String color{get;set;}
    public boolean isLastRow{get;set;}
    public QLIWrapper(QuoteLineItem qli,boolean isLastRow) {
      qliWrap = qli;
      this.islastRow = isLastRow;
      color = getColorCode(qli,isLastRow);
    }
    
    // helper method to get color code
    private String getColorCode(QuoteLineItem q,boolean isLastRow) {
      String colorCode = '#E0E0E0';
      system.debug('------>'+isLastRow);
      system.debug('------>'+q.Vehicle__r.Sold_Flag__c);
      if(isLastRow){
        colorCode = 'cadetblue';
        return colorCode;
      }
      
      if(q.OverStock__c <> false) {
        colorCode = '#00cc00';
      }
      
      if(q.SpecialPrice__c <> null && q.SpecialPrice__c <> 0.00) {
        colorCode = '#ccffff';
      }

      //if(q.Display_Code__c == true) {
        //colorCode = '#ffff99';
      //}
      
      if(q.AS_IS_Vehicle__c == true) {
        colorCode = '#ffff99';
      }

      if(q.Vehicle__r.Sold_Flag__c != NULL && q.Vehicle__r.Sold_Flag__c) {
        colorCode = '#FF3333';
      }

      if(q.BankOfAmerica__c == true) {
        colorCode = '#FF8040';
      }

      if(q.NonCompliantCAUnits__c  == true) {
        colorCode = '#7fe57f';
      }
      
      system.debug('------>'+colorCode);
      system.debug('------>'+q.Vehicle__r.Sold_Flag__c);
      return colorCode ;
    }
    
    
  }
  
  // Wrapper class used in visualforce page to display Totals
  public class UAT_Total{
    public Double total_NVI{get;set;}
    public Double total_NVIPer{get;set;}
    public Double total_BookValue{get;set;}
    public Double total_SalesPrice{get;set;}
    public Double total_TakePrice{get;set;}
    public Double total_TakePricePer{get;set;}
    public Double total_GainLoss{get;set;}
    public Double total_ApprovedPrice{get;set;}
    public Double total_ApprovedPerofTake{get;set;}
    
    public UAT_Total(){
      this.total_NVI=0.0;
      this.total_NVIPer = 0.0;
      this.total_BookValue = 0.0;
      this.total_SalesPrice = 0.0;
      this.total_TakePrice = 0.0;
      this.total_TakePricePer = 0.0;
      this.total_GainLoss = 0.0;
      this.total_ApprovedPrice = 0.0;
      this.total_ApprovedPerofTake = 0.0;
    }
  }
}