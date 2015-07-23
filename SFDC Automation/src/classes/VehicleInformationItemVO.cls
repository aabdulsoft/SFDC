public with sharing class VehicleInformationItemVO {

    public String vehicleNumber {get; set;}
    public String packageNumber {get; set;}
    public String costSheetNumber {get; set;}
    public String productLine {get; set;}
    public String samClass {get; set;}
    public Date expirationDate {get; set;}
    public Date lastUpdateDate {get; set;}
    
    public VehicleInformationItemVO (String vehicleNumber, String packageNumber,String costSheetNumber,
     String productLine, String samClass, Date expirationDate, Date lastUpdateDate) {
        this.vehicleNumber = vehicleNumber;
        this.packageNumber = packageNumber;
        this.costSheetNumber = costSheetNumber;
        this.productLine = productLine;
        this.samClass = samClass;
        this.expirationDate = expirationDate;
        this.lastUpdateDate = lastUpdateDate;
    }

	static testMethod void test_VehicleInformationItemVO() {
		
		VehicleInformationItemVO vii = new VehicleInformationItemVO('','','','','',date.today(), date.today());
		vii.vehicleNumber = '';
		vii.packageNumber = '';
		vii.costSheetNumber = '';
		vii.productLine = '';
		vii.samClass = '';
		vii.expirationDate = date.today();
		vii.lastUpdateDate = date.today();
        
        system.assertEquals(vii.vehicleNumber, '');
        system.assertEquals(vii.packageNumber, '');
		system.assertEquals(vii.costSheetNumber, '');
		system.assertEquals(vii.productLine, '');
		system.assertEquals(vii.samClass, '');
		system.assertEquals(vii.expirationDate, Date.today());
		system.assertEquals(vii.lastUpdateDate, Date.today());
    }

}