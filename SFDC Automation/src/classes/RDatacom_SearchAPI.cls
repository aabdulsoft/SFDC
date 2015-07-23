/*
*    Project        : CODE 9882 Jan 2014 SFDC - Replace DnB with Data.com )
*    Author         : Abdul Aziz Khatri
*    Date Created   : 06/12/2014
*    Last Updated   : 06/20/2014    
*    Description    : The purpose of this class is to get the company information from Data.com using 
*                     Data.com Search API 
*/

public with sharing class RDatacom_SearchAPI {
  
    //*********************************************************************************
    //The function will retreive the company information from Data.com which internally call 
    //DnB api in order to get the readable information like Address etc. which are obfuscated when 
    //called only thru datacloudCompany
    //*********************************************************************************
    public static List<DBAccount> getCompany(String CompanyName, String state, String country, String street, String city, String zipCode, String phone) 
    {
        
        //Collection variables
        List<DBAccount> dbAccounts = new List<DBAccount>();
        List<String> CompanyId = getDatacloudCompany(CompanyName, state, country, street, city, zipCode, phone);
        List<DatacloudDandBCompany> dbDandBCompany = getDatacloudDandBCompany(CompanyId);
        System.debug('getcompany dbandbcompany : ' + dbDandBCompany);

            if (dbDandBCompany != null)
            {
                for(DatacloudDandBCompany tempdbDandBCompany: dbDandBCompany)
                {
                    DBAccount dba = new DBAccount();
                    dba.Id = tempdbDandBCompany.Id;
                    dba.DCCompanyId = tempdbDandBCompany.CompanyId;
                    dba.DunsNumber = tempdbDandBCompany.DunsNumber;
                    dba.Company_Name = tempdbDandBCompany.Name;
                    dba.Address_Line = tempdbDandBCompany.Street;
                    dba.CountryCode = tempdbDandBCompany.Country;
                    dba.City = tempdbDandBCompany.City;
                    dba.State = tempdbDandBCompany.State;
                    dba.ZipCode = tempdbDandBCompany.Zip;
                    
                    //AAK 07/17/2014 Start - REQ343
                    //Added part of change request from Jose and Eduardo to add the location type and revenue
                    //System.debug('Location Status : ' + tempdbDandBCompany.LocationStatus);
                    dba.locationType = getLocationType(tempdbDandBCompany.LocationStatus);
                    //System.debug('dba.locationType : ' + dba.locationType);                              
                    
                    dba.AnnualRevenue = tempdbDandBCompany.SalesVolume;
                    //AAK 12/21/2014 Start - QC630 Change lead conversion process to use DUNSRIGHT API for matching and restore restricted functionality to create account without match                    
                    dba.tradeStyle = tempdbDandBCompany.TradeStyle1;
                    //AAK 12/21/2014 End
                    //System.debug('dba.AnnualRevenue : ' + dba.AnnualRevenue);
                    //AAK 07/17/2014 Start
                    
                    //Not available even in webserive 
                    //dba.locationType =
                    
                    //Missing 
                    //dba.Conf_cd =
                    //dba.probabilityOfAccuracy =
                    //dba.TLCM_Number =
                    
                    //internal variables
                    //if (company.CONF_CD != null)
                    //   dbAccount.ryderProbability = CommonFunctions.getAccuracyProbability(Integer.valueOf(company.CONF_CD));
                    //else    dbAccount.ryderProbability= 0.0;
                    //dba.ryderProbability =
                    //dba.selected =
                   
                    dbAccounts.add(dba);
                    //System.debug('dbAccounts1 = ' + dbAccounts);
                }
            }
            if (Test.isRunningTest())
            {    
                DBAccount dbat = new DBAccount();
                dbat.Id = '40242024';
                dbat.DCCompanyId = '20';
                dbat.DunsNumber = 'tempdbDandBCompany.DunsNumber';
                dbat.Company_Name = 'ABC';
                dbat.Address_Line = 'Doral';
                dbat.CountryCode = 'US';
                dbat.City = 'Miami';
                dbat.State = 'FL';
                dbat.ZipCode = '33193';  
            
                dbAccounts.add(dbat);
                System.debug('dbat = ' + dbat);
            }
            return dbAccounts;
    }  

    //*********************************************************************************
    //This function will retreive the company information based on the company Ids.
    //public List<DatacloudDandBCompany> getDandBCompany(List<String> pCompanyId, String street)
    //*********************************************************************************
    public static List<String> getDatacloudCompany(String CompanyName, String state, String country, String street, String city, String zipCode, String phone)
    {
        string strSOQL = '';            //for SOQL
        string strCond = '';            //for SOQL Conditions

        List<String> lstCompId = new List<String>();
        List<DatacloudCompany> dbDatacloudCompany = new List<DatacloudCompany>();
        
        strSOQL = 'SELECT CompanyId, State FROM DatacloudCompany ';

        //building for where clause
        if (CompanyName != null && CompanyName != '')
        {
            CompanyName = CompanyName.replace('\'', ' ');
            System.debug('CompanyName =' + CompanyName);
            if (strCond == '')
                strCond += 'Name LIKE \'' + CompanyName + '\'';
        }        
        
        if (state != null && state != '')
        {
            System.debug('State =' + state);
            if (strCond == '')
                strCond += 'State =  \'' + state + '\'';
            else
                strCond += ' AND State = \'' + state + '\'';
        }        
        
        //if (country.trim().toUpperCase()==RyderGlobalVariables.COUNTRIES_CANADA_TEXT)
        //    country = RyderGlobalVariables.COUNTRIES_CANADA;
         
        if (country != null && country != '')
        {
            System.debug('Country =' + country);
            if (strCond == '')
                strCond += 'Country = \'' + country + '\'';
            else
                strCond += ' AND Country = \'' + country + '\'';
        }
        
/*
    datacom given Error 
        INVALID_FIELD:
        Name FROM DatacloudCompany WHERE Street = 'Flagler'
        ^
        ERROR at Row:1:Column:54
        field 'Street' can not be filtered in query call
    I guess due to data restrictions, shown in the result as "*"
    if (street != null && street != '')
        {
            System.debug('street =' + street);
            if (strCond == '')
             strCond += 'Street = \'' + street + '\'';
            else
             strCond += ' AND Street = \'' + street + '\'';
        }
*/            
        if (city != null && city != '')
        {
            System.debug('City =' + city);
            if (strCond == '')
                strCond += 'City = \'' + city + '\'';
            else
                strCond += ' AND City = \'' + city + '\'';
        }

        //AKK 06/20/2014 - Start
        //Commented to maximize the search results
        //AKK 07/14/2014 - Start - Uncommenting as per Jose request
        
        if (zipCode != null && zipCode != '')
        {
            //Data.com search api consider 5 digit zipcode as per unit testing.
            if(country == 'US' || country == 'United States')
                zipCode = zipCode.substring(0, 5);
            
            System.debug('Zip =' + zipCode);
            strCond += ' AND Zip LIKE \'%' + zipCode + '%\'';
        }
        
        
/*        if (phone != null && phone != '')
        {
            System.debug('Phone =' + phone);
            if (strCond == '')
                strCond += 'Phone LIKE \'%' + phone + '%\'';
            else
                strCond += 'AND Phone LIKE \'%' + phone + '%\'';
        }*/
        
        System.debug('strCond : ' + strCond);

        if(strCond != '')
            strSOQL += 'WHERE ' + strCond + ' LIMIT 100'; 

        system.debug('strSQL DatacomCompany : ' + strSOQL);

        //Mocking the test as per Salesforce Datacom suggestion because Data.com cloud objects results in 
        //the issue "Could not run tests on class 01pm00000008cBZ" while running the Test class
        if(!Test.isRunningTest())        
        {
            dbDatacloudCompany = Database.query(strSOQL);
        }
        
        for(DatacloudCompany tempdcc : dbDatacloudCompany)
        {
            //System.debug('tempdcc.CompanyId, tempdcc.State : ' + tempdcc.CompanyId + ' --- ' + tempdcc.State);
            lstCompId.add(tempdcc.CompanyId);            
        }
                
            
        if (dbDatacloudCompany.size() == 0)
            lstCompId = null;

        
        return lstCompId;
    }

    //*********************************************************************************
    //This function will retreive the company information based on the company Ids.
    //The purpose of this function is get the detail information about company like DomesticUlitmateDunsNumber
    //GlobalUlitmateDunsNumber, ParentOrHqDunsNumber etc.
    //public List<DatacloudDandBCompany> getDandBCompany(List<String> pCompanyId, String street)
    //*********************************************************************************
    public static List<DatacloudDandBCompany> getDatacloudDandBCompany(List<String> pcompanyId)        
    {
        List<DatacloudDandBCompany> dcdnb = new  List<DatacloudDandBCompany>();
        if (pcompanyId != null)          
        {
            System.debug('pcompanyId IN = ' + pcompanyId);
    
            String strSOQL = 'SELECT City,CompanyId,Country,DomesticUltimateDunsNumber,DunsNumber,GeoCodeAccuracy,GlobalUltimateDunsNumber,Id,LegalStatus,LocationStatus,MailingCity,MailingCountry,MailingState,MailingStreet,MailingZip,Name,OutOfBusiness,OwnOrRent,ParentOrHqDunsNumber,Phone,PrimarySic,PrimarySicDesc,SalesVolume,State,Street,URL,Zip, TradeStyle1 FROM DatacloudDandBCompany WHERE CompanyId IN :pcompanyId LIMIT 100';
            System.debug('strSOQL IN = ' + strSOQL);
            if(!Test.isRunningTest()) 
            {
                dcdnb = database.query(strSOQL);
            }
            system.debug('datacloudD&B by companyid : ' + dcdnb.size());
            if(dcdnb.size()==0)
                dcdnb = null;
         }       
                    
        System.debug(dcdnb);

        Return dcdnb;
    }

    //*********************************************************************************
    //This function will retreive the company information based on the DunsNumber.
    //The purpose of this function is get the detail information about company like DomesticUlitmateDunsNumber
    //GlobalUlitmateDunsNumber, ParentOrHqDunsNumber etc.
    //*********************************************************************************
    public static DatacloudDandBCompany getDatacloudDandBCompany(String DunsNumber)        
    {
      
        DatacloudDandBCompany objdcdnb = new DatacloudDandBCompany();
        List<DatacloudDandBCompany> dcdnb = new  List<DatacloudDandBCompany>();

        try {
            String strSOQL = 'SELECT City,CompanyId,Country,DomesticUltimateDunsNumber,DunsNumber,GeoCodeAccuracy,GlobalUltimateDunsNumber,Id,LegalStatus,LocationStatus,MailingCity,MailingCountry,MailingState,MailingStreet,MailingZip,Name,OutOfBusiness,OwnOrRent,ParentOrHqDunsNumber,Phone,PrimarySic,PrimarySicDesc,SalesVolume,State,Street,URL,Zip, TradeStyle1 FROM DatacloudDandBCompany WHERE DunsNumber = \'' + DunsNumber + '\' LIMIT 100';
            System.debug('strSOQL IN = ' + strSOQL);
            if(!Test.isRunningTest()) 
            {
                dcdnb = database.query(strSOQL);
            }
            system.debug('datacloudD&B by DunsNumber : ' + dcdnb.size());
            if(dcdnb.size()==0)
                objdcdnb = null;
            else
            {
                objdcdnb = dcdnb.get(0);
            }
            
            System.debug(dcdnb.get(0));
            
        }catch (Exception ex) {
            System.debug('Exception = ' + ex.getMessage());
        }
        
        Return objdcdnb;
    }
    
    
    
    //*********************************************************************************
    //This function will retreive the 2 letter state from datacloudcompany because datacloudDandBCompany
    //give the full state Name which is not acceptable by FMS SFDC
    //*********************************************************************************
    public static String getDatacloudstateCode(String companyId)       
    {
      
        String state = null;
        List<DatacloudCompany> ldatacloudcompany = new List<DatacloudCompany>();
        try {
            String strSOQL = 'SELECT State FROM DatacloudCompany WHERE CompanyId = \'' + companyId + '\' LIMIT 100';
            System.debug('strSOQL IN = ' + strSOQL);
            if (!Test.isRunningTest())
            {
                ldatacloudcompany = database.query(strSOQL);
            }
            system.debug('ldatacloudcompany : ' + ldatacloudcompany);
            if(ldatacloudcompany!=null)
                state = ldatacloudcompany.get(0).state;
            
        }catch (Exception ex) {
            System.debug('Exception = ' + ex.getMessage());
        }
        
        Return state;
    }
    
    //*********************************************************************************
    //This function will retreive customer location type based on the location status
    //0=Single Location, 1=Headquarters, 2=Branch
    //*********************************************************************************
    public static String getLocationType(String LocationStatus)
    {
        String sResult = '';
        
        if(LocationStatus == '0')
            sResult = 'Single Location';
        if(LocationStatus == '1')
            sResult = 'Headquarters';
        if(LocationStatus == '2')
            sResult = 'Branch'; 
            
         System.debug('LocationType : ' + sResult);
            
        return sResult;     
    }
        
        
}