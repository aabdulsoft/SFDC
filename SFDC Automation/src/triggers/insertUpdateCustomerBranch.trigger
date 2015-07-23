trigger insertUpdateCustomerBranch on Customer_Branch__c (after insert, after update) {
	
	if(UserInfo.getUserName()==RyderGlobalVariables.ETLUSER) return;
	Map<Id,Customer_Branch__c > ActiveCustomerBranches= new Map<Id,Customer_Branch__c >();
	Map<Id,Customer_Branch__c > InActiveCustomerBranches= new Map<Id,Customer_Branch__c >();
	System.debug(LoggingLevel.INFO, '+++++++++++++ Customer Branches:' + Trigger.newMap);
	User loggedInUser=[Select u.Profile.Name from User u where u.id= :UserInfo.getUserId()];
	String profileName=loggedInUser.Profile.Name;
	if(profileName=='System Administrator' || profileName=='SSO System Administrator')
	// if it is an insert trigger inserv all key contacts.
	if(Trigger.isInsert && Trigger.isAfter)	
	CustomerBranchKeyContact.InsertKeyContactsByCustomerBranch(Trigger.newMap); 
	
	// if it is an update trigger insert key contacts only when if status is updated to active.
	if(Trigger.isUpdate && Trigger.isAfter)	
	{
		for(Customer_Branch__c cb : Trigger.newMap.values())
		{
		if(cb.Customer_Branch_Status__c=='Active' && Trigger.oldMap.get(cb.Id).Customer_Branch_Status__c !='Active')
		ActiveCustomerBranches.put(cb.Id,cb);
		if(cb.Customer_Branch_Status__c !='Active' && Trigger.oldMap.get(cb.Id).Customer_Branch_Status__c =='Active')
		InActiveCustomerBranches.put(cb.Id,cb);
		}
		
		if(!ActiveCustomerBranches.isEmpty())
		CustomerBranchKeyContact.InsertKeyContactsByCustomerBranch(ActiveCustomerBranches);
		
		if(!InActiveCustomerBranches.isEmpty())
		{
			System.debug(LoggingLevel.INFO, '+++++++++++++ InActiveCustomerBranches:' + InActiveCustomerBranches);
			//delete all branch key contacts only for inactive customer branches
			CustomerBranchKeyContact.DeleteKeyContactsByCustomerBranch(InActiveCustomerBranches,true);
		}
						
	}
	
	
	

}