public with sharing class Insurance {

    public String libabilityInsuranceProvider {get; set;}
    public String physicalDamageResponsibility {get; set;}
    public Decimal libabilityInsuranceDeductible {get; set;}
    public Decimal physicalDamageDeductible {get; set;}
    public Date expirationDate {get; set;}
    public Decimal combinedSingleLimit {get; set;}
    
	static testMethod void test_Insurance() {
        Insurance ins = new Insurance();
        ins.combinedSingleLimit = 1.0;
        ins.expirationDate = date.today();
        ins.libabilityInsuranceDeductible = 1.0;
        ins.libabilityInsuranceProvider = '';
        ins.physicalDamageDeductible = 1.0;
        ins.physicalDamageResponsibility = '';
        
        system.assertEquals(ins.combinedSingleLimit, 1.0);
        system.assertEquals(ins.expirationDate, Date.today());
        system.assertEquals(ins.libabilityInsuranceDeductible, 1.0);
        system.assertEquals(ins.libabilityInsuranceProvider, '');
        system.assertEquals(ins.physicalDamageDeductible, 1.0);
        system.assertEquals(ins.physicalDamageResponsibility, '');
    }
}