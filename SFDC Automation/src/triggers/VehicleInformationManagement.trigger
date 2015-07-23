trigger VehicleInformationManagement on UVS_Vehicle_Information__c(after insert)
{
	VehicleInformationManagement_Helper.SetScheduleAUserPricing(trigger.new);
}