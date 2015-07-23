trigger ContractPackage on ContractPackage__c (after insert, after update) {

    //#624 - Albert M. 10/28/2014 : Relate Vehicle to Opportunity
    //       Add opportunity id to Vehicle object when new contract package is created
        
    Set<Id> contractPackageIds = new Set<Id>();
    Set<Decimal> rateSheetIds = new Set<Decimal>();
    
    //Get all Id's to avoid governor limits
    for(ContractPackage__c cpIds : trigger.new)
    {
        try{
            contractPackageIds.add(cpIds.Id);
            rateSheetIds.add(Decimal.ValueOf(cpIds.cs_no__c)); //rate sheet numbers are the only way to link to the opportunity from the contract package
        } catch(Exception ex) {
            
        }
    }
    
    if(rateSheetIds.size() > 0) 
    {
        Map<String, String> rateSheet = getOpportunityId(rateSheetIds); //Get the opportunity id's to relate to the vehicle of this contract package 
    
    	////QC #759 - 1/27/2015 - Set list of transaction types.
    	Set<String> transType = new Set<String>();
    	transType.add('11');
		transType.add('12');
		transType.add('13');
		transType.add('16');
    	
        for (ContractPackage__c contPkg : trigger.new){ 
        	
        	//QC #759 - 1/27/2015 - Added Transaction Type filter
        	if(!transType.contains(contPkg.TRAN_TYP_CD__c)){
            
	            if(trigger.isAfter && trigger.isInsert){
	                string opportunityId = rateSheet.get(String.ValueOf(Integer.ValueOf(contPkg.cs_no__c))); //use cs_no__c to get the opportunity id from the mapped rate sheet
	                updateVehicle(opportunityId, contPkg.Vehicle__c); //update the current vehicle to the opportunity
	            }       
	            //update Vehicle object when contract is updated
	            if(trigger.isAfter && trigger.isUpdate){
	                
	                string opportunityId = rateSheet.get(String.ValueOf(Integer.ValueOf(contPkg.cs_no__c))); //use cs_no__c to get the opportunity id from the mapped rate sheet
	                
	                ContractPackage__c oldContPkg = Trigger.oldMap.get(contPkg.Id);
	                if(oldContPkg.Vehicle__c != contPkg.Vehicle__c){
	                    // update old vehicle record if vehicle is changed on the contract package
	                    updateVehicle(null, oldContPkg.Vehicle__c); 
	                }
	                
	                updateVehicle(opportunityId, contPkg.Vehicle__c); //update vehicle record with new opportunity id
	            }   
        	}
            
        }
    }
    public static Map<String, String> getOpportunityId(Set<Decimal> rsIds) { 
        
        //Query the rate sheet object to get all associated opportunity id's
        List<Rate_Sheet__c> rateSheetList = [Select ext_ratesheet_id__c, Opportunity__c
                                               From Rate_Sheet__c Where 
                                               ext_ratesheet_id__c in : rsIds];
        
        Map<String, String> rateSheet = new Map<String, String>(); //Map the rate sheet records to avoid governor limits
        //Map by string in order to use for the get. The .get will use the ext_ratesheet_id__c as the id to match the contract package.
        for (Rate_Sheet__c r : rateSheetList) {
            rateSheet.put(String.ValueOf(r.ext_ratesheet_id__c), r.Opportunity__c);
        }
        return rateSheet;
    }
    
    public static void updateVehicle(string opportunityId, string vehicleId){
        //Update the vehicle object/record with the Opportunity Id. 
        //This will create the relation/link between the vehicle and current opportunity it is associated with.
        Vehicle__c v = new Vehicle__c();
        v.Id = vehicleId;
        v.Opportunity__c = opportunityId;
        update v;
    }
    

    

}