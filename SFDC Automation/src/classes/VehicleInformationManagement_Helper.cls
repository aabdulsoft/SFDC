public with sharing class VehicleInformationManagement_Helper
{
	// This Method is called from VehicleInformationManagement trigger on UVS_Vehicle_Information__c Object
	public static void SetScheduleAUserPricing(List<UVS_Vehicle_Information__c> lVehicleInfo)
	{
		Set<ID> lScheduleAIds = new Set<ID>();
		// Collect the ScheduleA RequestIds
		for(UVS_Vehicle_Information__c Obj : lVehicleInfo)
		{
			lScheduleAIds.add(Obj.ScheduleA_Request__c);
		}
		// Query all the ScheduleA Request records
		List<UVS_SheduleA_Request__c> lSchedleA = [Select u.Id, u.Request_Type__c, 
													u.User_Pricing_Name__c 
													From UVS_SheduleA_Request__c u 
													where Id in : lScheduleAIds and Request_Type__c != null];
		lScheduleAIds = new Set<ID>();
		// Iterate all the ScheduleA Request record and check if the Request Type is 'End of Lease'
		// And User Pricing Name is Custom LABEL User. It means this could be the first record for SheduleA Request
		// and we need to assign the correct User Pricing Name
		for(UVS_SheduleA_Request__c SchedleAObj : lSchedleA)
		{
			String sUser = '';
			if(SchedleAObj.User_Pricing_Name__c != null)
				sUser = SchedleAObj.User_Pricing_Name__c;
			// check if the Request Type is 'End of Lease'
			// And User Pricing Name is Custom LABEL User. It means this could be the first record for SheduleA Request
			// and we need to assign the correct User Pricing Name or the previously inserted records doens't have Postal Code
			System.debug('---------29-->'+sUser);
			System.debug('---------30-->'+LABEL.UVS_SA_Pricing_User);
			System.debug('---------31-->'+SchedleAObj.Request_Type__c);
			if(SchedleAObj.Request_Type__c == 'End of Lease' && sUser == LABEL.UVS_SA_Pricing_User)
				lScheduleAIds.add(SchedleAObj.id);
		}
		System.debug('---------35-->'+lScheduleAIds);
		// This the Set has records when call the Method to process the record
		if(lScheduleAIds.size() > 0)
			ScheduleARequestManagement_Helper.ManagePricingUserName(lScheduleAIds);
	}
}