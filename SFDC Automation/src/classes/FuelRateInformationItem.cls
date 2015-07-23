public with sharing class FuelRateInformationItem {
	public String name {get; set;}
    public Decimal markupCostPerGallon {get; set;}
    public Decimal outsideMarkupRate {get; set;}
    public Decimal floorAmount {get; set;}
    public Decimal ceilingAmount {get; set;}
    
    public FuelRateInformationItem(String name, Decimal markupCostPerGallon, Decimal outsideMarkupRate, Decimal floorAmount, Decimal ceilingAmount) {
    	this.name = name;
    	this.markupCostPerGallon = markupCostPerGallon;
    	this.outsideMarkupRate = outsideMarkupRate;
    	this.floorAmount = floorAmount;
    	this.ceilingAmount = ceilingAmount;
    }
    
	static testMethod void test_FuelRateInformationItem() {
		
		FuelRateInformationItem frii = new FuelRateInformationItem('', 0.0, 0.0, 0.0, 0.0);
		frii.name = '';
		frii.markupCostPerGallon = 1.0;
		frii.outsideMarkupRate = 1.0;
		frii.floorAmount = 1.0;
		frii.ceilingAmount = 1.0;
		
		System.assertequals(frii.name, '');
		System.assertequals(frii.markupCostPerGallon, 1.0);
		System.assertequals(frii.outsideMarkupRate, 1.0);
		System.assertequals(frii.floorAmount, 1.0);
		System.assertequals(frii.ceilingAmount, 1.0);
		
    }
    
}