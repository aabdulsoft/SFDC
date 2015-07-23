@isTest
public with sharing class test_GetRebillableRates {
    
    static testMethod void validateRebillableRates() {
        
        GetRebillableRates.ProcessRequestResponse_element prr = new GetRebillableRates.ProcessRequestResponse_element();
        GetRebillableRates.DCRebillableRate fr = new GetRebillableRates.DCRebillableRate();
        fr.CurrencyIsoCode  = 'test';
       
        GetRebillableRates.CRMCredential cc = new GetRebillableRates.CRMCredential();
        cc.Password = '';
        cc.SecurityToken = '';
        cc.UserName = '';
        
        GetRebillableRates.RebillableRateRequestCriteria rsrc = new GetRebillableRates.RebillableRateRequestCriteria();
        rsrc.VehicleNo = '12345';       
    }
}