public with sharing class VehicleRepairReport{

    public List<VehicleRepairReportsProperties> vehReportList_Master = new List<VehicleRepairReportsProperties>();

	public String vehiclePageParameter {get; set;}
    public Integer totalRecCount {get;set;}
    public String periods {get; set;}
    public String filteredViews {get; set;}
	public String vehicleNumValue {get; set;}
	public Boolean showColumn {get; set;}
	public String pageMessage {get; set;}
	public Boolean showVehMessage {get; set;}
	DateTime dtFrom = null;
    DateTime dtTo = null;

	//Grid column properties
    public class VehicleRepairReportsProperties{
        public Integer RepairOrderNum {get; set;}
        public Integer Location {get; set;}
        public DateTime RepairDate {get; set;}
        public String Reason {get; set;}
        public Integer Odometer {get; set;}
        public String SystemDetail {get; set;}
        public String Assembly {get; set;}
        public String TaskDetail {get; set;}
        public Double LaborHour {get; set;}
        public Double LaborCost {get; set;}
        public Integer PartsQuantity {get; set;}
        public Double PartsCost {get; set;}
        public Double TotalCost {get; set;}
        public Integer AccountNum {get; set;}
        public String Source {get; set;}
    }
    
    
    
    /* Dropdown filter selection */
    public List<SelectOption> getPeriodItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('current','Current Month'));
        options.add(new SelectOption('6months','6 Months'));
        options.add(new SelectOption('1year','1 Year'));
        options.add(new SelectOption('all','Show All'));
        return options;
    }
    
    public String getPeriods() {
        return periods;
    }
    
    public void setPeriods(String periods) {
        this.periods= periods;
    }
    
    /* Radio Button filter selection */
    public List<SelectOption> getFilteredViewItems() {
        List<SelectOption> optionsView = new List<SelectOption>();
        optionsView.add(new SelectOption('1','Customer View')); //Hides all cost and account data
        optionsView.add(new SelectOption('0','Ryder – Internal View')); //Shows cost data
        return optionsView;
    }
    
    public String getFilteredViews() {
        return filteredViews;
    }
    
    public void setFilteredViews(String filteredViews) {
        this.filteredViews= filteredViews;
    }
    
    
    /* Populate page grid */
    public List<VehicleRepairReportsProperties> getVehicleRepairReportData(){
    	
    	vehReportList_Master.clear(); //make sure to clear list, before re-binding, to avoid governor limits
    	hideShowColumns(filteredViews); 
    	showVehMessage = false; //Hide vehicle number required text
    	
    	if(vehicleNumValue != null && vehicleNumValue.trim() != ''){
			
    		integer vehicleNumber = integer.valueOf(vehicleNumValue); //Vehicle Number input field value //(use 373987 for testing)
    		setDateFilters(periods); //set the selected period values 'From' and 'To' date ranges 

			//Call web service method to get results
	    	List<GetVehicleRepairReport.DCVehicleRepairReport> vehReport = SyncVehicleRepairReport(vehicleNumber, dtFrom, dtTo, integer.valueOf(filteredViews));

	    	fillMasterList(vehReport); //populate the master list from the web service results
    	}else{
    		showVehMessage = true; //Show vehicle number required text
    	}
    	
    	return vehReportList_Master;
    }
    
    public void setDateFilters(String ddlSelection){
    	Date currDate = Date.today();
    	
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
    		dtFrom = myDateTime.date(); //Default this to a hardcoded date of 1/1/1900. This will be handled in the webservice to get the correct dynamic date.
    		System.debug(LoggingLevel.INFO, 'aaaaaaaaaaa dtFrom: ' + dtFrom);
    		dtTo = currDate.addMonths(1).toStartofMonth().addDays(-1);
    	}
    }
    
    public void hideShowColumns(String filteredViews){
    	
    	//1 = Customer View : Hides all cost and account data
        //0 = Ryder – Internal View : Shows cost data
    	if(filteredViews == '1'){
    		showColumn = false;
    		pageMessage = ''; //Hide page message
    		
    	}else if(filteredViews == '0'){
    		showColumn = true;
    		pageMessage = '* Note: Overhead costs are not included in total cost'; //Default page message text
    		
    	}else{
    		showColumn = true;
    		
    	}
    }

    
    
    public VehicleRepairReport() { 
    	filteredViews = '0'; //default radio button filter to "Ryder - Internal view"
		showVehMessage = false; //default to false
		
    	vehiclePageParameter = ApexPages.currentPage().getParameters().get('id'); //Get vehicle id (Unit Number) if passed as a parameter
    	//Set defaults if a parameter is passed with a vehicle number (Unit Number)
    	if(vehiclePageParameter != null){
    		vehicleNumValue = vehiclePageParameter;
    		periods = 'current';
    	}
    }
    
    public VehicleRepairReport(ApexPages.StandardController stdController) { }
    
    public PageReference doSubmit() {
    	return null;
    }
    
    
	/* Web Service Callouts */
    public List<GetVehicleRepairReport.DCVehicleRepairReport> SyncVehicleRepairReport(integer vehicleNum, datetime fromDate, datetime toDate, integer filterType){
        
        // Create criteria
        GetVehicleRepairReport.VehicleRepairReportRequestCriteria requestCriteria = new GetVehicleRepairReport.VehicleRepairReportRequestCriteria();
        requestCriteria.SearchByVehicleNum = true;
        requestCriteria.VehicleNum = vehicleNum;
        requestCriteria.FromDate = fromDate;
        requestCriteria.ToDate = toDate;
        requestCriteria.Type_x = filterType;
        requestCriteria.Sort_x = null;
        
        // Create soap request
        GetVehicleRepairReport.GetVehicleRepairReportSoap vehicleRepairReportSoap = new GetVehicleRepairReport.GetVehicleRepairReportSoap();
        GetVehicleRepairReport.CRMCredential credential = new GetVehicleRepairReport.CRMCredential();
        credential.UserName = '';
        credential.Password = '';
        credential.SecurityToken = '';
        vehicleRepairReportSoap.timeout_x = RyderGlobalVariables.WS_TIMEOUT;
        vehicleRepairReportSoap.endpoint_x = RyderGlobalVariables.RYDER_WS_ENDPOINT + RyderGlobalVariables.GET_VEHICLE_REPAIR_REPORT;
        
        //Webservice Call Out
        GetVehicleRepairReport.DCVehicleRepairReports vehicleRepairReport = new GetVehicleRepairReport.DCVehicleRepairReports();
        vehicleRepairReport = vehicleRepairReportSoap.ProcessRequest(credential, requestCriteria);
        
        //Convert results to List<>
        List<GetVehicleRepairReport.DCVehicleRepairReport> lVehicleRepairReport = new List<GetVehicleRepairReport.DCVehicleRepairReport>();
        lVehicleRepairReport = vehicleRepairReport.VehicleRepairReports.DCVehicleRepairReport;
        
        return lVehicleRepairReport;
    }
    
    public void fillMasterList(List<GetVehicleRepairReport.DCVehicleRepairReport> vehReport) {
    	
    	if(vehReport != null){
	    	//loop through webservice result
	    	totalRecCount = 0;
	    	for(GetVehicleRepairReport.DCVehicleRepairReport vr : vehReport){
	    		
	        	//Bind Webservice result to visual force page/grid
	        	VehicleRepairReportsProperties vrResult = new VehicleRepairReportsProperties();
	        	vrResult.RepairOrderNum = vr.RepairOrderNum;
	        	vrResult.Location = vr.Location;
	        	vrResult.RepairDate = vr.RepairDate;
	        	vrResult.Reason = vr.Reason;
	        	vrResult.Odometer = vr.Odometer;
	        	vrResult.SystemDetail = vr.SystemDetail;
	        	vrResult.Assembly = vr.Assembly;
	        	vrResult.TaskDetail = vr.Task;
	        	vrResult.LaborHour = vr.LaborHour;
	        	vrResult.LaborCost = vr.LaborCost;
	        	vrResult.PartsQuantity = vr.PartsQuantity;
	        	vrResult.PartsCost = vr.PartsCost;
	        	vrResult.TotalCost = vr.TotalCost;
	        	vrResult.AccountNum = vr.AccountNum;
	        	vrResult.Source = vr.Source;
	        	vehReportList_Master.add(vrResult); 
	        	totalRecCount++;
	        }	
	        System.debug(LoggingLevel.INFO, 'aaaaaaaaaaa WS Count totalRecCount: ' + totalRecCount);

    	}else{
    		pageMessage = 'No Records For This Time Period';
    	}
    }

}