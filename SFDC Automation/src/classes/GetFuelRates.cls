//Generated by wsdl2apex

public class GetFuelRates {
    public class GetFuelRatesSoap {
        public String endpoint_x = 'http://miavpsfweb01/crmtestservice/GetFuelRates.asmx';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://tempuri.org/', 'GetFuelRates'};
        public GetFuelRates.DCFuelRates ProcessRequest(GetFuelRates.CRMCredential aCRMCredential,GetFuelRates.FuelRateRequestCriteria aRequestData) {
            GetFuelRates.ProcessRequest_element request_x = new GetFuelRates.ProcessRequest_element();
            GetFuelRates.ProcessRequestResponse_element response_x;
            request_x.aCRMCredential = aCRMCredential;
            request_x.aRequestData = aRequestData;
            Map<String, GetFuelRates.ProcessRequestResponse_element> response_map_x = new Map<String, GetFuelRates.ProcessRequestResponse_element>();
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
              'GetFuelRates.ProcessRequestResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ProcessRequestResult;
        }
    }
    public class RequestData {
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class DCFuelRates {
        public String FuelRates_Id;
        public String FuelRates_Name;
        public String FuelRates_CurrencyIsoCode;
        public String FuelRates_Customer_No;
        public String FuelRates_District_Code;
        public String FuelRates_Domicile_Location_Code;
        public String FuelRates_Effective_Date;
        public String FuelRates_ExtRates;
        public String FuelRates_ExtRef_FisAcct_id;
        public String FuelRates_ExtRef_Unit;
        public Double FuelRates_Lease_Ceiling_Amount;
        public Double FuelRates_Lease_Floor_Amount;
        public Double FuelRates_Lease_Markup_Cost_Per_Gallon;
        public Double FuelRates_Lease_Outside_Markup_Rate;
        public Double FuelRates_Lease_Extra_Ceiling_Amount;
        public Double FuelRates_Lease_Extra_Floor_Amount;
        public Double FuelRates_Lease_Extra_Markup_Cost_Per_Gallon;
        public Double FuelRates_Lease_Extra_Outside_Markup_Rate;
        public String FuelRates_Other_Algorithm_Code;
        public String FuelRates_Other_FPF_Score;
        public Double FuelRates_Other_Markup_Rate;
        public String FuelRates_Other_Usage_Code;
        public Double FuelRates_Rental_Ceiling_Amount;
        public Double FuelRates_Rental_Floor_Amount;
        public Double FuelRates_Rental_Markup_Cost_Per_Gallon;
        public Double FuelRates_Rental_Outside_Markup_Rate;
        public String FuelRates_LesseeNo;
        public String FuelRates_Special_Rate_Flag;
        public String FuelRates_Vehicle;
        public String FuelRates_LastModifiedById;
        public String FuelRates_LastModifiedDate;
        public String FuelRates_CreatedById;
        public String FuelRates_CreatedDate;
        public Boolean FuelRates_Is_Deleted;
        public Boolean FuelRates_Is_Changed;
        public String FuelRates_Changed_Date;
        public Boolean FuelRates_Is_Uploaded;
        public String FuelRates_Uploaded_Date;
        private String[] FuelRates_Id_type_info = new String[]{'FuelRates_Id','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FuelRates_Name_type_info = new String[]{'FuelRates_Name','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FuelRates_CurrencyIsoCode_type_info = new String[]{'FuelRates_CurrencyIsoCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FuelRates_Customer_No_type_info = new String[]{'FuelRates_Customer_No','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FuelRates_District_Code_type_info = new String[]{'FuelRates_District_Code','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FuelRates_Domicile_Location_Code_type_info = new String[]{'FuelRates_Domicile_Location_Code','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FuelRates_Effective_Date_type_info = new String[]{'FuelRates_Effective_Date','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FuelRates_ExtRates_type_info = new String[]{'FuelRates_ExtRates','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FuelRates_ExtRef_FisAcct_id_type_info = new String[]{'FuelRates_ExtRef_FisAcct_id','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FuelRates_ExtRef_Unit_type_info = new String[]{'FuelRates_ExtRef_Unit','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FuelRates_Lease_Ceiling_Amount_type_info = new String[]{'FuelRates_Lease_Ceiling_Amount','http://www.w3.org/2001/XMLSchema','double','1','1','false'};
        private String[] FuelRates_Lease_Floor_Amount_type_info = new String[]{'FuelRates_Lease_Floor_Amount','http://www.w3.org/2001/XMLSchema','double','1','1','false'};
        private String[] FuelRates_Lease_Markup_Cost_Per_Gallon_type_info = new String[]{'FuelRates_Lease_Markup_Cost_Per_Gallon','http://www.w3.org/2001/XMLSchema','double','1','1','false'};
        private String[] FuelRates_Lease_Outside_Markup_Rate_type_info = new String[]{'FuelRates_Lease_Outside_Markup_Rate','http://www.w3.org/2001/XMLSchema','double','1','1','false'};
        private String[] FuelRates_Lease_Extra_Ceiling_Amount_type_info = new String[]{'FuelRates_Lease_Extra_Ceiling_Amount','http://www.w3.org/2001/XMLSchema','double','1','1','false'};
        private String[] FuelRates_Lease_Extra_Floor_Amount_type_info = new String[]{'FuelRates_Lease_Extra_Floor_Amount','http://www.w3.org/2001/XMLSchema','double','1','1','false'};
        private String[] FuelRates_Lease_Extra_Markup_Cost_Per_Gallon_type_info = new String[]{'FuelRates_Lease_Extra_Markup_Cost_Per_Gallon','http://www.w3.org/2001/XMLSchema','double','1','1','false'};
        private String[] FuelRates_Lease_Extra_Outside_Markup_Rate_type_info = new String[]{'FuelRates_Lease_Extra_Outside_Markup_Rate','http://www.w3.org/2001/XMLSchema','double','1','1','false'};
        private String[] FuelRates_Other_Algorithm_Code_type_info = new String[]{'FuelRates_Other_Algorithm_Code','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FuelRates_Other_FPF_Score_type_info = new String[]{'FuelRates_Other_FPF_Score','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FuelRates_Other_Markup_Rate_type_info = new String[]{'FuelRates_Other_Markup_Rate','http://www.w3.org/2001/XMLSchema','double','1','1','false'};
        private String[] FuelRates_Other_Usage_Code_type_info = new String[]{'FuelRates_Other_Usage_Code','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FuelRates_Rental_Ceiling_Amount_type_info = new String[]{'FuelRates_Rental_Ceiling_Amount','http://www.w3.org/2001/XMLSchema','double','1','1','false'};
        private String[] FuelRates_Rental_Floor_Amount_type_info = new String[]{'FuelRates_Rental_Floor_Amount','http://www.w3.org/2001/XMLSchema','double','1','1','false'};
        private String[] FuelRates_Rental_Markup_Cost_Per_Gallon_type_info = new String[]{'FuelRates_Rental_Markup_Cost_Per_Gallon','http://www.w3.org/2001/XMLSchema','double','1','1','false'};
        private String[] FuelRates_Rental_Outside_Markup_Rate_type_info = new String[]{'FuelRates_Rental_Outside_Markup_Rate','http://www.w3.org/2001/XMLSchema','double','1','1','false'};
        private String[] FuelRates_LesseeNo_type_info = new String[]{'FuelRates_LesseeNo','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FuelRates_Special_Rate_Flag_type_info = new String[]{'FuelRates_Special_Rate_Flag','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FuelRates_Vehicle_type_info = new String[]{'FuelRates_Vehicle','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FuelRates_LastModifiedById_type_info = new String[]{'FuelRates_LastModifiedById','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FuelRates_LastModifiedDate_type_info = new String[]{'FuelRates_LastModifiedDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FuelRates_CreatedById_type_info = new String[]{'FuelRates_CreatedById','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FuelRates_CreatedDate_type_info = new String[]{'FuelRates_CreatedDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FuelRates_Is_Deleted_type_info = new String[]{'FuelRates_Is_Deleted','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] FuelRates_Is_Changed_type_info = new String[]{'FuelRates_Is_Changed','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] FuelRates_Changed_Date_type_info = new String[]{'FuelRates_Changed_Date','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FuelRates_Is_Uploaded_type_info = new String[]{'FuelRates_Is_Uploaded','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] FuelRates_Uploaded_Date_type_info = new String[]{'FuelRates_Uploaded_Date','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'FuelRates_Id','FuelRates_Name','FuelRates_CurrencyIsoCode','FuelRates_Customer_No','FuelRates_District_Code','FuelRates_Domicile_Location_Code','FuelRates_Effective_Date','FuelRates_ExtRates','FuelRates_ExtRef_FisAcct_id','FuelRates_ExtRef_Unit','FuelRates_Lease_Ceiling_Amount','FuelRates_Lease_Floor_Amount','FuelRates_Lease_Markup_Cost_Per_Gallon','FuelRates_Lease_Outside_Markup_Rate','FuelRates_Lease_Extra_Ceiling_Amount','FuelRates_Lease_Extra_Floor_Amount','FuelRates_Lease_Extra_Markup_Cost_Per_Gallon','FuelRates_Lease_Extra_Outside_Markup_Rate','FuelRates_Other_Algorithm_Code','FuelRates_Other_FPF_Score','FuelRates_Other_Markup_Rate','FuelRates_Other_Usage_Code','FuelRates_Rental_Ceiling_Amount','FuelRates_Rental_Floor_Amount','FuelRates_Rental_Markup_Cost_Per_Gallon','FuelRates_Rental_Outside_Markup_Rate','FuelRates_LesseeNo','FuelRates_Special_Rate_Flag','FuelRates_Vehicle','FuelRates_LastModifiedById','FuelRates_LastModifiedDate','FuelRates_CreatedById','FuelRates_CreatedDate','FuelRates_Is_Deleted','FuelRates_Is_Changed','FuelRates_Changed_Date','FuelRates_Is_Uploaded','FuelRates_Uploaded_Date'};
    }
    public class CRMCredential {
        public String UserName;
        public String Password;
        public String SecurityToken;
        private String[] UserName_type_info = new String[]{'UserName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Password_type_info = new String[]{'Password','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] SecurityToken_type_info = new String[]{'SecurityToken','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'UserName','Password','SecurityToken'};
    }
    public class ProcessRequestResponse_element {
        public GetFuelRates.DCFuelRates ProcessRequestResult;
        private String[] ProcessRequestResult_type_info = new String[]{'ProcessRequestResult','http://tempuri.org/','DCFuelRates','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'ProcessRequestResult'};
    }
    public class ProcessRequest_element {
        public GetFuelRates.CRMCredential aCRMCredential;
        public GetFuelRates.FuelRateRequestCriteria aRequestData;
        private String[] aCRMCredential_type_info = new String[]{'aCRMCredential','http://tempuri.org/','CRMCredential','0','1','false'};
        private String[] aRequestData_type_info = new String[]{'aRequestData','http://tempuri.org/','FuelRateRequestCriteria','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'aCRMCredential','aRequestData'};
    }
    public class ResponseData {
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class FuelRateRequestCriteria {
        public String VehicleNo;
        private String[] VehicleNo_type_info = new String[]{'VehicleNo','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'VehicleNo'};
    }
}