/**=====================================================================
 * Appirio, Inc
 * Class Name: OpptyTypeRouterController
 * Description: T-319456 : Route to standard/custom add product page based on the Opp record type ()
 * Created Date: 09/15/2014
 * Created By: [Manisha Gupta] (Appirio)
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 =====================================================================*/
public class OpptyTypeRouterController {

    private Opportunity opp;
    public OpptyTypeRouterController(ApexPages.StandardController sc){
    	// 09/20/2014 : NP : Added for Test Coverage
    	if(!Test.isRunningTest()){
    		sc.addFields(new List<String>{'RecordTypeId', 'Id'});
    	}
        opp = (Opportunity)sc.getRecord();

    }

	// RA: Please provide comments
    public PageReference redirectToAddProduct(){
        System.debug('$$$: OpptyTypeRouterController.redirectToAddProduct(): Entered');
        // get UVS Record type of opportunity
        Id uvsRTId = UVS_Util.UVSRecordType_Opp;
        // check if Opportunity Record Type is UVS
        // if Yes, redirect to custom add product
        // if No, redirect to standard add product
        if(uvsRTId <> null && opp.RecordTypeId == uvsRTId){
            System.debug('$$$: OpptyTypeRouterController.redirectToAddProduct(): Opp Type is UVS');
            return new Pagereference('/apex/AddProductsCustom?oppId='+opp.Id);
        }else{
            System.debug('$$$: OpptyTypeRouterController.redirectToAddProduct(): Opp Type is NOT UVS');
            return new Pagereference('/p/opp/SelectSearch?addTo='+opp.Id+'&retURL=/'+opp.Id + '&nooverride=1');
        }
        return null;
    }
}