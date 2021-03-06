//Generated by wsdl2apex

public class PWRelocateOpportunities {
    public class RequestData {
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class ProcessRequestResponse_element {
        public PWRelocateOpportunities.DCPartialWins ProcessRequestResult;
        private String[] ProcessRequestResult_type_info = new String[]{'ProcessRequestResult','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'ProcessRequestResult'};
    }
    public class PartialWinRequestCriteria {
        public String Id;
        public String UserRideId;
        public String DataToRelocateInJson;
        private String[] Id_type_info = new String[]{'Id','http://tempuri.org/',null,'0','1','false'};
        private String[] UserRideId_type_info = new String[]{'UserRideId','http://tempuri.org/',null,'0','1','false'};
        private String[] DataToRelocateInJson_type_info = new String[]{'DataToRelocateInJson','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'Id','UserRideId','DataToRelocateInJson'};
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
    public class DCPartialWin {
        public String PartialWinId;
        public String ext_ref_id;
        public String Owner_xc;
        public String Rate_Sheet_xc;
        public String Rate_Sheet_Name_xc;
        public String Status_xc;
        public String NewOpportunityId;
        public String NewOpportunityName;
        public String UserRideId;
        public String DataToRelocateInJson;
        private String[] PartialWinId_type_info = new String[]{'PartialWinId','http://tempuri.org/',null,'0','1','false'};
        private String[] ext_ref_id_type_info = new String[]{'ext_ref_id','http://tempuri.org/',null,'0','1','false'};
        private String[] Owner_xc_type_info = new String[]{'Owner__c','http://tempuri.org/',null,'0','1','false'};
        private String[] Rate_Sheet_xc_type_info = new String[]{'Rate_Sheet__c','http://tempuri.org/',null,'0','1','false'};
        private String[] Rate_Sheet_Name_xc_type_info = new String[]{'Rate_Sheet_Name__c','http://tempuri.org/',null,'0','1','false'};
        private String[] Status_xc_type_info = new String[]{'Status__c','http://tempuri.org/',null,'0','1','false'};
        private String[] NewOpportunityId_type_info = new String[]{'NewOpportunityId','http://tempuri.org/',null,'0','1','false'};
        private String[] NewOpportunityName_type_info = new String[]{'NewOpportunityName','http://tempuri.org/',null,'0','1','false'};
        private String[] UserRideId_type_info = new String[]{'UserRideId','http://tempuri.org/',null,'0','1','false'};
        private String[] DataToRelocateInJson_type_info = new String[]{'DataToRelocateInJson','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'PartialWinId','ext_ref_id','Owner_xc','Rate_Sheet_xc','Rate_Sheet_Name_xc','Status_xc','NewOpportunityId','NewOpportunityName','UserRideId','DataToRelocateInJson'};
    }
    public class DCPartialWins {
        public PWRelocateOpportunities.ArrayOfDCPartialWin PartialWins;
        private String[] PartialWins_type_info = new String[]{'PartialWins','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'PartialWins'};
    }
    public class ProcessRequest_element {
        public PWRelocateOpportunities.CRMCredential aCRMCredential;
        public PWRelocateOpportunities.PartialWinRequestCriteria aRequestData;
        private String[] aCRMCredential_type_info = new String[]{'aCRMCredential','http://tempuri.org/',null,'0','1','false'};
        private String[] aRequestData_type_info = new String[]{'aRequestData','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'aCRMCredential','aRequestData'};
    }
    public class ArrayOfDCPartialWin {
        public PWRelocateOpportunities.DCPartialWin[] DCPartialWin;
        private String[] DCPartialWin_type_info = new String[]{'DCPartialWin','http://tempuri.org/',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'DCPartialWin'};
    }
    public class ResponseData {
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class PWRelocateOpportunitiesSoap {
        public String endpoint_x = RyderGlobalVariables.RYDER_WS_ENDPOINT + 'PWRelocateOpportunities.asmx';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://tempuri.org/', 'PWRelocateOpportunities'};
        public PWRelocateOpportunities.DCPartialWins ProcessRequest(PWRelocateOpportunities.CRMCredential aCRMCredential,PWRelocateOpportunities.PartialWinRequestCriteria aRequestData) {
            PWRelocateOpportunities.ProcessRequest_element request_x = new PWRelocateOpportunities.ProcessRequest_element();
            request_x.aCRMCredential = aCRMCredential;
            request_x.aRequestData = aRequestData;
            PWRelocateOpportunities.ProcessRequestResponse_element response_x;
            Map<String, PWRelocateOpportunities.ProcessRequestResponse_element> response_map_x = new Map<String, PWRelocateOpportunities.ProcessRequestResponse_element>();
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
              'PWRelocateOpportunities.ProcessRequestResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ProcessRequestResult;
        }
    }
}