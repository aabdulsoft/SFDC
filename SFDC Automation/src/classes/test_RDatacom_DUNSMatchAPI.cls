@isTest(SeeAllData=true)
private class test_RDatacom_DUNSMatchAPI
{

    static testMethod void test_getCompany()
    {
        DBAccount dba = new DBAccount();
        List<DBAccount> lstdba = RDatacom_DUNSMatchAPI.getCompany('ABC', 'FL', 'US', '8th Street', 'Miami', '33196', '3054005555' );
        System.debug('test lstdba : ' + lstdba);
        dba = lstdba.get(0);
        System.assertEquals(true, dba.City=='Miami');
    }
    
    static testMethod void test_getCompanyCA()
    {
        DBAccount dba = new DBAccount();
        List<DBAccount> lstdba = RDatacom_DUNSMatchAPI.getCompany('ABC', 'FL', 'CA', '8th Street', 'Miami','33196', '3054005555' );
        System.debug('test lstdba : ' + lstdba);
        dba = lstdba.get(0);
        System.assertEquals(true, dba.City=='Miami');
    }
    
}