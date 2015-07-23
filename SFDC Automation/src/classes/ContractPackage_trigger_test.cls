@isTest
public class ContractPackage_trigger_test {

    

    static testMethod void getOpportunityId() {
    
        ContractPackage__c testCntPkg = new ContractPackage__c(Cs_no__c = '0008891456', Id='a0n60000002dRnV');
        update testCntPkg;
    
        Map<String, String> rateSheet = new Map<String, String>();
        rateSheet.put(String.ValueOf(12345), '000615784236');
        
    }
}