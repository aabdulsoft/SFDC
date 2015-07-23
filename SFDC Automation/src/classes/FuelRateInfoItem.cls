public with sharing class FuelRateInfoItem {
    public String name {get; set;} 
    public VehicleRateInfoVO fuelInfo {get; set;}
    
	static testMethod void test_FuelRateInfoItem() {
		
		FuelRateInfoItem frii = new FuelRateInfoItem();
		frii.name = '';
		VehicleRateInfoVO vri = new VehicleRateInfoVO();
		vri.amount = 1.0;
		vri.amountType = '';
		vri.infoType = RyderGlobalVariables.InfoType.repair;
		frii.fuelInfo = vri;
		vri = frii.fuelInfo;
		
		System.assertequals(frii.name, '');
		
    }
}