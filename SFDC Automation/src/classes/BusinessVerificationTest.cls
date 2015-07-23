/*******************************************************************
Name  : BusinessVerificationTest
Author: Hari Krishnan Appirio)
Date  : February 28, 2015
Discription: Test Class for the class BusinessVerification
*************************************************************************/
@isTest(seealldata = true)
private class BusinessVerificationTest {
    static testMethod void testBusinessVerification() {
        BusinessVerification bv = new BusinessVerification();
        bv.dunsNumber = 'aa';
        bv.primaryName = 'aa';
        bv.addressLine = 'aa';
        bv.postalTown = 'aa';
        bv.stateProvince = 'aa';
        bv.postalCode = 'aa';
        bv.countryCode = 'aa';
        bv.branchIndicator = 'aa';
        bv.businessStructure = 'aa';
        bv.locationStatus = 'aa';
        bv.siteName = 'aa';
        bv.siteDUNS = 'aa';
        bv.siteCountry = 'aa';
        bv.domesticUltimateName = 'aa';
        bv.globalUltimateName = 'aa';
        bv.globalUltimateDUNS = 'aa';
        bv.globalUltimateCountry = 'aa';
        bv.hqDUNSName = 'aa';
        bv.hqDUNS = 'aa';
        bv.hqDUNSCountry = 'aa';
        bv.sicCode = 'aa';
        bv.sicTypeCode = 'aa';
        bv.hasBusinessVerication = true;
        bv.outOfBusiness = 'aa';
        
    }
}