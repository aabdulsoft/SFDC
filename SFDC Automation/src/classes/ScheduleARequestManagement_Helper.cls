public with sharing class ScheduleARequestManagement_Helper
{
	// Below Method is called on SheduleA_Request Insert and if the Request Type is 'ScheduleA' then default the 
	// User Pricing Name as in Custom LABEL UVS_SA_Pricing_User
	public static void ManageRequestTypeInsert(List<UVS_SheduleA_Request__c> lScheduleA)
	{
		for(UVS_SheduleA_Request__c ObjSCheduleA : lScheduleA)
		{
			if(ObjSCheduleA.Request_Type__c == 'ScheduleA')
				ObjSCheduleA.User_Pricing_Name__c = LABEL.UVS_SA_Pricing_User;
		}
	}
	// Below Method is called on SheduleA_Request Update
	// This Method checks if the Request Type field is updated by user or not
	// If updated then it further process the request and set the correct User Pricing Name
	public static void ManageRequestTypeUpdate(List<UVS_SheduleA_Request__c> lScheduleA, Map<Id, UVS_SheduleA_Request__c> mScheduleAOld)
	{
		Set<ID> lScheduleAIds = new Set<ID>();		
		for(UVS_SheduleA_Request__c ObjSCheduleA : lScheduleA)
		{
			String sNew = '';
			String sOld = '';
			if(ObjSCheduleA.Request_Type__c != null)
				sNew = ObjSCheduleA.Request_Type__c;
			if(mScheduleAOld.get(ObjSCheduleA.Id).Request_Type__c != null)
				sOld = mScheduleAOld.get(ObjSCheduleA.Id).Request_Type__c;
			// Check if the request Type field is changed then collect the SheduleA_Request record Id
			if(sNew != sOld)
				lScheduleAIds.add(ObjSCheduleA.Id);
		}
		System.debug('---------25-->'+lScheduleAIds);
		// if the Collection size is mare then one then Process that SheduleA_Request list 
		if(lScheduleAIds.size() > 0)
			ManagePricingUserName(lScheduleAIds);
	}
	// This method takes SheduleA_Request Ids as an Argument and Process those records
	// This method is called from ScheduleARequestManagement_Helper.ManageRequestTypeUpdate method 
	// and VehicleInformationManagement_Helper.SetScheduleAUserPricing method
	public static void ManagePricingUserName(Set<ID> lScheduleAIds)
	{
		// Query the SheduleA_Request and its child record of Vehicle Information object
		List<UVS_SheduleA_Request__c> lScheduleARequest = new List<UVS_SheduleA_Request__c>();
		Map<Id, UVS_SheduleA_Request__c> mSchedleA = 
										new Map<Id, UVS_SheduleA_Request__c>([Select u.Id, u.Request_Type__c, 
										u.User_Pricing_Name__c, 
										(Select Id, Vehicle_Number__c, Postal_Code__c 
										From Vehicle_Information__r 
										where Postal_Code__c != null Order by CreatedDate Desc) 
										From UVS_SheduleA_Request__c u 
										where Id in : lScheduleAIds  
										and Request_Type__c != null]);
		System.debug('---------42-->'+mSchedleA);
		Set<String> sPostalCode = new Set<String>();
		// Iterate the SheduleA_Request reocrds and from Vehicle Informatoin child records collect the Postal Code
		for(UVS_SheduleA_Request__c ObjSCheduleA : mSchedleA.values())
		{
			for(UVS_Vehicle_Information__c Obj : ObjSCheduleA.Vehicle_Information__r)
			{
				sPostalCode.add(Obj.Postal_Code__c);
			}
		}
		// If postal Code list is there then call the Postal Code method and get a Map of Postal code and Corresponding User ID
		System.debug('---------51-->'+sPostalCode);
		Map<String,Id> postalCodeSelfMap = new Map<String,Id>();
		if(sPostalCode.size() > 0)
			postalCodeSelfMap = GetPostalCode(sPostalCode);
		System.debug('---------55-->'+postalCodeSelfMap);
		// Iterate SheduleA_Request records
		for(UVS_SheduleA_Request__c ObjSCheduleA : mSchedleA.values())
		{
			// Now if the Request Type is not 'ScheduleA' then we need to check if there is any Vehicle Information record is there or not
			// If there is Vehicle Information records then Based on the Postal Code set the User
			// If No Vehicle Information record exist or Postal Code is missing or Request Type is 'ScheduleA'
			// then set the default Custom LABEL User
			Boolean bDefault = true;
			System.debug('---------58-->'+ObjSCheduleA.Request_Type__c);
			if(ObjSCheduleA.Request_Type__c != 'ScheduleA' && postalCodeSelfMap.size() > 0)
			{
				System.debug('---------61-->'+ObjSCheduleA.Vehicle_Information__r);
				for(UVS_Vehicle_Information__c Obj : ObjSCheduleA.Vehicle_Information__r)
				{
					if(postalCodeSelfMap.get(Obj.Postal_Code__c) != null)
					{
						ObjSCheduleA.User_Pricing_Name__c = postalCodeSelfMap.get(Obj.Postal_Code__c);
						lScheduleARequest.add(ObjSCheduleA);
						bDefault = false;
						break;
					}
				}
			}
			// If No Vehicle Information record exist or Postal Code is missing or Request Type is 'ScheduleA'
			// then set the default Custom LABEL User
			if(bDefault)
			{
				ObjSCheduleA.User_Pricing_Name__c = LABEL.UVS_SA_Pricing_User;
				lScheduleARequest.add(ObjSCheduleA);
			}
		}
		System.debug('---------78-->'+lScheduleARequest);
		if(lScheduleARequest.size( )> 0)
			update lScheduleARequest;
	}
	// This method get the Postal Codes as Argument and Query the data from Postal Code table and get the UVS Assignment Ids
	// This method returns a Map where Key is Postal code and Value is UVS Assignment User Id
	public static Map<String,Id> GetPostalCode(Set<String> postalCodeSet)
	{
		Map<String,Id> postalCodeSelfMap = new Map<String,Id>();
		for(Postal_Code__c postCode : [SELECT Postal_Code__c, UVS_Assignee__c 
										FROM Postal_Code__c 
										WHERE Postal_Code__c IN : postalCodeSet and 
										UVS_Assignee__c != null])
		{
			System.debug('---------90-->'+postCode);
			// Create a Map of Postal Code and User Id
    		postalCodeSelfMap.put(postCode.Postal_Code__c , postCode.UVS_Assignee__c);
      	}
      	// return the Map
      	return postalCodeSelfMap;
	}
	
}