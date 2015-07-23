public with sharing class DealSummaryToDisplay 
{
    public boolean selected{get;set;}
    public String Name {get; set;}
    
	static testMethod void test_DealSummaryToDisplay() {
        DealSummaryToDisplay ds = new DealSummaryToDisplay();
        ds.Name = '';
        ds.selected = true;
        
        system.assertEquals(ds.name, '');
        system.assertEquals(ds.selected, true);
    }
}