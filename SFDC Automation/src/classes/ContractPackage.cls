public with sharing class ContractPackage{

    public String packageNumber {get; set;}
    public String costSheetNumber {get; set;}
    public String productLine {get; set;}
    public Integer vehicleCount {get; set;}
    public String samClass {get; set;}
    public Date expirationDate {get; set;}
    public Date lastUpdateDate {get; set;}
    
	static testMethod void test_ContractPackage() {
        ContractPackage cp = new ContractPackage();
        cp.packageNumber = '';
        cp.costSheetNumber = '';
        cp.productLine = '';
        cp.vehicleCount = 0;
        cp.samClass = '';
        cp.expirationDate = Date.today();
        cp.lastUpdateDate = Date.today();
        
        system.assertEquals(cp.packageNumber, '');
        system.assertEquals(cp.costSheetNumber, '');
        system.assertEquals(cp.productLine, '');
        system.assertEquals(cp.vehicleCount, 0);
        system.assertEquals(cp.samClass, '');
        system.assertEquals(cp.expirationDate, Date.today());
        system.assertEquals(cp.lastUpdateDate, Date.today());
    }

    
}