/**=====================================================================
Created By:     Rahul Agrawal
Date:           Jan 03, 2015
Description  :  Test Class for CreateSAMCompany Class
 =====================================================================*/
@isTest(seeAllData = true)
private class CreateSAMCompanyTest {

    static testMethod void unitTestCreateSAMCompany() {

        CreateSAMCompany.RequestData rd = new CreateSAMCompany.RequestData();
        CreateSAMCompany.ArrayOfDCSAMCompanyAddress add = new CreateSAMCompany.ArrayOfDCSAMCompanyAddress();
        CreateSAMCompany.ProcessRequest_element pre = new CreateSAMCompany.ProcessRequest_element();
        CreateSAMCompany.ArrayOfDCSAMCompanyPhone ph = new CreateSAMCompany.ArrayOfDCSAMCompanyPhone();
        CreateSAMCompany.ResponseData rd1 = new CreateSAMCompany.ResponseData();
        CreateSAMCompany.DCSAMCompanyCallInfo ci = new CreateSAMCompany.DCSAMCompanyCallInfo();
        CreateSAMCompany.DCSAMCompanyAccount ca = new CreateSAMCompany.DCSAMCompanyAccount();
        CreateSAMCompany.ArrayOfDCSAMCompanyContact cc = new CreateSAMCompany.ArrayOfDCSAMCompanyContact();
        CreateSAMCompany.CRMCredential cred = new CreateSAMCompany.CRMCredential();
        CreateSAMCompany.ProcessRequestResponse_element prre = new CreateSAMCompany.ProcessRequestResponse_element();
        CreateSAMCompany.SAMCompanyCollectionRequestCriteria reqCrit = new CreateSAMCompany.SAMCompanyCollectionRequestCriteria();
        CreateSAMCompany.DCSAMCompanyContact cc1 = new CreateSAMCompany.DCSAMCompanyContact();
        CreateSAMCompany.DCSAMCompanyAddress cAdd = new CreateSAMCompany.DCSAMCompanyAddress();
        CreateSAMCompany.DCSAMCompanyPhone cPh = new CreateSAMCompany.DCSAMCompanyPhone();
        CreateSAMCompany.DCSAMCompanyCollection cc2 = new CreateSAMCompany.DCSAMCompanyCollection();
        CreateSAMCompany.CreateSAMCompanySoap cSoap = new CreateSAMCompany.CreateSAMCompanySoap();

    }

    static testMethod void unitTestSAMResponcse(){

    	SAMResponse sr = new SAMResponse();
    	sr.put('NEW_ACCOUNT_BSNP', '1');
    	sr.put('BSNP_ID', '1');
    	sr.put('CUST_NO', '1');
    	sr.put('Name', '1');
    	sr.put('Location', '1');
    	sr.put('Phone', '1');
    	sr.put('EmailAddress', '1');
    	sr.put('ContactName', '1');
    	sr.put('errorCode', '1');
    	sr.put('errorMessage', '1');

    	System.assertEquals(1, sr.listPotentialDuplicates.size());
    	System.assertEquals(1, sr.lstError.size());

    	sr = new SAMResponse();
    	sr.put('BSNP_ID', '1');
    	sr = new SAMResponse();
    	sr.put('CUST_NO', '1');
    	sr = new SAMResponse();
    	sr.put('Name', '1');
    	sr = new SAMResponse();
    	sr.put('Location', '1');
    	sr = new SAMResponse();
    	sr.put('Phone', '1');
    	sr = new SAMResponse();
    	sr.put('EmailAddress', '1');
    	sr = new SAMResponse();
    	sr.put('ContactName', '1');
    	sr = new SAMResponse();
    	sr.put('errorCode', '1');
    	sr = new SAMResponse();
    	sr.put('errorMessage', '1');
    }
}