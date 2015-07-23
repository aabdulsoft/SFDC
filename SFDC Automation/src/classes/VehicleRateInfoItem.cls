public with sharing class VehicleRateInfoItem {

    public String name {get; set;}
    public VehicleRateInfoVO repairInfo {get; set;}
    public VehicleRateInfoVO accidentInfo {get; set;}
    public VehicleRateInfoVO accomodationInfo {get; set;}
    public VehicleRateInfoVO abuseInfo {get; set;}
    public VehicleRateInfoVO specialInfo {get; set;}
    public VehicleRateInfoVO miscellaneousInfo {get; set;}
    
	static testMethod void test_VehicleRateInfoItem() {
		
		VehicleRateInfoItem vri = new VehicleRateInfoItem();
        vri.name = '';
        VehicleRateInfoVO vi1 = new VehicleRateInfoVO();
        vi1.amount=1.0;
        vi1.amountType='';
        vi1.infoType = RyderGlobalVariables.InfoType.repair;
        
        vri.repairInfo = vi1;
        vri.accidentInfo = vi1;
        vri.accomodationInfo = vi1;
        vri.abuseInfo = vi1;
        vri.specialInfo = vi1;
        vri.miscellaneousInfo = vi1;
        
        vi1 = vri.repairInfo;
        vi1 = vri.accidentInfo;
        vi1 = vri.accomodationInfo;
        vi1 = vri.abuseInfo;
        vi1 = vri.specialInfo;
        vi1 = vri.miscellaneousInfo;
    }
    
}