/*********************************************************************************************************
Name         : SubmitBTRService
Created By   : Sunil (Appiro)
Usage        : Global Class called upon submit for approval button on Quote.
***********************************************************************************************************/
global class SubmitBTRService {

    private static Id firstApprover;
    private static Id secondApprover;
    private static Id thirdApprover;
    private static boolean isException;

  // Create Customer Input Changes for T-213757
  webservice static String checkAlreadySubmitted(String quoteId){

    List<BTR__c> lstBTR = [SELECT Id,Status__c,  Quote__c FROM BTR__c WHERE Quote__c = :quoteId and Status__c != 'Rejected'];
    System.debug('@@@' + quoteId );
    System.debug('@@@' + lstBTR.size() );
    
    for(BTR__C btr : lstBTR){
      if(btr.Status__c == 'Approved'){
        return 'already approved';
      } 
    }
    
    
    if(lstBTR.size() > 0){
      return 'already submitted';
    }
    return 'success';
  }
    webservice static String CheckIfQLIHasZeroSalesPrice(String quoteId)
    {
        List<QuoteLineItem> lQuoteLineItem = [SELECT Id FROM QuoteLineItem WHERE QuoteId = : quoteId and (UnitPrice = null OR UnitPrice = 0)];
        if(lQuoteLineItem != null && lQuoteLineItem.size() > 0)
            return 'false';
        return 'true';
    }
    
  // Create Customer Input Changes for T-213757
  webservice static String submitBTR(String quoteId){
    RecordType recordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote' and DeveloperName = 'UVS'];

    Quote quoteObject = [SELECT Id,Requester_Comments__c, Status, Max_Approval_Level__c, RecordTypeId FROM Quote WHERE Id = :quoteId];


    //List<BTR__c> lstBTR = [SELECT Id, Quote__c FROM BTR__c WHERE Quote__c = :quoteId];

    //if(lstBTR.size() > 0 || quoteObject.Status == 'Submitted for BTR Approval'){
    //  return 'already submitted';
    //}

    if(quoteObject.RecordTypeId != recordTypeId.Id){
        return 'Quote record type is not UVS';
    }

    if(quoteObject.Max_Approval_Level__c == null || quoteObject.Max_Approval_Level__c < 1){
      return 'This record is not eligible for approval process, max approval level must be greater than 0';
    }
    if(String.isBlank(quoteObject.Requester_Comments__c) == true){
      return 'Please provide Requester Comments.';
    }

    if(quoteObject.Status == 'Denied' || quoteObject.Status == 'Rejected' || quoteObject.Status == 'Approved' || quoteObject.Status == 'Accepted'){
      return 'This record is not eligible for approval process.';
    }

    Id ryderBranchid = null;
    User u = [SELECT UTC__c FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
    if(String.isBlank(u.UTC__c) == false){
        List<Ryder_Branch__c> lstRB = [SELECT Id, Name FROM Ryder_Branch__c WHERE Branch_Code__c = :u.UTC__c];
        
        if(lstRB.size() > 0 && String.isBlank(lstRB.get(0).Name) == false){
            ryderBranchId = lstRB.get(0).Id;
        }
    }
    
    // Insert BTR Records.
    setApprovers();
    
    String FirstApproverMissing='This user do not have associated FAM Manager';
    String SecondApproverMissing='This user do not have associated DAM Manager';
    String thirdApproverMissing='This user do not have associated VP AM Manager';
    isException=false;
    String userRoleId=UserInfo.getUserRoleId();
    if(userRoleId!=null)
    {
        List<UserRole> usrRole=[Select id,name from userrole where id=:userRoleId];
        if(usrRole.size()>0)
        {
            string LoggedinUserRolename=usrRole[0].Name;
            System.debug('LOGGED IN USER ROLE--'+LoggedinUserRolename);
            UVS_Approval_Setting__c CS = UVS_Approval_Setting__c.getInstance();
            if(cs!=null){
            List<String> roleNames=cs.Role_Names__c.split(';');
            for(string role:roleNames)
            {
                System.debug(role);
                if(role==LoggedinUserRolename)
                {
                    isException=true;
                    FirstApproverMissing='This user do not have associated DAM Manager';
                    SecondApproverMissing='This user do not have associated VP AM Manager';
                    thirdApproverMissing='This user do not have associated SVP Manager';
                    break;
                    
                }
            }
          }  
        }
    }
    
    
    BTR__c objBTR = new BTR__c();
    objBTR.Quote__c = quoteId;
    objBTR.Ryder_Branch__c = ryderBranchId;
        
    if(firstApprover != null){
      objBTR.First_Approver__c = firstApprover;
    }
    if(secondApprover != null){
      objBTR.Second_Approver__c = secondApprover;
    }
    if(thirdApprover != null){
      objBTR.Third_Approver__c = thirdApprover;
    }
    objBTR.Requester_Comments__c = quoteObject.Requester_Comments__c;
    
     if(quoteObject.Max_Approval_Level__c == 1){
        if(objBTR.First_Approver__c == null){
            return FirstApproverMissing;
        }
     }
     else if(quoteObject.Max_Approval_Level__c == 2){
        if(objBTR.First_Approver__c == null){
          return FirstApproverMissing;
        }
        if(objBTR.Second_Approver__c == null){
          return SecondApproverMissing;
        }
     }
     else if(quoteObject.Max_Approval_Level__c == 3){
        if(objBTR.First_Approver__c == null){
          return FirstApproverMissing;
        }
        if(objBTR.Second_Approver__c == null){
          return SecondApproverMissing;
        }
        if(objBTR.Third_Approver__c == null){
          return thirdApproverMissing;
        }
     }

    //objBTR.Status__c = 'Submitted to FAM';
    Database.SaveResult sr = Database.insert(objBTR, false);
    if (sr.isSuccess())
    {
        submitAndProcessApprovalRequest(sr.getId());
        // Update Quote Status to Submitted for BTR Approval
        quoteObject.Status = 'Submitted for BTR Approval';
        update quoteObject;
        // Below code is written as part of QC 947. We need to mark all previous BTR to Rejected except Rejected and Approved
        List<BTR__c> lstBTR = [SELECT Id, Status__c, Quote__c, Requester_Comments__c 
        						FROM BTR__c WHERE Quote__c = : quoteId 
        						and Status__c != 'Rejected' and Status__c != 'Approved' 
        						AND Id != : sr.getId()];
	    for(BTR__C btr : lstBTR)
	    {
	    	btr.Status__c = 'Rejected';
	    	btr.Requester_Comments__c += ' Auto Rejected, as a new BTR is submitted.';
	    }
	    if(lstBTR.size() > 0)
    		update lstBTR;
        return 'success';
    }
    return 'An error occurred in submitting record for Approval, please contact administrator.';
  }


  // Helper method to get the User Id of the current Approver.
  private static void setApprovers(){
    Id firstApproverRoleId;
    Id secondApproverRoleId;
    List<User> lstUsers = [SELECT Id, UserRoleId FROM User WHERE isActive=true and UserRoleId IN
                 (SELECT parentRoleId FROM UserRole WHERE Id = :UserInfo.getUserRoleId())];


    if(!lstUsers.isEmpty()){
        firstApprover = lstUsers.get(0).Id;
        firstApproverRoleId = lstUsers.get(0).UserRoleId;
    }

    if(firstApprover != null && firstApproverRoleId != null){
        List<User> lstUsers_2 = [SELECT Id, UserRoleId FROM User WHERE isActive=true and UserRoleId IN
                 (SELECT parentRoleId FROM UserRole WHERE Id = :firstApproverRoleId)];
        if(!lstUsers_2.isEmpty()){
            secondApprover = lstUsers_2.get(0).Id;
            secondApproverRoleId = lstUsers_2.get(0).UserRoleId;
        }
    }

    if(secondApprover != null && secondApproverRoleId != null){
      List<User> lstUsers_3 = [SELECT Id, UserRoleId FROM User WHERE isActive=true and UserRoleId IN
                 (SELECT parentRoleId FROM UserRole WHERE Id = :secondApproverRoleId)];

        if(!lstUsers_3.isEmpty()){
            thirdApprover = lstUsers_3.get(0).Id;
        }
    }

  }


  // Helper method to submit Approval Process
  private static void submitAndProcessApprovalRequest(Id recordId) {
    // Create an approval request for the account
    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
    req1.setComments('Submitting request for approval.');
    req1.setObjectId(recordId);
    // Submit on behalf of a specific submitter
    //req1.setSubmitterId(user1.Id);
    // Submit the record to specific process and skip the criteria evaluation
    if(isException)
    req1.setProcessDefinitionNameOrId('BTR_Approval_Process_without_FAM');
    else
    req1.setProcessDefinitionNameOrId('BTR_Approval_Process');
    //req1.setSkipEntryCriteria(true);
    // Submit the approval request for the account
    Approval.ProcessResult result = Approval.process(req1);
  }
}