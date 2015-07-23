public with sharing class VehicleRebillableRateInfoItem {

    public String name {get; set;}
    public VehicleRateInfoVO repairInfo {get; set;}
    public VehicleRateInfoVO accidentInfo {get; set;}
    public VehicleRateInfoVO accomodationInfo {get; set;}
    public VehicleRateInfoVO abuseInfo {get; set;}
    public VehicleRateInfoVO specialInfo {get; set;}
    public VehicleRateInfoVO miscellaneousInfo {get; set;}
    
    static testMethod void test_VehicleRebillableRateInfoItem(){
    	VehicleRebillableRateInfoItem vr = new VehicleRebillableRateInfoItem();
    	VehicleRateInfoVO vrvo = new VehicleRateInfoVO();
    	vr.repairInfo = vrvo;
    	vr.accidentInfo = vrvo;
    	vr.accomodationInfo = vrvo;
    	vr.abuseInfo = vrvo;
    	vr.specialInfo = vrvo;
    	vr.miscellaneousInfo = vrvo;
    	
    	system.assertnotequals(vr.repairInfo, null);
    	system.assertnotequals(vr.accidentInfo, null);
    	system.assertnotequals(vr.accomodationInfo, null);
    	system.assertnotequals(vr.abuseInfo, null);
    	system.assertnotequals(vr.specialInfo, null);
    	system.assertnotequals(vr.miscellaneousInfo, null);
    
    }
    
}