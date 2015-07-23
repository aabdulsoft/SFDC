@isTest(SeeAllData=true)
private class test_RDatacom_SearchAPI
{

    static testMethod void test_getCompany()
    {
        DBAccount dba = new DBAccount();
        List<DBAccount> lstdba = RDatacom_SearchAPI.getCompany(null, null, null, null, null, null, null);
		System.debug('test lstdba : ' + lstdba);
        dba = lstdba.get(0);
        System.assertEquals(true, dba.City=='Miami');
    }
    
    static testMethod void test_getDatacloudCompany()
    {
        List<String> lststr = RDatacom_SearchAPI.getDatacloudCompany('Metro Food Distributors, Inc', null, null, null, null, null, null);
		System.assertEquals(true, lststr == null);
    }

    static testMethod void test_getDatacloudCompanyState()
    {
        List<String> lststr = RDatacom_SearchAPI.getDatacloudCompany(null, 'FL', null, null, null, null, null);
		System.assertEquals(true, lststr == null);
    }

    static testMethod void test_getDatacloudCompanyCity()
    {
        List<String> lststr = RDatacom_SearchAPI.getDatacloudCompany(null, null, null, null, 'Miami', null, null);
		System.assertEquals(true, lststr == null);
    }
    
    static testMethod void test_getDatacloudCompanyCountry()
    {
        List<String> lststr = RDatacom_SearchAPI.getDatacloudCompany(null, null, 'US', null, null, null, null);
		System.assertEquals(true, lststr == null);
    }

    static testMethod void test_getDatacloudCompanyZipCountry()
    {
        List<String> lststr = RDatacom_SearchAPI.getDatacloudCompany(null, null, 'US', null, null, '75070', null);
		System.assertEquals(true, lststr == null);
    }
    
    static testMethod void test_getDatacloudCompanyData()
    {
        List<String> lststr = RDatacom_SearchAPI.getDatacloudCompany('Metro Food Distributors, Inc', 'NJ', 'US', null, 'Miami', null, '19543265789');
		System.assertEquals(true, lststr == null);
    }

    //unit test case with list of companyid 
    static testMethod void test_getDatacloudDandBCompany()
    {
        List<String> lstinp = new List<String>();
        lstinp.add('20');
        List<DatacloudDandBCompany> lstdnb = RDatacom_SearchAPI.getDatacloudDandBCompany(lstinp);
		System.assertEquals(true, lstdnb==null);
    }
    
   
    static testMethod void test_getDatacloudDandBCompanyforDuns()
    {

        DatacloudDandBCompany dnb = RDatacom_SearchAPI.getDatacloudDandBCompany('927284505');
		System.assertEquals(true, dnb==null);
    }
    
    static testMethod void test_getDatacloudstateCode()
    {
        String strState = RDatacom_SearchAPI.getDatacloudstateCode(null);
		System.assertEquals(null, strState);
    }
    
    static testMethod void test_getgetLocationTypeSL()
    {
        String strlocationtype = RDatacom_SearchAPI.getLocationType('0');
		System.assertEquals('Single Location', strlocationtype);
    }

    static testMethod void test_getgetLocationTypeHQ()
    {
        String strlocationtype = RDatacom_SearchAPI.getLocationType('1');
		System.assertEquals('Headquarters', strlocationtype);
    }

    static testMethod void test_getgetLocationTypBR()
    {
        String strlocationtype = RDatacom_SearchAPI.getLocationType('2');
		System.assertEquals('Branch', strlocationtype);
    }
    
}