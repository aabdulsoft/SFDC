//Generated by wsdl2apex

public class UpdateCompany {
    public class RequestData {
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class DCCompanyUpdate {
        public Integer ID;
        public Boolean IsSuccess;
        public String StatusMessage;
        private String[] ID_type_info = new String[]{'ID','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] IsSuccess_type_info = new String[]{'IsSuccess','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] StatusMessage_type_info = new String[]{'StatusMessage','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'ID','IsSuccess','StatusMessage'};
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
        public UpdateCompany.DCCompanyUpdate ProcessRequestResult;
        private String[] ProcessRequestResult_type_info = new String[]{'ProcessRequestResult','http://tempuri.org/','DCCompanyUpdate','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'ProcessRequestResult'};
    }
    public class UpdateCompanySoap {
        //public String endpoint_x = 'http://salesforce.ryder.com/crmtestservice/UpdateCompany.asmx';
        public String endpoint_x = RyderGlobalVariables.RYDER_WS_ENDPOINT + 'UpdateCompany.asmx';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://tempuri.org/', 'UpdateCompany'};
        public UpdateCompany.DCCompanyUpdate ProcessRequest(UpdateCompany.CRMCredential aCRMCredential,UpdateCompany.CompanyUpdateRequest aRequestData) {
            UpdateCompany.ProcessRequest_element request_x = new UpdateCompany.ProcessRequest_element();
            UpdateCompany.ProcessRequestResponse_element response_x;
            request_x.aCRMCredential = aCRMCredential;
            request_x.aRequestData = aRequestData;
            Map<String, UpdateCompany.ProcessRequestResponse_element> response_map_x = new Map<String, UpdateCompany.ProcessRequestResponse_element>();
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
              'UpdateCompany.ProcessRequestResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ProcessRequestResult;
        }
    }
    public class ProcessRequest_element {
        public UpdateCompany.CRMCredential aCRMCredential;
        public UpdateCompany.CompanyUpdateRequest aRequestData;
        private String[] aCRMCredential_type_info = new String[]{'aCRMCredential','http://tempuri.org/','CRMCredential','0','1','false'};
        private String[] aRequestData_type_info = new String[]{'aRequestData','http://tempuri.org/','CompanyUpdateRequest','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'aCRMCredential','aRequestData'};
    }
    public class CompanyUpdateRequest {
        public Integer ID;
        public String CompanyName;
        public String CompanyType;
        public String LesseNum;
        public String IndustryType;
        public String SICCode;
        public String CustomerType;
        public String SiteDuns;
        // 02/07/2012 Saad Wali Jaan- Added LegalSiteDuns
        public String LegalSiteDuns;
        public String HQDuns;
        public String UltimateDuns;
        public Boolean DummyFlag;
        public Boolean NationalCustFlag;
        public String LastUpdateUser;
        public String CompanySegment;
        //Added By Saad Wali Jaan. 07/11/2012- Changes for Equifax fields
        public string EquifaxNo;
        public string LegalEquifaxNo;
        public string EquifaxStreet1;
        public string EquifaxStreet2;
        public string EquifaxCity;
        public string EquifaxState;
        public string EquifaxCountry;
        public string EquifaxZipCode; 
        public string EquifaxPhone;
        public string EquifaxFax;
        public string EquifaxEmail;
        public string EquifaxCompanyName;
        
        private String[] ID_type_info = new String[]{'ID','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] CompanyName_type_info = new String[]{'CompanyName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CompanyType_type_info = new String[]{'CompanyType','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] LesseNum_type_info = new String[]{'LesseNum','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] IndustryType_type_info = new String[]{'IndustryType','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] SICCode_type_info = new String[]{'SICCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CustomerType_type_info = new String[]{'CustomerType','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] SiteDuns_type_info = new String[]{'SiteDuns','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        // 02/07/2012 Saad Wali Jaan - Added LegalSiteDuns
        private String[] LegalSiteDuns_type_info = new String[]{'LegalSiteDuns','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] HQDuns_type_info = new String[]{'HQDuns','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] UltimateDuns_type_info = new String[]{'UltimateDuns','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DummyFlag_type_info = new String[]{'DummyFlag','http://www.w3.org/2001/XMLSchema','boolean','1','1','true'};
        private String[] NationalCustFlag_type_info = new String[]{'NationalCustFlag','http://www.w3.org/2001/XMLSchema','boolean','1','1','true'};
        private String[] LastUpdateUser_type_info = new String[]{'LastUpdateUser','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CompanySegment_type_info = new String[]{'CompanySegment','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] EquifaxNo_type_info = new String[]{'EquifaxNo','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] LegalEquifaxNo_type_info = new String[]{'LegalEquifaxNo','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] EquifaxStreet1_type_info = new String[]{'EquifaxStreet1','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] EquifaxStreet2_type_info = new String[]{'EquifaxStreet2','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] EquifaxCity_type_info = new String[]{'EquifaxCity','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] EquifaxState_type_info = new String[]{'EquifaxState','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] EquifaxCountry_type_info = new String[]{'EquifaxCountry','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] EquifaxZipCode_type_info = new String[]{'EquifaxZipCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] EquifaxPhone_type_info = new String[]{'EquifaxPhone','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] EquifaxFax_type_info = new String[]{'EquifaxFax','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] EquifaxEmail_type_info = new String[]{'EquifaxEmail','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] EquifaxCompanyName_type_info = new String[]{'EquifaxCompanyName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'ID','CompanyName','CompanyType','LesseNum','IndustryType','SICCode','CustomerType','SiteDuns','LegalSiteDuns','HQDuns','UltimateDuns','DummyFlag','NationalCustFlag','LastUpdateUser','CompanySegment','EquifaxNo','LegalEquifaxNo','EquifaxStreet1','EquifaxStreet2','EquifaxCity','EquifaxState','EquifaxCountry','EquifaxZipCode','EquifaxPhone','EquifaxFax','EquifaxEmail','EquifaxCompanyName'};
    }
    public class ResponseData {
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
}