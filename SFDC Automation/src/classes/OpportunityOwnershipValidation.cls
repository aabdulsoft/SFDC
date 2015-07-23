public with sharing class OpportunityOwnershipValidation {

    public static void CreateCasesForValidOwnership(Map<Id, Opportunity> mapOld, Map<Id, Opportunity> mapNew){
        
        for (Opportunity oppty : mapNew.values()){
        
            // Check if any of the below information has changed
            if(oppty.StageName == 'Booked') {
    
                if(oppty.Customer_100_Ownership__c == 'Yes'){
                    
                    try{
                        // Check if a case already exists
                        RecordType recType = [Select Id from RecordType where Name =:'Ownership Validations'];
                        List<Case> cCase = [Select Id from Case where Opportunity_Case__c = :oppty.Id and RecordTypeId =:recType.Id];
                        
                        if(cCase.isEmpty() || cCase.size() == 0){
                            
                            //Get Oppty Owner Name
                            User u = [Select Name from User where Id = :oppty.OwnerId];
                            //Get Queue Id to assign as the Owner of the Case
                            Group queue = [Select Id FROM Group WHERE Name = 'Ownership Validations' AND Type = 'Queue'];
                            
                            //Get Oppty Decision Maker
                            String origDecisionMaker = '';
                            Contact origDecMakerContact = null;
                            
                            //Assign the Original Decision Maker 
                            if(oppty.Original_Decision_Maker__c == null){
                                //Check if there is a Parent Id in Account
                                Account parentAccount = [SELECT ParentId FROM Account WHERE Id = :oppty.AccountId];
                                if(parentAccount.ParentId == null){
                                    //If there is no ParentId then use the oppty AccountId
                                    origDecMakerContact = [SELECT Name FROM Contact WHERE AccountId = :oppty.AccountId AND STATUS_ACTIVE__c = true LIMIT 1];
                                    origDecisionMaker = origDecMakerContact.Name;
                                }else{
                                    origDecMakerContact = [SELECT Name FROM Contact WHERE AccountId = :parentAccount.ParentId AND STATUS_ACTIVE__c = true LIMIT 1];
                                    origDecisionMaker = origDecMakerContact.Name;
                                }
                            }else{
                                //There is an Original Decision Maker in the opportunity
                                origDecMakerContact = [SELECT Name FROM Contact WHERE Id = :oppty.Original_Decision_Maker__c AND STATUS_ACTIVE__c = true LIMIT 1];
                                origDecisionMaker = origDecMakerContact.Name;
                            }
                        
                            //No case exists, create a new one
                            Case newCase = new Case();
                            newCase.AccountId = oppty.AccountId; 
                            newCase.Status = 'New';
                            newCase.Opportunity_Owner__c = u.Name;
                            newCase.Opportunity_Case__c = oppty.Id;
                            newCase.Opportunity_Close_Date__c = oppty.Actual_Close_Date__c;
                            newCase.Opportunity_Number__c = oppty.ext_pipeline_id__c;
                            newCase.RecordTypeId = recType.Id;
                            newCase.OwnerId = queue.Id; //Case is assigned to a Queue
                            newCase.Original_Decision_Maker__c = origDecisionMaker;
                            insert newCase;
                        }
                        
                    }
                    catch (Exception ex){
                        system.debug(LoggingLevel.ERROR, 'aaaaaaaaa Message: ' + ex.getMessage());    
                        system.debug(LoggingLevel.ERROR, 'aaaaaaaaa Cause: ' + ex.getCause());    
                        system.debug(LoggingLevel.ERROR, 'aaaaaaaaa Line number: ' + ex.getLineNumber());
                    }
                }
            }
        }
    }

}