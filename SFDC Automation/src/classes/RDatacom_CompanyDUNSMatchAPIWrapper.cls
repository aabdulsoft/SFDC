/*
Changes History
Date        |    Author    			|     Changes
------------------------------------------------------
12/04/2014	|	Abdul Aziz Khatri	|	Created
*/

public class RDatacom_CompanyDUNSMatchAPIWrapper
{
    //variables for JSON declaration
    private static final String strBEGIN = '{"entities": [{"attributes": {"type":"DatacloudCompany"},';
    //private static final String strRETURNFIELDS = ',"fields": ["AnnualRevenue","City","CompanyId","Country","Description","DunsNumber","Fax","Industry","IsInactive","NaicsCode","NaicsDesc","Name","NumberOfEmployees","Ownership","Phone","Sic","SicDesc","State","Street","TickerSymbol","TradeStyle","Website","YearStarted","Zip","Site"]}';
    private static final String strRETURNFIELDS = '],"matchOptions": { "fields": "CompanyId, Name, City, Country, DunsNumber, Phone, State, Street, Zip, Site, AnnualRevenue, TradeStyle"';
    private static final String strMATCHOPTIONS = ', "matchEngine": "DunsRightMatchEngine",   "maxMatchResults": "10", "minMatchConfidence": "6", "rule": "DunsRightMatchRule", "sObjectType": "DatacloudCompany"';
    private static final String strEND = '  }}';
    private String strREQUEST;

    //object variables
    private List<RDatacom_CompanyDUNSResponse> lst_Response;
    private RDatacom_CompanyDUNSResponse Response;
    
    public boolean LongURL {get; set;}

	//Constructor
    public RDatacom_CompanyDUNSMatchAPIWrapper(){}

	//Error Property
    public RDatacom_Errors error
    {
        get 
        {
         	if (Response != null && Response.Errors != null)
        	{
        		return Response.Errors.get(0);
        	}      	
            return null;
        }
    }

	//Size Property
    public Integer size
    {
        get 
        {
          	if (Response != null)
        	{
        		return Response.size;
        	}      	
            return null;
        }
    }

  
  	//Request for the criteria in JSON to be pass to the 
    public String buildRequest(RDatacom_Company rdccomp)
    {
        Map<String, String> mapComp = new Map<String, String>();

        ///////////////// Name /////////////////////        
        if (rdccomp.CompanyName != null && rdccomp.CompanyName != '')
            mapComp.put('Name', rdccomp.CompanyName);

        ///////////////// State/////////////////////        
        if (rdccomp.state!= null && rdccomp.state!= '')
            mapComp.put('State', rdccomp.state);

        ///////////////// country/////////////////////
        if (rdccomp.country!= null && rdccomp.country!= '')
            mapComp.put('Country', rdccomp.country);
                
        ///////////////// street /////////////////////
        if (rdccomp.street!= null && rdccomp.street!= '')
            mapComp.put('Street', rdccomp.street);  
              
        ///////////////// city /////////////////////
        if (rdccomp.city!= null && rdccomp.city!= '')
            mapComp.put('City', rdccomp.city);
                
        ///////////////// zipCode /////////////////////
        if (rdccomp.zipCode!= null && rdccomp.zipCode!= '')
            mapComp.put('Zip', rdccomp.zipCode);
                
        ///////////////// city /////////////////////
        if (rdccomp.Phone!= null && rdccomp.Phone!= '')
            mapComp.put('Phone', rdccomp.Phone);

        String srequest = JSON.serialize(mapComp);
        
        if (srequest != '')
        	srequest = strBEGIN + srequest.replace('{','') + strRETURNFIELDS + strMATCHOPTIONS + strEND;

        system.debug('RDatacom_CompanyDunsRightJSONMatchAPI:buildRequest : ' + srequest);
        return srequest;       
    }
    
    //Deserialization of the response to their respective objects
    public RDatacom_CompanyDUNSResponse GenerateResponse(string sSessionID, String request)
    {
        HttpRequest httpRequest = buildHttpRequest(sSessionID, request);
        
        HttpResponse res = getHttpResponse(httpRequest);
        String rescomp = HandleResponse(res);
        lst_response = (List<RDatacom_CompanyDUNSResponse>)JSON.deserialize(rescomp,List<RDatacom_CompanyDUNSResponse>.class);
        system.debug('CompanyDUNSResponse : ' + lst_response + ', Size : ' + lst_response.size());
        if (lst_response.size() > 0)
            	Response = lst_response.get(0);
          
        return Response;
    }
    
	//Request for to pass to Match API   
    private HttpRequest buildHttpRequest(string sSessionID, string request)
    {
    
        HttpRequest req = new HttpRequest();

       	//req.setEndpoint(RyderConfig__c.getOrgDefaults().sfdcDomain__c + '/services/data/v32.0/match');
       	req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v32.0/match');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + sSessionID);
        req.setBody(request);
        req.setCompressed(false);
        
        return req;    
    }
    
    //Response from the Match API
    private HttpResponse getHttpResponse(HttpRequest req)
    {
        HttpResponse res = new HttpResponse();
       	Http http = new Http();        
    
		if (!Test.isRunningTest())
       		res = http.send(req);
       	system.debug('response : ' + res.getBody() + ' res - ' + res);
       	return res;   
    }
    
    //getting the search result from the response of the Match API
    private String HandleResponse(HttpResponse res)
    {
    	String result;
    	if(Test.isRunningTest())
    	{
    		result = '[{"errors":null,"matchEngine":"DunsRightMatchEngine","matchRecords":[{"additionalInformation":[{"name":"matchGrade","value":"AZZAAZZBFFZ"}],"fieldDiffs":[{"difference":"DIFFERENT","name":"Name"},{"difference":"DIFFERENT","name":"Phone"},{"difference":"DIFFERENT","name":"Zip"}],"matchConfidence":6.0,"record":{"attributes":{"type":"DatacloudCompany"},"Name":"Cellco Partnership","DunsNumber":"005282871","Street":"13623 S Dixie Hwy Ste 144","Phone":"+1.305.232.7780","Site":"Branch","State":"FL","CompanyId":7420000,"Zip":"33176-7295","Country":"United States","AnnualRevenue":0.0,"City":"Miami"}},{"additionalInformation":[{"name":"matchGrade","value":"AZZAAZZBFFZ"}],"fieldDiffs":[{"difference":"DIFFERENT","name":"Name"},{"difference":"DIFFERENT","name":"Phone"},{"difference":"DIFFERENT","name":"Zip"},{"difference":"DIFFERENT","name":"City"}],"matchConfidence":6.0,"record":{"attributes":{"type":"DatacloudCompany"},"Name":"Verizon Communications Inc.","DunsNumber":"023942688","Street":"2533 NW 79th Ave","Phone":"+1.305.477.8131","Site":"Branch","State":"FL","CompanyId":19391179,"Zip":"33122-1032","Country":"United States","AnnualRevenue":0.0,"City":"Doral"}},{"additionalInformation":[{"name":"matchGrade","value":"AZZAAZZBFFZ"}],"fieldDiffs":[{"difference":"DIFFERENT","name":"Name"},{"difference":"DIFFERENT","name":"Phone"},{"difference":"DIFFERENT","name":"Zip"}],"matchConfidence":6.0,"record":{"attributes":{"type":"DatacloudCompany"},"Name":"Cellco Partnership","DunsNumber":"030213180","Street":"11600 N Kendall Dr","Phone":"+1.305.598.7457","Site":"Branch","State":"FL","CompanyId":21890144,"Zip":"33176-1005","Country":"United States","AnnualRevenue":0.0,"City":"Miami"}},{"additionalInformation":[{"name":"matchGrade","value":"AZZAAZZBFFZ"}],"fieldDiffs":[{"difference":"DIFFERENT","name":"Name"},{"difference":"DIFFERENT","name":"Phone"},{"difference":"DIFFERENT","name":"Zip"}],"matchConfidence":6.0,"record":{"attributes":{"type":"DatacloudCompany"},"Name":"Verizon Florida LLC","DunsNumber":"152396867","Street":"100 Biscayne Blvd Ste 415","Phone":"+1.305.577.3934","Site":"Branch","State":"FL","CompanyId":44201831,"Zip":"33132-2344","Country":"United States","AnnualRevenue":0.0,"City":"Miami"}},{"additionalInformation":[{"name":"matchGrade","value":"AZZAAZZBFFZ"}],"fieldDiffs":[{"difference":"DIFFERENT","name":"Name"},{"difference":"DIFFERENT","name":"Phone"},{"difference":"DIFFERENT","name":"Zip"},{"difference":"DIFFERENT","name":"City"}],"matchConfidence":6.0,"record":{"attributes":{"type":"DatacloudCompany"},"Name":"Cellco Partnership","DunsNumber":"957998487","Street":"13256 Biscayne Blvd","Phone":"","Site":"Branch","State":"FL","CompanyId":68057638,"Zip":"33181-2040","Country":"United States","AnnualRevenue":0.0,"City":"North Miami"}},{"additionalInformation":[{"name":"matchGrade","value":"AZZAAZZBFFZ"}],"fieldDiffs":[{"difference":"DIFFERENT","name":"Name"},{"difference":"DIFFERENT","name":"Phone"},{"difference":"DIFFERENT","name":"Zip"}],"matchConfidence":6.0,"record":{"attributes":{"type":"DatacloudCompany"},"Name":"Verizon Communications Inc","DunsNumber":"009437304","Street":"16120 NW 13th Ave","Phone":"","Site":"Single Location","State":"FL","CompanyId":11724905,"Zip":"33169-5712","Country":"United States","AnnualRevenue":0.0,"City":"Miami"}},{"additionalInformation":[{"name":"matchGrade","value":"AZZAAZZBFFZ"}],"fieldDiffs":[{"difference":"DIFFERENT","name":"Name"},{"difference":"DIFFERENT","name":"Phone"},{"difference":"DIFFERENT","name":"Zip"}],"matchConfidence":6.0,"record":{"attributes":{"type":"DatacloudCompany"},"Name":"Verizon Wireless Messaging Services","DunsNumber":"015206287","Street":"5757 Blue Lagoon Dr","Phone":"+1.305.944.4141","Site":"Branch","State":"FL","CompanyId":14745620,"Zip":"33126-2058","Country":"United States","AnnualRevenue":0.0,"City":"Miami"}},{"additionalInformation":[{"name":"matchGrade","value":"AZZAAZZBFFZ"}],"fieldDiffs":[{"difference":"DIFFERENT","name":"Name"},{"difference":"DIFFERENT","name":"Phone"},{"difference":"DIFFERENT","name":"Zip"}],"matchConfidence":6.0,"record":{"attributes":{"type":"DatacloudCompany"},"Name":"Verizon Wireless Inc","DunsNumber":"023847333","Street":"13825 SW 88th St","Phone":"+1.305.388.2603","Site":"Branch","State":"FL","CompanyId":19350549,"Zip":"33186-1303","Country":"United States","AnnualRevenue":0.0,"City":"Miami"}},{"additionalInformation":[{"name":"matchGrade","value":"AZZAAZZBFFZ"}],"fieldDiffs":[{"difference":"DIFFERENT","name":"Name"},{"difference":"DIFFERENT","name":"Phone"},{"difference":"DIFFERENT","name":"Zip"}],"matchConfidence":6.0,"record":{"attributes":{"type":"DatacloudCompany"},"Name":"Cellco Partnership","DunsNumber":"030377027","Street":"271 SW 8th St","Phone":"+1.305.860.1886","Site":"Branch","State":"FL","CompanyId":21954053,"Zip":"33130-3529","Country":"United States","AnnualRevenue":0.0,"City":"Miami"}},{"additionalInformation":[{"name":"matchGrade","value":"AZZAAZZBFFZ"}],"fieldDiffs":[{"difference":"DIFFERENT","name":"Name"},{"difference":"DIFFERENT","name":"Phone"},{"difference":"DIFFERENT","name":"Zip"}],"matchConfidence":6.0,"record":{"attributes":{"type":"DatacloudCompany"},"Name":"Verizon Global Networks Inc","DunsNumber":"102274417","Street":"100 Biscayne Blvd Ste 415","Phone":"+1.305.377.9555","Site":"Branch","State":"FL","CompanyId":38171549,"Zip":"33132-2344","Country":"United States","AnnualRevenue":0.0,"City":"Miami"}}],"rule":"DunsRightMatchRule","size":10,"success":true}]';	
    	}else{
 			if(res.getStatus() == 'OK')
 				result = res.getBody();
    	}   
    	return result;	
    }
}