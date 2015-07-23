/*
*    Project        : QC630 Change lead conversion process to use DUNSRIGHT API for matching and restore restricted functionality to create account without match
*    Author         : Abdul Aziz Khatri
*    Date Created   : 11/13/2014
*    Description    : The purpose of this class is to get the company information from Data.com using 
*                     Data.com DUNSRight Match API. The Match API gives you the close match as compared to Search  API.
*/

public with sharing class RDatacom_DUNSMatchAPI{

    	private static RDatacom_CompanyDUNSMatchAPIWrapper dunswrapper;
    	
        public static List<DBAccount> getCompany(String CompanyName, String state, String country, String street, String city, String zipCode, String phone)
        {
            List<DBAccount> dbaccounts = new List<DBAccount>();

            List<RDatacom_DUNSMatchRecords> lstmatchRecords = new List<RDatacom_DUNSMatchRecords>(); 
          
            try
            {
                System.debug('START');
				dunswrapper = new RDatacom_CompanyDUNSMatchAPIWrapper();
				String request = dunswrapper.buildRequest(getDUNSCompany(CompanyName, state, country, street, city, zipCode, phone));				
				RDatacom_CompanyDUNSResponse res = dunswrapper.GenerateResponse(UserInfo.getSessionID(), request);
				
				//if (dunswrapper.error != null)
					//handle error
				if (res != null)
				{
					if (res.matchRecords.size() > 0)
					{
						for(RDatacom_DUNSMatchRecords matchRecords : res.matchRecords)
						{
							DBAccount dbaccount = new DBAccount();
                        	if(matchRecords.additionalinformation.size()>0)
                        	{
                            	//system.debug(matchRecords.additionalinformation.get(0));
                            	dbaccount.matchGrade = matchRecords.additionalinformation.get(0).value;
                        	}
                                
	                        if(matchRecords.record != null)
	                        {
	                            DatacloudCompany DCCompany = matchRecords.record;
	                            
	                            dbaccount.DCCompanyId = DCCompany.CompanyId;
	                            dbaccount.DCCompanyId = DCCompany.CompanyId;
	                            dbaccount.DunsNumber = DCCompany.DunsNumber;
	                            dbaccount.Company_Name = DCCompany.Name;
	                            dbaccount.Address_Line = DCCompany.Street;
	                            dbaccount.City = DCCompany.City;
	                            dbaccount.State = DCCompany.State;
	                                                            
	                            if (country.trim().toUpperCase()==RyderGlobalVariables.COUNTRIES_CANADA)
	                                country = RyderGlobalVariables.COUNTRIES_CANADA_TEXT;
	                            
	                            dbaccount.CountryCode = country;
	                            dbaccount.ZipCode = DCCompany.Zip;
	                            dbaccount.AnnualRevenue = DCCompany.AnnualRevenue;
	                            dbaccount.matchConfidence = Integer.ValueOf(matchRecords.matchConfidence);
	                            dbaccount.locationType = DCCompany.Site;
	                            dbaccount.tradeStyle = DCCompany.TradeStyle;
	                                                            
	                            dbaccounts.add(dbaccount);
	                            system.debug('dbaccount : ' + dbaccount);
	                        }
						}
	                    return dbaccounts;  							
					} 	
				}
				return null;
            }
            catch(Exception e)
            {
                return null;
            }
        }
        
        private static RDatacom_Company getDUNSCompany(String CompanyName, String state, String country, String street, String city, String zipCode, String phone)
        {
        	RDatacom_Company comp = new RDatacom_Company();
        	comp.CompanyName = CompanyName;
        	comp.state = state;		
        	comp.country = country;
        	comp.street = street;
        	comp.city = city;
        	comp.zipCode = zipCode;
        	comp.Phone = phone;
        	
        	return comp;
       
        }
                 
}