public with sharing class DnB_WebServiceUtilities 
{
	/*
	*    Returns Duns number and Conf_cd information from D&B
	*/
	public List<DBAccount> GetDBAccountLookup(String CompanyName, String state, String country, String street,  
											  String city, String zipCode, String phone) 
	{
		//DnB_LookUp.DNB_WebServices_Providers_LookUp_wsp_LookUp_Port
	    List<DBAccount> result = new List<DBAccount>();

		DnB_LookUp.lookUpRequest lookupRequest = new DnB_LookUp.lookUpRequest();
		lookupRequest.UserId = RyderGlobalVariables.DNB_USERID;
		lookupRequest.Password = RyderGlobalVariables.DNB_PASSWORD;
		DnB_LookUp.lookUpInput dbInput = new DnB_LookUp.lookUpInput();
		dbinput.Match_Type='C';	//MPH 1/26/11 - this input element is necessary for D&B to return a non-null CONF_CD value
		dbInput.Name = CompanyName;
		dbInput.State_or_Region = state;
		if (country.trim().toUpperCase()==RyderGlobalVariables.COUNTRIES_CANADA_TEXT)
			country = RyderGlobalVariables.COUNTRIES_CANADA;
		dbInput.Country_Code = country;
		if (street != null)
			dbInput.Street_Address = street;
			
		if (city != null)
			dbInput.PostTown = city;
		
		if (zipCode != null)
			dbInput.Post_Code = zipCode;
		
		if (phone != null)
			dbInput.Telephone_Number = phone;
			
		lookupRequest.lookUpInput = dbInput;
		System.debug('DBRequest companyName - ' + companyName + ', state = '+state+', country - '+country);
		System.debug('DBRequest street - ' + street + ', city = '+city+', zipcode - '+zipcode);
		System.debug('DBRequest phone - '+phone);
		DnB_LookUp.DNB_WebServices_Providers_LookUp_wsp_LookUp_Port webServiceCall = new DnB_LookUp.DNB_WebServices_Providers_LookUp_wsp_LookUp_Port();
		webServiceCall.timeout_x = RyderGlobalVariables.WS_TIMEOUT;
		DnB_LookUp.lookUpResponse dbResponse;
		
		if (RyderGlobalVariables.IS_TEST)
        {
        	DBAccount dbAccount = new DBAccount();
	    	dbAccount.DunsNumber = RyderGlobalVariables.TEST_DUNS_NUMBER;
	    	dbAccount.Conf_cd = RyderGlobalVariables.TEST_CONF_CD;
	    	dbAccount.Company_Name = RyderGlobalVariables.TEST_PRIMARY_NAME;
	    	dbAccount.Address_Line = RyderGlobalVariables.TEST_ADDRESS_LINE;
	    	if (country.trim().toUpperCase()==RyderGlobalVariables.COUNTRIES_CANADA)
	    		country = RyderGlobalVariables.COUNTRIES_CANADA_TEXT;
	    	dbAccount.CountryCode = country;
	    	dbAccount.City = RyderGlobalVariables.TEST_CITY;
	    	dbAccount.State = RyderGlobalVariables.TEST_STATE;
	    	dbAccount.TLCM_Number = RyderGlobalVariables.TEST_TLCM_NBR;
	    	dbAccount.ZipCode = RyderGlobalVariables.TEST_POST_CODE;
	    	dbAccount.probabilityOfAccuracy = RyderGlobalVariables.TEST_CONF_CD;
	    	dbAccount.ryderProbability = CommonFunctions.getAccuracyProbability(Integer.valueOf(dbAccount.Conf_cd));
	    	result.add(dbAccount);
        }
        else
        {
		
			dbResponse = webServiceCall.ws_LookUp(lookUpRequest);
			System.debug('DBResponse - ' + dbResponse);
			if (dbResponse.DGX != null)
			{
				System.debug('dbResponse.DGX - ' + dbResponse.DGX);
				DnB_LookUp.STATUS status = dbResponse.DGX.SIGNONMSGSRSV1.SONRS.STATUS;  
				System.debug('dbResponse.DGX.SIGNONMSGSRSV1.SONRS.STATUS - ' + dbResponse.DGX.SIGNONMSGSRSV1.SONRS.STATUS);
				if (status.Code == '0')
				{
					if (dbResponse.DGX.CREDITMSGSRSV2.LOOKUPTRNRS.LOOKUPRS.LOOKUPRSCOMPANY != null)
					{
						DnB_LookUp.LOOKUPRSCOMPANY[] companies = dbResponse.DGX.CREDITMSGSRSV2.LOOKUPTRNRS.LOOKUPRS.LOOKUPRSCOMPANY.ArrayOfLOOKUPRSCOMPANYItem;
						System.debug('companies - ' + companies);
						for (DnB_LookUp.LOOKUPRSCOMPANY company : companies)
						{
					    	DBAccount dbAccount = new DBAccount();
					    	dbAccount.DunsNumber = company.DUNS_NBR;
					    	dbAccount.Conf_cd = company.CONF_CD;
					    	dbAccount.Company_Name = company.NME;
					    	dbAccount.Address_Line = company.ADR_LINE;
					    	if (country.trim().toUpperCase()==RyderGlobalVariables.COUNTRIES_CANADA)
					    		country = RyderGlobalVariables.COUNTRIES_CANADA_TEXT;
					    	dbAccount.CountryCode = country;
					    	dbAccount.City = company.NON_POST_TOWN;
					    	dbAccount.State = company.PRIM_GEO_AREA;
					    	dbAccount.TLCM_Number = company.TLCM_NBR;
					    	dbAccount.ZipCode = company.POST_CODE;
					    	dbAccount.probabilityOfAccuracy = company.PROB_OF_ACCR;
					    	if (company.CONF_CD != null)
					    		dbAccount.ryderProbability = CommonFunctions.getAccuracyProbability(Integer.valueOf(company.CONF_CD));
					    	else	dbAccount.ryderProbability= 0.0;
					    	result.add(dbAccount);
						}
					} else {
						// do nothing because we received valid response just found not matching companies.
						// throw new RyderException(RyderGlobalVariables.DEFAULT_DnB_ERROR_MSG, 'DnB_LookUp', String.valueOf(lookUpRequest) ,String.valueOf(dbResponse));
					}
				} else {
					throw new RyderException(RyderGlobalVariables.DEFAULT_DnB_ERROR_MSG, 'DnB_LookUp', String.valueOf(lookUpRequest), String.valueOf(dbResponse));
				}
			}
        }
	    return result;
	}

	/*
	*    Returns Business Verification information from DnB
	*/
	public BusinessVerification GetBusinessVerification(String dunsNumber)
	{
        BusinessVerification dbBusinessVerification = new BusinessVerification();
        dbBusinessVerification.hasBusinessVerication = false;
        // set user information
	    DnB_GDP.prodOrderRequest prodOrderRequest = new DnB_GDP.prodOrderRequest();
	    prodOrderRequest.UserId = RyderGlobalVariables.DNB_USERID;
	    prodOrderRequest.Password = RyderGlobalVariables.DNB_PASSWORD;

        // set request information
	    DnB_GDP.Orders order = new DnB_GDP.Orders();
	    order.Product_Type = RyderGlobalVariables.ORDER_PRODUCT_TYPE;
	    order.Product = RyderGlobalVariables.ORDER_PRODUCT_BUSINESS_VERIFICATION;
	    order.User_Language = RyderGlobalVariables.ORDER_USER_LANGUAGE;
	    order.Trade_Up_Indicator = RyderGlobalVariables.ORDER_TRADE_UP_INDICATOR;
	    order.DnB_DUNS_Number = dunsNumber;
        prodOrderRequest.Orders = order;
        
        DnB_GDP.Immediate_Delivery immDelivery = new DnB_GDP.Immediate_Delivery();
        immDelivery.Mode = RyderGlobalVariables.IMMEDIATE_DELIVERY_MODE;
        immDelivery.Format = RyderGlobalVariables.IMMEDIATE_DELIVERY_FORMAT;

        System.debug(LoggingLevel.Info, prodOrderRequest);
        DnB_GDP.DNB_WebServices_Providers_OrderAndInvestigations_GDP_wsp_GDP_Port soapRequest = 
                new DnB_GDP.DNB_WebServices_Providers_OrderAndInvestigations_GDP_wsp_GDP_Port();
        soapRequest.timeout_x = RyderGlobalVariables.WS_TIMEOUT;
        prodOrderRequest.Immediate_Delivery = immDelivery;
        
        DnB_GDP.GDPResponse response;
        if (RyderGlobalVariables.IS_TEST)
        {
			dbBusinessVerification.branchIndicator = RyderGlobalVariables.BRANCH_INDICATOR_N;
        	dbBusinessVerification.primaryName = RyderGlobalVariables.TEST_PRIMARY_NAME;
        	dbBusinessVerification.countryCode = RyderGlobalVariables.COUNTRIES_USA;
            dbBusinessVerification.dunsNumber = RyderGlobalVariables.TEST_DUNS_NUMBER;
            dbBusinessVerification.addressLine = RyderGlobalVariables.TEST_ADDRESS_LINE;
            dbBusinessVerification.countryCode = RyderGlobalVariables.COUNTRIES_USA;

            dbBusinessVerification.postalCode = RyderGlobalVariables.TEST_POST_CODE;
            dbBusinessVerification.postalTown = RyderGlobalVariables.TEST_CITY;
            dbBusinessVerification.sicCode = RyderGlobalVariables.TEST_SIC_CODE;
            //dbBusinessVerification.sicTypeCode= RyderGlobalVariables.PRIM_SIC_TYPE_CD;
            dbBusinessVerification.stateProvince = RyderGlobalVariables.TEST_STATE;
			//dbBusinessVerification.businessStructure = dataResponse.BUS_STRU;
			
			dbBusinessVerification.siteCountry = RyderGlobalVariables.COUNTRIES_USA;
			dbBusinessVerification.siteDUNS = RyderGlobalVariables.TEST_DUNS_NUMBER;
			dbBusinessVerification.domesticUltimateName = RyderGlobalVariables.TEST_PRIMARY_NAME;
			dbBusinessVerification.domesticUltimateCountry = RyderGlobalVariables.COUNTRIES_USA;
			dbBusinessVerification.domesticUltimateDUNS = RyderGlobalVariables.TEST_DUNS_NUMBER;
			dbBusinessVerification.globalUltimateName = RyderGlobalVariables.TEST_PRIMARY_NAME;
			dbBusinessVerification.globalUltimateCountry = RyderGlobalVariables.COUNTRIES_USA;
			dbBusinessVerification.globalUltimateDUNS = RyderGlobalVariables.TEST_DUNS_NUMBER;
			dbBusinessVerification.hqDUNS = RyderGlobalVariables.TEST_DUNS_NUMBER;
			dbBusinessVerification.hqDUNSCountry = RyderGlobalVariables.COUNTRIES_USA;
			dbBusinessVerification.hqDUNSName = RyderGlobalVariables.TEST_PRIMARY_NAME;
			
	        dbBusinessVerification.hasBusinessVerication = true;

        }
        else
        {
	        response = soapRequest.ws_OtherGDPProducts(prodOrderRequest);
	        System.debug(LoggingLevel.Info, response); 
	        
	        if (response.DGX != null)
	        {
	            DnB_GDP.STATUS status = response.DGX.SIGNONMSGSRSV1.SONRS.STATUS;  
	            if (status.Code == RyderGlobalVariables.OK_STATUS_CODE)
	            {
	                DnB_GDP.DATARS dataResponse = response.DGX.CREDITMSGSRSV2.DATATRNRS.DATARS;
	                dbBusinessVerification.dunsNumber = dataResponse.DUNS_NBR;
	                dbBusinessVerification.primaryName = dataResponse.PRIM_NME;
	                DnB_GDP.ArrayOfstring addrLines = dataResponse.ADR_LINE;
	                String addr = '';
	                if (addrLines != null) 
	                {
		                List<String> addLines = addrLines.ArrayOfstringItem;
		                
		                if (addLines != null && !addLines.isEmpty()) 
		                {
		                	for (Integer i = 0; i < addLines.size(); i++)
		                	{
		                		addr  = addr + addLines[i];
		                	}
		                }
	                }
	                dbBusinessVerification.addressLine = addr;	
	                dbBusinessVerification.branchIndicator = dataResponse.BR_IND;
	                dbBusinessVerification.countryCode = dataResponse.CTRY_CD;
	                dbBusinessVerification.postalCode = dataResponse.POST_CODE;
	                dbBusinessVerification.postalTown = dataResponse.POST_TOWN;
	                dbBusinessVerification.sicCode = dataResponse.PRIM_SIC;
	                dbBusinessVerification.sicTypeCode= dataResponse.PRIM_SIC_TYPE_CD;
	                dbBusinessVerification.stateProvince = dataResponse.PRIM_GEO_AREA;
					dbBusinessVerification.dunsNumber = dataResponse.DUNS_NBR;
					dbBusinessVerification.branchIndicator = dataResponse.BR_IND;
					dbBusinessVerification.businessStructure = dataResponse.BUS_STRU;
					dbBusinessVerification.primaryName = dataResponse.PRIM_NME;
					dbBusinessVerification.locationStatus = dataResponse.LOCN_STAT;
					dbBusinessVerification.siteName = dataResponse.PNT_NME;
	
					dbBusinessVerification.siteCountry = dataResponse.PNT_CTRY_CD;
					dbBusinessVerification.siteDUNS = dataResponse.PNT_DUNS;
					dbBusinessVerification.domesticUltimateName = dataResponse.DOM_ULT_PNT_NME;
					dbBusinessVerification.domesticUltimateCountry = dataResponse.DOM_ULT_CTRY_CD;
					dbBusinessVerification.domesticUltimateDUNS = dataResponse.DOM_ULT_PNT_DUNS;
					dbBusinessVerification.globalUltimateName = dataResponse.GBL_ULT_PNT_NME;
					dbBusinessVerification.globalUltimateCountry = dataResponse.GBL_ULT_CTRY_CD;
					dbBusinessVerification.globalUltimateDUNS = dataResponse.GBL_ULT_PNT_DUNS;
					dbBusinessVerification.hqDUNS = dataResponse.HQ_DUNS;
					dbBusinessVerification.hqDUNSCountry = dataResponse.HQ_CTRY_CD;
					dbBusinessVerification.hqDUNSName = dataResponse.HQ_NME;
					
					dbBusinessVerification.outOfBusiness = dataResponse.OUT_BUS_IND;
					
					if (dbBusinessVerification.outOfBusiness != null && dbBusinessVerification.outOfBusiness.toLowerCase() == 'y') {
                        throw new RyderException(RyderGlobalVariables.OUT_OF_BUS_ERROR_MSG, 'DnB BusinessVerification', String.valueOf(prodOrderRequest), String.valueOf(response));
					} 
                
			        dbBusinessVerification.hasBusinessVerication = true;
	            } 
	            else 
	            {
	                //error occurred
	                System.debug(LoggingLevel.ERROR, '++++++++++++++ Invalid Status code returned:' + response);
	                throw new RyderException(RyderGlobalVariables.DEFAULT_DnB_ERROR_MSG, 'DnB BusinessVerification', String.valueOf(prodOrderRequest), String.valueOf(response));
	            }
	        } 
	        else 
	        {
	        	//error occurred
	        	System.debug(LoggingLevel.ERROR, '+++++++++++++++++ Invalid response:' + response);
	        	throw new RyderException(RyderGlobalVariables.DEFAULT_DnB_ERROR_MSG, 'DnB BusinessVerification', String.valueOf(prodOrderRequest), String.valueOf(response));
	        }
        }
	    System.debug(LoggingLevel.Info, '++++++++++++++++++++++++++++++++' + dbBusinessVerification); 
	    return dbBusinessVerification;
	}


    /*
    *    Returns Corporate Linkage information from DnB
    *   Corporate Linkage - to obtain parent/subsidiary information (these are called in for US companies)
    */
    public CorporateLinkage GetCorporateLinkage(String dunsNumber)
    {
        CorporateLinkage dbCorporateLinkage = new CorporateLinkage();
		dbCorporateLinkage.hasCorporateLinkage = false;
        // set user information
        DnB_GDP.prodOrderRequest corporateLinkageRequest = new DnB_GDP.prodOrderRequest();
        corporateLinkageRequest.UserId = RyderGlobalVariables.DNB_USERID;
        corporateLinkageRequest.Password = RyderGlobalVariables.DNB_PASSWORD;

        // set request information
        DnB_GDP.Orders order = new DnB_GDP.Orders();
        order.Product_Type = RyderGlobalVariables.ORDER_PRODUCT_TYPE;
        order.Product = RyderGlobalVariables.ORDER_PRODUCT_CORPORATE_LINKAGE;
        order.User_Language = RyderGlobalVariables.ORDER_USER_LANGUAGE;
        order.Trade_Up_Indicator = RyderGlobalVariables.ORDER_TRADE_UP_INDICATOR;
        order.DnB_DUNS_Number = dunsNumber;
        corporateLinkageRequest.Orders = order;
        
        DnB_GDP.Immediate_Delivery immDelivery = new DnB_GDP.Immediate_Delivery();
        immDelivery.Mode = RyderGlobalVariables.IMMEDIATE_DELIVERY_MODE;
        immDelivery.Format = RyderGlobalVariables.IMMEDIATE_DELIVERY_FORMAT;

    
        System.debug(LoggingLevel.Info, corporateLinkageRequest);
        DnB_GDP.DNB_WebServices_Providers_OrderAndInvestigations_GDP_wsp_GDP_Port soapRequest = 
                new DnB_GDP.DNB_WebServices_Providers_OrderAndInvestigations_GDP_wsp_GDP_Port();
        soapRequest.timeout_x = 60000;
        corporateLinkageRequest.Immediate_Delivery = immDelivery;
        
        DnB_GDP.CorporateLinkageResponse response;
        
        if (RyderGlobalVariables.IS_TEST)
        {
			dbCorporateLinkage.branchIndicator = RyderGlobalVariables.BRANCH_INDICATOR_N;
        	dbCorporateLinkage.primaryName = RyderGlobalVariables.TEST_PRIMARY_NAME;
        	dbCorporateLinkage.countryCode = RyderGlobalVariables.COUNTRIES_USA;

            dbCorporateLinkage.dunsNumber = RyderGlobalVariables.TEST_DUNS_NUMBER;
            dbCorporateLinkage.enqDunsNumber = RyderGlobalVariables.TEST_DUNS_NUMBER;
            //dbCorporateLinkage.businessStructure = RyderGlobalVariables.OUT_BUS_IND;
            //dbCorporateLinkage.locationStatus = RyderGlobalVariables.LOCN_STAT;
            dbCorporateLinkage.countryCode = RyderGlobalVariables.COUNTRIES_USA;
			dbCorporateLinkage.siteName = RyderGlobalVariables.TEST_PRIMARY_NAME;
			dbCorporateLinkage.siteCountry = RyderGlobalVariables.COUNTRIES_USA;
			dbCorporateLinkage.siteDUNS = RyderGlobalVariables.TEST_DUNS_NUMBER;
			dbCorporateLinkage.hqDUNS = RyderGlobalVariables.TEST_DUNS_NUMBER;
			dbCorporateLinkage.hqName= RyderGlobalVariables.TEST_PRIMARY_NAME;
            dbCorporateLinkage.hqCountry = RyderGlobalVariables.COUNTRIES_USA;
			dbCorporateLinkage.domesticUltimateName = RyderGlobalVariables.TEST_PRIMARY_NAME;
			dbCorporateLinkage.domesticUltimateCountry = RyderGlobalVariables.COUNTRIES_USA;
			dbCorporateLinkage.domesticUltimateDUNS = RyderGlobalVariables.TEST_DUNS_NUMBER;
			dbCorporateLinkage.globalUltimateName = RyderGlobalVariables.TEST_PRIMARY_NAME;
			dbCorporateLinkage.globalUltimateCountry = RyderGlobalVariables.COUNTRIES_USA;
			dbCorporateLinkage.globalUltimateDUNS = RyderGlobalVariables.TEST_DUNS_NUMBER;
			dbCorporateLinkage.hasCorporateLinkage = true;
        }
        else
        {
        
	        response = soapRequest.ws_CorporateLinkage(corporateLinkageRequest);
	        
	        System.debug(LoggingLevel.Info, response); 
	        
	        if (response.DGX != null)
	        {
	            DnB_GDP.STATUS5 status = response.DGX.SIGNONMSGSRSV1.SONRS.STATUS;  
	            if (status.Code == RyderGlobalVariables.OK_STATUS_CODE)
	            {
	                DnB_GDP.DATARS3 dataResponse = response.DGX.CREDITMSGSRSV2.DATATRNRS.DATARS;
	                DnB_GDP.CORPORATE_LINKAGE corpLinkage = dataResponse.CORPORATE_LINKAGE;
	
	                dbCorporateLinkage.dunsNumber = corpLinkage.DUNS_NBR;
	                dbCorporateLinkage.enqDunsNumber = corpLinkage.ENQ_DUNS;
	                dbCorporateLinkage.businessStructure = corpLinkage.OUT_BUS_IND;
	                dbCorporateLinkage.primaryName = corpLinkage.PRIM_NME;
	                dbCorporateLinkage.branchIndicator = corpLinkage.BR_IND;
	                dbCorporateLinkage.locationStatus = corpLinkage.LOCN_STAT;
	                dbCorporateLinkage.countryCode = corpLinkage.CTRY_CD;
					dbCorporateLinkage.siteName = corpLinkage.PNT_NME;
					dbCorporateLinkage.siteCountry = corpLinkage.PNT_CTRY_CD;
					dbCorporateLinkage.siteDUNS = corpLinkage.PNT_DUNS;
					dbCorporateLinkage.hqDUNS = corpLinkage.HQ_DUNS;
					dbCorporateLinkage.hqName= corpLinkage.HQ_NME;
					dbCorporateLinkage.hqCountry = corpLinkage.HQ_CTRY_CD;
					dbCorporateLinkage.domesticUltimateName = corpLinkage.DOM_ULT_PNT_NME;
					dbCorporateLinkage.domesticUltimateCountry = corpLinkage.DOM_ULT_CTRY_CD;
					dbCorporateLinkage.domesticUltimateDUNS = corpLinkage.DOM_ULT_PNT_DUNS;
					dbCorporateLinkage.globalUltimateName = corpLinkage.GBL_ULT_PNT_NME;
					dbCorporateLinkage.globalUltimateCountry = corpLinkage.GBL_ULT_CTRY_CD;
					dbCorporateLinkage.globalUltimateDUNS = corpLinkage.GBL_ULT_PNT_DUNS;
					dbCorporateLinkage.hasCorporateLinkage = true;
	            } 
	            else 
	            {
	                //error occurred
	                System.debug(LoggingLevel.ERROR, '++++++++++++++ Invalid Status code returned:' + response);
	                throw new RyderException(RyderGlobalVariables.DEFAULT_DnB_ERROR_MSG, 'DnB CorporateLinkage', String.valueOf(corporateLinkageRequest), String.valueOf(response));
	            }
	        } 
	        else 
	        {
	            //error occurred
	            throw new RyderException(RyderGlobalVariables.DEFAULT_DnB_ERROR_MSG, 'DnB CorporateLinkage', String.valueOf(corporateLinkageRequest), String.valueOf(response));
	        }
        }
        System.debug(LoggingLevel.Info, '++++++++++++++++++++++++++++++++' + dbCorporateLinkage); 
        return dbCorporateLinkage;
    }
    
    /*
    * Worldbase Marketing Plus With Linkage (this is called for Canadian companies) - takes the place of 
    * Business Verification & Corporate linkage for Canadian companies.
    */
    public DnB_WorldBase.DATARS GetWorldBase(String dunsNumber)
    {
        DnB_WorldBase.DATARS result = null;

        // set user information
        DnB_WorldBase.prodOrderRequest worldBaseRequest = new DnB_WorldBase.prodOrderRequest();
        worldBaseRequest.UserId = RyderGlobalVariables.DNB_USERID;
        worldBaseRequest.Password = RyderGlobalVariables.DNB_PASSWORD;

        // set request information
        DnB_WorldBase.Orders order = new DnB_WorldBase.Orders();
        order.Product_Type = RyderGlobalVariables.ORDER_PRODUCT_TYPE;
        order.Product = RyderGlobalVariables.ORDER_PRODUCT_WORLDBASE_MARKETING_PLUS_WITH_LINKAGE;
        order.User_Language = RyderGlobalVariables.ORDER_USER_LANGUAGE;
        order.Trade_Up_Indicator = RyderGlobalVariables.ORDER_TRADE_UP_INDICATOR;
        order.DnB_DUNS_Number = dunsNumber;
        worldBaseRequest.Orders = order;
        
        DnB_WorldBase.Immediate_Delivery immDelivery = new DnB_WorldBase.Immediate_Delivery();
        immDelivery.Mode = RyderGlobalVariables.IMMEDIATE_DELIVERY_MODE;
        immDelivery.Format = RyderGlobalVariables.IMMEDIATE_DELIVERY_FORMAT;

    
        System.debug(LoggingLevel.Info, worldBaseRequest);
        DnB_WorldBase.DNB_WebServices_Providers_OrderAndInvestigations_WorldBase_wsp_WorldBase_Port soapRequest = 
                new DnB_WorldBase.DNB_WebServices_Providers_OrderAndInvestigations_WorldBase_wsp_WorldBase_Port();
        soapRequest.timeout_x = 60000;
        worldBaseRequest.Immediate_Delivery = immDelivery;
        
        DnB_WorldBase.worldBaseProductsResponse response;
        
        if (RyderGlobalVariables.IS_TEST)
        {
			result = new DnB_WorldBase.DATARS();
        	result.MKT_PHYS_CTRY_TEXT = RyderGlobalVariables.COUNTRIES_CANADA_TEXT;
        	result.MKT_PRIM_NME = RyderGlobalVariables.TEST_PRIMARY_NAME;
        	
        	result.MKT_HDQ_PNT_DUNS = RyderGlobalVariables.TEST_DUNS_NUMBER;
        	result.MKT_DOM_ULT_PNT_DUNS = RyderGlobalVariables.TEST_DUNS_NUMBER;
        	result.MKT_GLBL_ULT_PNT_DUNS = RyderGlobalVariables.TEST_DUNS_NUMBER;
        	result.MKT_PRIM_NME = RyderGlobalVariables.TEST_PRIMARY_NAME;

        	result.MKT_PHYS_ADR_LINE = RyderGlobalVariables.TEST_ADDRESS_LINE;
			result.MKT_PHYS_POST_TOWN_CD = RyderGlobalVariables.TEST_POST_CODE;
			result.MKT_PHYS_POST_TOWN_TEXT = RyderGlobalVariables.TEST_CITY;
			result.MKT_PHYS_GEO_AREA_CD = RyderGlobalVariables.TEST_STATE;
			result.MKT_PHYS_CTRY_TEXT = RyderGlobalVariables.COUNTRIES_CANADA_TEXT;
	
			result.MKT_SIC8 = RyderGlobalVariables.TEST_SIC_CODE;
        }
        else
        {
        	response = soapRequest.ws_WorldBase(worldBaseRequest);
        
	        System.debug(LoggingLevel.Info, response); 
	        
	        if (response.DGX != null)
	        {
	            DnB_WorldBase.STATUS2 status = response.DGX.CREDITMSGSRSV2.DATATRNRS.STATUS;  
	            System.debug(LoggingLevel.INFO, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ status - ' + status);
	            System.debug(LoggingLevel.INFO, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ RyderGlobalVariables.OK_STATUS_CODE-' + RyderGlobalVariables.OK_STATUS_CODE);
	            if (status.Code == RyderGlobalVariables.OK_STATUS_CODE)
	            {
	                result = response.DGX.CREDITMSGSRSV2.DATATRNRS.DATARS;
	                if (result.MKT_OUT_BUS_IND != null && result.MKT_OUT_BUS_IND.toLowerCase() == 'y') {
                        throw new RyderException(RyderGlobalVariables.OUT_OF_BUS_ERROR_MSG, 'DnB BusinessVerification', String.valueOf(worldBaseRequest), String.valueOf(response));
                    }
	            } else 
	            {
	                //error occurred
	                System.debug(LoggingLevel.ERROR, '++++++++++++++ Invalid Status code returned:' + response);
	                throw new RyderException(RyderGlobalVariables.DEFAULT_DnB_ERROR_MSG, 'DnB WorldBase', String.valueOf(worldBaseRequest), String.valueOf(response));
	            }
	        } 
	        else 
	        {
	            //error occurred
	            System.debug(LoggingLevel.ERROR, '+++++++++++++++++ Invalid response:' + response);
	            throw new RyderException(RyderGlobalVariables.DEFAULT_DnB_ERROR_MSG, 'DnB WorldBase', String.valueOf(worldBaseRequest), String.valueOf(response));
	        }
        }
        System.debug(LoggingLevel.Info, '++++++++++++++++++++++++++++++++' + result); 
        return result;
    }
    

}