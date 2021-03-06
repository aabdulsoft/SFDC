//Generated by wsdl2apex

public class GetVehicleRepairReport {
    public class RequestData {
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class ProcessRequestResponse_element {
        public GetVehicleRepairReport.DCVehicleRepairReports ProcessRequestResult;
        private String[] ProcessRequestResult_type_info = new String[]{'ProcessRequestResult','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'ProcessRequestResult'};
    }
    public class CRMCredential {
        public String UserName;
        public String Password;
        public String SecurityToken;
        private String[] UserName_type_info = new String[]{'UserName','http://tempuri.org/',null,'0','1','false'};
        private String[] Password_type_info = new String[]{'Password','http://tempuri.org/',null,'0','1','false'};
        private String[] SecurityToken_type_info = new String[]{'SecurityToken','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'UserName','Password','SecurityToken'};
    }
    public class ArrayOfDCVehicleRepairReport {
        public GetVehicleRepairReport.DCVehicleRepairReport[] DCVehicleRepairReport;
        private String[] DCVehicleRepairReport_type_info = new String[]{'DCVehicleRepairReport','http://tempuri.org/',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'DCVehicleRepairReport'};
    }
    public class VehicleRepairReportRequestCriteria {
        public Boolean SearchByVehicleNum;
        public Integer VehicleNum;
        public DateTime FromDate;
        public DateTime ToDate;
        public Integer Type_x;
        public String Sort_x;
        private String[] SearchByVehicleNum_type_info = new String[]{'SearchByVehicleNum','http://tempuri.org/',null,'1','1','false'};
        private String[] VehicleNum_type_info = new String[]{'VehicleNum','http://tempuri.org/',null,'1','1','false'};
        private String[] FromDate_type_info = new String[]{'FromDate','http://tempuri.org/',null,'1','1','false'};
        private String[] ToDate_type_info = new String[]{'ToDate','http://tempuri.org/',null,'1','1','false'};
        private String[] Type_x_type_info = new String[]{'Type','http://tempuri.org/',null,'1','1','false'};
        private String[] Sort_x_type_info = new String[]{'Sort','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'SearchByVehicleNum','VehicleNum','FromDate','ToDate','Type_x','Sort_x'};
    }
    public class DCVehicleRepairReport {
        public Integer RepairOrderNum;
        public Integer Location;
        public DateTime RepairDate;
        public String Reason;
        public Integer Odometer;
        public String SystemDetail;
        public String Assembly;
        public String Task;
        public Double LaborHour;
        public Double LaborCost;
        public Integer PartsQuantity;
        public Double PartsCost;
        public Double TotalCost;
        public Integer AccountNum;
        public String Source;
        private String[] RepairOrderNum_type_info = new String[]{'RepairOrderNum','http://tempuri.org/',null,'1','1','false'};
        private String[] Location_type_info = new String[]{'Location','http://tempuri.org/',null,'1','1','false'};
        private String[] RepairDate_type_info = new String[]{'RepairDate','http://tempuri.org/',null,'1','1','false'};
        private String[] Reason_type_info = new String[]{'Reason','http://tempuri.org/',null,'0','1','false'};
        private String[] Odometer_type_info = new String[]{'Odometer','http://tempuri.org/',null,'1','1','false'};
        private String[] SystemDetail_type_info = new String[]{'SystemDetail','http://tempuri.org/',null,'0','1','false'};
        private String[] Assembly_type_info = new String[]{'Assembly','http://tempuri.org/',null,'0','1','false'};
        private String[] Task_type_info = new String[]{'Task','http://tempuri.org/',null,'0','1','false'};
        private String[] LaborHour_type_info = new String[]{'LaborHour','http://tempuri.org/',null,'1','1','false'};
        private String[] LaborCost_type_info = new String[]{'LaborCost','http://tempuri.org/',null,'1','1','false'};
        private String[] PartsQuantity_type_info = new String[]{'PartsQuantity','http://tempuri.org/',null,'1','1','false'};
        private String[] PartsCost_type_info = new String[]{'PartsCost','http://tempuri.org/',null,'1','1','false'};
        private String[] TotalCost_type_info = new String[]{'TotalCost','http://tempuri.org/',null,'1','1','false'};
        private String[] AccountNum_type_info = new String[]{'AccountNum','http://tempuri.org/',null,'1','1','false'};
        private String[] Source_type_info = new String[]{'Source','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'RepairOrderNum','Location','RepairDate','Reason','Odometer','SystemDetail','Assembly','Task','LaborHour','LaborCost','PartsQuantity','PartsCost','TotalCost','AccountNum','Source'};
    }
    public class ProcessRequest_element {
        public GetVehicleRepairReport.CRMCredential aCRMCredential;
        public GetVehicleRepairReport.VehicleRepairReportRequestCriteria aRequestData;
        private String[] aCRMCredential_type_info = new String[]{'aCRMCredential','http://tempuri.org/',null,'0','1','false'};
        private String[] aRequestData_type_info = new String[]{'aRequestData','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'aCRMCredential','aRequestData'};
    }
    public class DCVehicleRepairReports {
        public GetVehicleRepairReport.ArrayOfDCVehicleRepairReport VehicleRepairReports;
        private String[] VehicleRepairReports_type_info = new String[]{'VehicleRepairReports','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'VehicleRepairReports'};
    }
    public class ResponseData {
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class GetVehicleRepairReportSoap {
        public String endpoint_x = 'http://salesforce.ryder.com/crmtestservice/GetVehicleRepairReport.asmx';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://tempuri.org/', 'GetVehicleRepairReport'};
        public GetVehicleRepairReport.DCVehicleRepairReports ProcessRequest(GetVehicleRepairReport.CRMCredential aCRMCredential,GetVehicleRepairReport.VehicleRepairReportRequestCriteria aRequestData) {
            GetVehicleRepairReport.ProcessRequest_element request_x = new GetVehicleRepairReport.ProcessRequest_element();
            request_x.aCRMCredential = aCRMCredential;
            request_x.aRequestData = aRequestData;
            GetVehicleRepairReport.ProcessRequestResponse_element response_x;
            Map<String, GetVehicleRepairReport.ProcessRequestResponse_element> response_map_x = new Map<String, GetVehicleRepairReport.ProcessRequestResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/ProcessRequest',
              'http://tempuri.org/',
              'ProcessRequest',
              'http://tempuri.org/',
              'ProcessRequestResponse',
              'GetVehicleRepairReport.ProcessRequestResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ProcessRequestResult;
        }
    }
}