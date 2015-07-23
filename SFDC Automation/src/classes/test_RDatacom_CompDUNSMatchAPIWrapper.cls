@isTest(SeeAllData=true)
private class test_RDatacom_CompDUNSMatchAPIWrapper {
    
    static testMethod void testbuildrequest()
    {
        RDatacom_CompanyDUNSMatchAPIWrapper wrapper = new RDatacom_CompanyDUNSMatchAPIWrapper();
        
        RDatacom_Company tempcomp = new RDatacom_Company();
        tempcomp.CompanyName = 'ABC';
        tempcomp.state = 'FL';
        tempcomp.city = 'Miami';
        tempcomp.country = 'US';
        tempcomp.Phone = '3055000000';
        tempcomp.street = '8th Street';
        tempcomp.zipCode = '333178';
        
        String str = wrapper.buildRequest(tempcomp);           
        wrapper.GenerateResponse('', str);
        
        RDatacom_Errors error = wrapper.error;
        Integer size = wrapper.size;
        
    }
    
    static testMethod void testfieldDiffsinst()
    {
        RDatacom_fieldDiffs rdfielddiff = new RDatacom_fieldDiffs();
        rdfielddiff.difference = '';
        rdfielddiff.name = '';        
      
    }
    
    static testMethod void testErrorinst()
    {
        RDatacom_Errors err = new RDatacom_Errors();
        err.message = '';
        err.statusCode = '';
      
    }    
    
    
}