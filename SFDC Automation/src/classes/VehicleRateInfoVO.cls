public with sharing class VehicleRateInfoVO {
    public RyderGlobalVariables.InfoType infoType {get; set;}
    public String amountType {get; set;}
    public Decimal amount {get; set;}
    
	static testMethod void test_VehicleRateInfoVO() {
		
		VehicleRateInfoVO vri = new VehicleRateInfoVO();
        vri.infoType = RyderGlobalVariables.infoType.repair;
        vri.amountType = '';
        vri.amount = 1.0;
        
        system.assertEquals(vri.infoType, RyderGlobalVariables.InfoType.repair);
        system.assertEquals(vri.amountType, '');
		system.assertEquals(vri.amount, 1.0);
    }
    

}