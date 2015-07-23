public with sharing class RatesToDisplay 
{
    public boolean selected{get;set;}
    public String Name {get; set;}
    public Integer No_of_Vehicles {get; set;}
    public Decimal EVA {get; set;}
    public Decimal Gross_Revenue {get; set;}
    public String Package_Type {get; set;}	
    public String Product_Line {get; set;}
    public String Rate_Sheet_Name {get; set;}
    
	static testMethod void test_RatesToDisplay() {
        RatesToDisplay rtd = new RatesToDisplay();
        rtd.EVA = 1.0;
        rtd.Gross_Revenue = 1.0;
        rtd.Name = '';
        rtd.No_of_Vehicles = 0;
        rtd.Package_Type = '';
        rtd.Product_Line = '';
        rtd.Rate_Sheet_Name = '';
        rtd.selected = true;
        
        system.assertEquals(rtd.EVA, 1.0);
        system.assertEquals(rtd.Gross_Revenue, 1.0);
		system.assertEquals(rtd.Name, '');
        system.assertEquals(rtd.No_of_Vehicles, 0);
        system.assertEquals(rtd.Package_Type, '');
        system.assertEquals(rtd.Product_Line, '');
        system.assertEquals(rtd.Rate_Sheet_Name, '');
        system.assertEquals(rtd.selected, true);
    }
}