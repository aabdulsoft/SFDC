@isTest
public class GetVehicleRepairReport_Test {

	static testMethod void VehicleRepairReportRequestCriteria() {
        
        GetVehicleRepairReport.VehicleRepairReportRequestCriteria vrc = new GetVehicleRepairReport.VehicleRepairReportRequestCriteria();
        vrc.SearchByVehicleNum = true;
        vrc.VehicleNum = 123;
        vrc.FromDate = DateTime.newInstance(1900, 1, 1, 00, 00, 00);
        vrc.ToDate = DateTime.newInstance(1900, 1, 1, 00, 00, 00);
        vrc.Type_x = 1;
        vrc.Sort_x = null;
        
        Test.startTest();
        GetVehicleRepairReport vrrTestCriteria = new GetVehicleRepairReport();
        Test.stopTest();
    }
    
	static testMethod void CRMCredential() {
		
		GetVehicleRepairReport.CRMCredential crm = new GetVehicleRepairReport.CRMCredential();
        crm.UserName = 'test';
        crm.Password = 'test';
        crm.SecurityToken = 'test';
        
        Test.startTest();
        GetVehicleRepairReport vrrTestCred = new GetVehicleRepairReport();
        Test.stopTest();
    }
    
    static testMethod void DCVehicleRepairReport() {
    	
    	GetVehicleRepairReport.DCVehicleRepairReport vrr = new GetVehicleRepairReport.DCVehicleRepairReport();
    	vrr.RepairOrderNum = 111;
    	vrr.Location = 111;
    	vrr.RepairDate = DateTime.newInstance(1900, 1, 1, 00, 00, 00);
    	vrr.Reason = 'test';
    	vrr.Odometer = 222;
    	vrr.SystemDetail = 'test';
    	vrr.Assembly = 'test';
    	vrr.Task = 'test';
    	vrr.LaborHour = 0.00;
    	vrr.LaborCost = 0.00;
    	vrr.PartsQuantity = 1;
    	vrr.PartsCost = 0.00;
    	vrr.TotalCost = 0.00;
    	vrr.AccountNum = 555;
    	vrr.Source = 'test';
    	
        Test.startTest();
        GetVehicleRepairReport vrrTestVrr = new GetVehicleRepairReport();
        Test.stopTest();
    }
    
    static testMethod void ArrayOfDCVehicleRepairReport() {
    	
    	List<GetVehicleRepairReport.DCVehicleRepairReport> vrr2 = new List<GetVehicleRepairReport.DCVehicleRepairReport>();
    	GetVehicleRepairReport.DCVehicleRepairReport vrr = new GetVehicleRepairReport.DCVehicleRepairReport();
    	vrr.RepairOrderNum = 111;
    	vrr.Location = 111;
    	vrr.RepairDate = DateTime.newInstance(1900, 1, 1, 00, 00, 00);
    	vrr.Reason = 'test';
    	vrr.Odometer = 222;
    	vrr.SystemDetail = 'test';
    	vrr.Assembly = 'test';
    	vrr.Task = 'test';
    	vrr.LaborHour = 0.00;
    	vrr.LaborCost = 0.00;
    	vrr.PartsQuantity = 1;
    	vrr.PartsCost = 0.00;
    	vrr.TotalCost = 0.00;
    	vrr.AccountNum = 555;
    	vrr.Source = 'test';
    	vrr2.add(vrr);
    	 
    	GetVehicleRepairReport.DCVehicleRepairReport[] DCVehicleRepairReport;
    	DCVehicleRepairReport = vrr2;
    	
        String[] DCVehicleRepairReport_type_info = new String[]{'DCVehicleRepairReport','http://tempuri.org/',null,'0','-1','true'};
        String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        String[] field_order_type_info = new String[]{'DCVehicleRepairReport'};
    	
        Test.startTest();
        GetVehicleRepairReport vrrTestArrVrr = new GetVehicleRepairReport();
        Test.stopTest();
    }
    
    static testMethod void ProcessRequestResponse_element() {
    	GetVehicleRepairReport.DCVehicleRepairReports ProcessRequestResult = new GetVehicleRepairReport.DCVehicleRepairReports();
    	
    	Test.startTest();
        GetVehicleRepairReport vrrTestp = new GetVehicleRepairReport();
        Test.stopTest();
    }
    
 	static testMethod void ProcessRequest_element() {
 		GetVehicleRepairReport.CRMCredential aCRMCredential = new GetVehicleRepairReport.CRMCredential();
 		aCRMCredential.UserName = 'test';
        aCRMCredential.Password = 'test';
        aCRMCredential.SecurityToken = 'test';
        
 		GetVehicleRepairReport.VehicleRepairReportRequestCriteria aRequestData = new GetVehicleRepairReport.VehicleRepairReportRequestCriteria();
 		
    	Test.startTest();
        GetVehicleRepairReport vrrTestpp = new GetVehicleRepairReport();
        Test.stopTest();
 	}
 	
	static testMethod void GetVehicleRepairReportSoap() {
        String endpoint_x = 'http://salesforce.ryder.com/sfdc_fulldev/GetVehicleRepairReport.asmx';
        String clientCertName_x = 'test';
        String clientCert_x = 'test';
        String clientCertPasswd_x = 'test';
        Integer timeout_x = 60000;
        
        Test.startTest();
        GetVehicleRepairReport vrrTestSoap = new GetVehicleRepairReport();
        Test.stopTest();
	}

}