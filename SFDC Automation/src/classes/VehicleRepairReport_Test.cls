@isTest
public class VehicleRepairReport_Test {

    static testMethod void getPeriodItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('current','Current Month'));
        options.add(new SelectOption('6months','6 Months'));
        options.add(new SelectOption('1year','1 Year'));
        options.add(new SelectOption('all','Show All'));
        
        Test.startTest();
        VehicleRepairReport vrrTestGetPeriodItems = new VehicleRepairReport();
        vrrTestGetPeriodItems.getPeriodItems();
        Test.stopTest();
    }
    
    static testMethod void VehicleRepairReportsProperties() {
		Integer RepairOrderNum = 111;
        Integer Location = 111;
        DateTime RepairDate = DateTime.newInstance(1900, 1, 1, 00, 00, 00);
        String Reason = 'test';
        Integer Odometer = 111;
        String SystemDetail = 'test';
        String Assembly = 'test';
        String TaskDetail = 'test';
        Double LaborHour = 0.00;
        Double LaborCost = 0.00;
        Integer PartsQuantity = 555;
        Double PartsCost = 0.00;
        Double TotalCost = 0.00;
        Integer AccountNum = 123;
        String Source = 'test';
        
        Test.startTest();
        VehicleRepairReport vrrTestVrrProp = new VehicleRepairReport();
        Test.stopTest();
    }
    
    static testMethod void getPeriods() {
        String periods = 'current';
        
        Test.startTest();
        VehicleRepairReport vrrTestGetPeriods = new VehicleRepairReport();
        vrrTestGetPeriods.getPeriods();
        Test.stopTest();
    }
    
    static testMethod void setPeriods() {
    	String periods = 'current';

		Test.startTest();
        VehicleRepairReport vrrTestGetPeriods = new VehicleRepairReport();
        vrrTestGetPeriods.setPeriods(periods);
        Test.stopTest();
    }
    
    static testMethod void getFilteredViewItems() {
        List<SelectOption> optionsView = new List<SelectOption>();
        optionsView.add(new SelectOption('1','Customer View')); 
        optionsView.add(new SelectOption('0','Ryder – Internal View')); 

        Test.startTest();
        VehicleRepairReport vrrTestGetFilteredViewItems = new VehicleRepairReport();
        vrrTestGetFilteredViewItems.getFilteredViewItems();
        Test.stopTest();
    }
    
    static testMethod void getFilteredViews() {
    	String filteredViews = '1';

        Test.startTest();
        VehicleRepairReport vrrTestGetFilteredViews = new VehicleRepairReport();
        vrrTestGetFilteredViews.getFilteredViews();
        Test.stopTest();
    }
    
    static testMethod void setFilteredViews() {
    	String filteredViews = '1';

        Test.startTest();
        VehicleRepairReport vrrTestSetFilteredViews = new VehicleRepairReport();
        vrrTestSetFilteredViews.setFilteredViews(filteredViews);
        Test.stopTest();
    }
    
    static testMethod void getVehicleRepairReportData() {
    	String vehicleNumValue = '123456';
    	Boolean showVehMessage = false; 
    	
		integer vehicleNumber = 123456; 

    	DateTime myDateTime = DateTime.newInstance(1900, 1, 1, 00, 00, 00);
    	List<GetVehicleRepairReport.DCVehicleRepairReport> vehReport = new List<GetVehicleRepairReport.DCVehicleRepairReport>();
    	GetVehicleRepairReport.DCVehicleRepairReport vrResult = new GetVehicleRepairReport.DCVehicleRepairReport();
    	vrResult.RepairOrderNum = 555;
    	vrResult.Location = 111;
    	vrResult.RepairDate = myDateTime;
    	vrResult.Reason = 'test';
    	vrResult.Odometer = 1;
    	vrResult.SystemDetail = 'test';
    	vrResult.Assembly = 'test';
    	vrResult.LaborHour = 0.00;
    	vrResult.LaborCost = 0.00;
    	vrResult.PartsQuantity = 1;
    	vrResult.PartsCost = 0.00;
    	vrResult.TotalCost = 0.00;
    	vrResult.AccountNum = 123;
    	vrResult.Source = 'test';
    	vehReport.add(vrResult);

		showVehMessage = true;
    	
    	Test.startTest();
		VehicleRepairReport vrrTestGetVrrData = new VehicleRepairReport();
		vrrTestGetVrrData.getVehicleRepairReportData();
		Test.stopTest();
    }
    
    static testMethod void setDateFilters() {
    	String ddlSelection = 'current';
    	Date currDate = Date.today();
    	DateTime dtFrom = null;
    	DateTime dtTo = null;
    	
    	if(ddlSelection == 'current'){
    		dtFrom = currDate.toStartofMonth();
    		dtTo = currDate.addMonths(1).toStartofMonth().addDays(-1);
    		
    	}else if(ddlSelection == '6months'){    		
    		dtFrom = currDate.addMonths(-6).toStartofMonth();
    		dtTo = currDate.addMonths(1).toStartofMonth().addDays(-1);
    		
    	}else if(ddlSelection == '1year'){
    		dtFrom = currDate.addMonths(-11).toStartofMonth();
    		dtTo = currDate.addMonths(1).toStartofMonth().addDays(-1);
    		
    	}else if(ddlSelection == 'all'){
    		DateTime myDateTime = DateTime.newInstance(1900, 1, 1, 00, 00, 00);
    		dtFrom = myDateTime.date();
    		dtTo = currDate.addMonths(1).toStartofMonth().addDays(-1);
    	}
    	
    	Test.startTest();
    	VehicleRepairReport vrrTestSetDateFilters = new VehicleRepairReport();
    	vrrTestSetDateFilters.setDateFilters(ddlSelection);
    	Test.stopTest();
    }
    
    static testMethod void hideShowColumns(){
    	String filteredViews = '1';
    	Boolean showColumn = false;
    	String pageMessage = '';
    	
    	if(filteredViews == '1'){
    		showColumn = false;
    		pageMessage = '';
    		
    	}else if(filteredViews == '0'){
    		showColumn = true;
    		pageMessage = '* Note: Overhead costs are not included in total cost';
    		
    	}else{
    		showColumn = true;
    	}
    	
    	Test.startTest();
    	VehicleRepairReport vrrTestHideShowColumns = new VehicleRepairReport();
    	vrrTestHideShowColumns.hideShowColumns(filteredViews);
    	Test.stopTest();
    }
    
    static testMethod void SyncVehicleRepairReport() {
        GetVehicleRepairReport.VehicleRepairReportRequestCriteria requestCriteria = new GetVehicleRepairReport.VehicleRepairReportRequestCriteria();
        requestCriteria.SearchByVehicleNum = true;
        requestCriteria.VehicleNum = 111;
        requestCriteria.FromDate = DateTime.newInstance(1900, 1, 1, 00, 00, 00);
        requestCriteria.ToDate = DateTime.newInstance(1900, 1, 1, 00, 00, 00);
        requestCriteria.Type_x = 0;
        requestCriteria.Sort_x = null;
        
        GetVehicleRepairReport.GetVehicleRepairReportSoap vehicleRepairReportSoap = new GetVehicleRepairReport.GetVehicleRepairReportSoap();
        GetVehicleRepairReport.CRMCredential credential = new GetVehicleRepairReport.CRMCredential();
        credential.UserName = '';
        credential.Password = '';
        credential.SecurityToken = '';
        vehicleRepairReportSoap.timeout_x = 60000;
        vehicleRepairReportSoap.endpoint_x = 'http://salesforce.ryder.com/crmtestservice/GetVehicleRepairReport.asmx';
        
        //Webservice Call Out
        GetVehicleRepairReport.DCVehicleRepairReports vehicleRepairReport = new GetVehicleRepairReport.DCVehicleRepairReports();
        
        vehicleRepairReport = vehicleRepairReportSoap.ProcessRequest(credential, requestCriteria);
        
        //Convert results to List<>
        List<GetVehicleRepairReport.DCVehicleRepairReport> lVehicleRepairReport = new List<GetVehicleRepairReport.DCVehicleRepairReport>();
        lVehicleRepairReport = vehicleRepairReport.VehicleRepairReports.DCVehicleRepairReport;
        
    	Test.startTest();
    	VehicleRepairReport vrrTestSyncWebService = new VehicleRepairReport();
    	vrrTestSyncWebService.SyncVehicleRepairReport(requestCriteria.VehicleNum, requestCriteria.FromDate, requestCriteria.ToDate, requestCriteria.Type_x);
    	Test.stopTest();
    }
    
    static testMethod void fillMasterList() {
    	DateTime myDateTime = DateTime.newInstance(1900, 1, 1, 00, 00, 00);
    	List<GetVehicleRepairReport.DCVehicleRepairReport> vehReport = new List<GetVehicleRepairReport.DCVehicleRepairReport>();
    	GetVehicleRepairReport.DCVehicleRepairReport vrResult = new GetVehicleRepairReport.DCVehicleRepairReport();
    	vrResult.RepairOrderNum = 555;
    	vrResult.Location = 111;
    	vrResult.RepairDate = myDateTime;
    	vrResult.Reason = 'test';
    	vrResult.Odometer = 1;
    	vrResult.SystemDetail = 'test';
    	vrResult.Assembly = 'test';
    	vrResult.LaborHour = 0.00;
    	vrResult.LaborCost = 0.00;
    	vrResult.PartsQuantity = 1;
    	vrResult.PartsCost = 0.00;
    	vrResult.TotalCost = 0.00;
    	vrResult.AccountNum = 123;
    	vrResult.Source = 'test';
    	vehReport.add(vrResult);
    	
    	String pageMessage = 'test';
    	
    	Test.startTest();
    	VehicleRepairReport vrrTestFillMasterList = new VehicleRepairReport();
    	vrrTestFillMasterList.fillMasterList(vehReport);
    	Test.stopTest();
    	
    }
    

}