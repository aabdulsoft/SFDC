@isTest
public with sharing class test_getCompanies{

    static testMethod void validateCompanies() {
        
        getCompanies.ProcessRequestResponse_element prr = new getCompanies.ProcessRequestResponse_element();
        getCompanies.DCCompanies cms = new getCompanies.DCCompanies();
        getCompanies.DCCompany cmy = new getCompanies.DCCompany();     
        getCompanies.DCDealSummary ds = new getCompanies.DCDealSummary();
        getCompanies.DCRateSheet rs = new getCompanies.DCRateSheet();        
        getCompanies.ArrayOfDCCompany acy = new getCompanies.ArrayOfDCCompany();
        getCompanies.ArrayOfDCDealSummary ads = new getCompanies.ArrayOfDCDealSummary();
        getCompanies.ArrayOfDCRateSheet ars = new getCompanies.ArrayOfDCRateSheet();
        
        acy.DCCompany = new getCompanies.DCCompany[1];
        ads.DCDealSummary = new getCompanies.DCDealSummary[1];
        ars.DCRateSheet = new getCompanies.DCRateSheet[1];                
        
        getCompanies.CRMCredential cc = new getCompanies.CRMCredential();
        cc.Password = '';
        cc.SecurityToken = '';
        cc.UserName = '';
        
        getCompanies.CompanyRequestCriteria crc = new getCompanies.CompanyRequestCriteria();
        crc.CompanyId = 12345;   
    }
}