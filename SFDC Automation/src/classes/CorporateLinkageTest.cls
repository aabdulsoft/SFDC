/*******************************************************************
Name  : CorporateLinkageTest
Author: Hari Krishnan (Appirio)
Date  : February 28, 2015
Discription: Test Class for the  class CorporateLinkageTest
*************************************************************************/
@isTest(seealldata = true)
private class CorporateLinkageTest {
    static testMethod void testCorporateLinkage() {
        CorporateLinkage cl = new CorporateLinkage();
        cl.dunsNumber = 'aa';
        cl.enqDunsNumber = 'aa';
        cl.primaryName = 'aa';
        cl.branchIndicator = 'aa';
        cl.businessStructure = 'aa';
        cl.locationStatus = 'aa';
        cl.countryCode = 'aa';
        cl.siteName = 'aa';
        cl.siteDUNS = 'aa';
        cl.siteCountry = 'aa';
        cl.hqDUNS = 'aa';
        cl.hqName = 'aa';
        cl.hqCountry = 'aa';
        cl.domesticUltimateName = 'aa';
        cl.domesticUltimateDUNS = 'aa';
        cl.domesticUltimateCountry = 'aa';
        cl.globalUltimateName = 'aa';
        cl.globalUltimateDUNS = 'aa';
        cl.globalUltimateCountry = 'aa';
        cl.hasCorporateLinkage = true;
    }
}