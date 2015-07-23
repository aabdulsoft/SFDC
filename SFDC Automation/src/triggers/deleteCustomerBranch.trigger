trigger deleteCustomerBranch on Customer_Branch__c (after delete) {
	//if(UserInfo.getUserName()==RyderGlobalVariables.ETLUSER) return;
	// delete all keycontacts  for that customer branch not just all branch key contacts.
	CustomerBranchKeyContact.DeleteKeyContactsByCustomerBranch(Trigger.oldMap,false);
}