public with sharing class RollupOpptyTotalsVO {
    public decimal eva {get; set;}
    public decimal grossRevenue {get; set;}
    public decimal numOfVehicles {get; set;}
    // neelima- added old revenue- 08/05/2011
    public decimal oldRevenue {get; set;}
    public decimal eva_veh {get; set;}
    public decimal netInvestment {get; set;}
        
    public RollupOpptyTotalsVO() {
    	this.eva = 0.0;
    	this.grossRevenue = 0.0;
    	this.numOfVehicles = 0.0;
    	this.oldRevenue=0.0;
    	this.eva_veh=0.0;
    	this.netInvestment=0.0;
	}
    
	static testMethod void test_RollupOpptyTotalsVO() {
        RollupOpptyTotalsVO rotvo = new RollupOpptyTotalsVO();
        rotvo.eva = 1.0;
        rotvo.grossRevenue = 1.0;
        rotvo.numOfVehicles = 1.0;
        rotvo.oldRevenue=2.0;
         rotvo.eva_veh=3.0;
         rotvo.netInvestment=1.0;
        
        system.assertEquals(rotvo.eva, 1.0);
        system.assertEquals(rotvo.grossRevenue, 1.0);
		system.assertEquals(rotvo.numOfVehicles, 1.0);
		system.assertEquals(rotvo.oldRevenue, 2.0);
		system.assertEquals(rotvo.eva_veh, 3.0);
		system.assertEquals(rotvo.netInvestment, 1.0);
    }
    
}