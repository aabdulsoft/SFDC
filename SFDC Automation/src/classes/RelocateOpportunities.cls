public virtual without sharing class RelocateOpportunities {

    //Create new opportunities from data collected in Partial Win object
    public static List<PartialWinRateSheet__c> CreateOpportunityFromPartialWin(String oldOppId){
        
        PartialWinRateSheet__c partialWinValue = new PartialWinRateSheet__c();
        List<PartialWinRateSheet__c> partialWinResultFinal = new List<PartialWinRateSheet__c>();
        List<PartialWinRateSheet__c> partialWinResult_Lost = new List<PartialWinRateSheet__c>();
        List<PartialWinRateSheet__c> partialWinResult_OpenBusiness = new List<PartialWinRateSheet__c>();
        List<PartialWinRateSheet__c> partialWinResult_WonBusinessNext = new List<PartialWinRateSheet__c>();
        List<PartialWinRateSheet__c> partialWinResult_WonBusinessThis = new List<PartialWinRateSheet__c>();
        Opportunity newOpptyLost = new Opportunity();
        Opportunity newOpptyOpenB = new Opportunity();
        Opportunity newOpptyWonBusNext = new Opportunity();
        Opportunity newOpptyWonBusThis = new Opportunity();
        
        Integer i = 0;
        Integer j = 0;
        Integer k = 0;
        Integer m = 0;
        Integer r = 0;
        Integer w = 0;
        Integer x = 0;
        
        String origDecisionMaker = '';
        Contact origDecMakerContact = null;
                
        //Old Opportunity
        Opportunity oldOppResult = [Select Name, AccountId, OwnerId, Original_Decision_Maker__c, StageName, Estimated_Proposal_Date__c, CloseDate, Actual_Close_Date__c, Assign_To__c  From Opportunity where id = :oldOppId];
        System.debug('aaaaaaa oldOppResult: ' + oldOppResult );
        
        //Assign the Original Decision Maker 
        if(oldOppResult.Original_Decision_Maker__c == null){
            
            //Check if there is a Parent Id in Account
            Account parentAccount = [SELECT ParentId FROM Account WHERE Id = :oldOppResult.AccountId];
            
            if(parentAccount.ParentId == null){
                
                //If there is no ParentId then use the oppty AccountId
                origDecMakerContact = [SELECT Id FROM Contact WHERE AccountId = :oldOppResult.AccountId AND STATUS_ACTIVE__c = true LIMIT 1];
                origDecisionMaker = origDecMakerContact.Id;
                
            }else{
                
                origDecMakerContact = [SELECT Id FROM Contact WHERE AccountId = :parentAccount.ParentId AND STATUS_ACTIVE__c = true LIMIT 1];
                origDecisionMaker = origDecMakerContact.Id;
            }
            
        }else{
            //There is an Original Decision Maker in the opportunity
            origDecisionMaker = oldOppResult.Original_Decision_Maker__c; 
        }
        System.debug('aaaaaaa odm: ' + origDecisionMaker );
        
        
        //Get current Partial Win 
        List<PartialWinRateSheet__c> partialWinList = [Select pwr.Id,
                                                        pwr.Rate_Sheet__c,
                                                        pwr.Deal_Summary__c,
                                                        pwr.Status__c,
                                                        pwr.Reason_Won_Lost__c,
                                                        pwr.Deal_lost_to_Won_from_whom__c,
                                                        pwr.Competitor__c,
                                                        pwr.Was_this_competitor_the_incumbent__c,
                                                        pwr.Local_Provider_Name__c,
                                                        pwr.Opportunity__c
                                                    From PartialWinRateSheet__c pwr where pwr.Opportunity__c = :oldOppId];

        System.debug('aaaaaaa partial win list: ' + partialWinList );
        
        //split results into 'Lost', 'Open Business', 'Won Business about to book next month' and 'Won Business about to book this month' lists
        for(PartialWinRateSheet__c pwr : partialWinList){
            if(partialWinList[i].Status__c == 'Lost'){
                System.debug('aaaaaaa LOST');  
                PartialWinRateSheet__c partialWinValueLST = new PartialWinRateSheet__c();
                partialWinValueLST.Rate_Sheet__c = partialWinList[i].Rate_Sheet__c;
                partialWinValueLST.Deal_Summary__c = partialWinList[i].Deal_Summary__c;
                partialWinValueLST.Reason_Won_Lost__c = partialWinList[i].Reason_Won_Lost__c;
                partialWinValueLST.Deal_lost_to_Won_from_whom__c = partialWinList[i].Deal_lost_to_Won_from_whom__c;
                partialWinValueLST.Competitor__c = partialWinList[i].Competitor__c;
                partialWinValueLST.Was_this_competitor_the_incumbent__c = partialWinList[i].Was_this_competitor_the_incumbent__c;
                partialWinValueLST.Local_Provider_Name__c = partialWinList[i].Local_Provider_Name__c;
                partialWinResult_Lost.add(partialWinValueLST);
                    
            }else if(partialWinList[i].Status__c == 'Open Business'){
                System.debug('aaaaaaa OPEN');            
                PartialWinRateSheet__c partialWinValueOB = new PartialWinRateSheet__c();
                partialWinValueOB.Rate_Sheet__c = partialWinList[i].Rate_Sheet__c;
                partialWinValueOB.Deal_Summary__c = partialWinList[i].Deal_Summary__c;
                partialWinResult_OpenBusiness.add(partialWinValueOB);
                
            }else if(partialWinList[i].Status__c == 'Won Business about to book next month'){
                System.debug('aaaaaaa WON NEXT');            
                PartialWinRateSheet__c partialWinValueWBNext = new PartialWinRateSheet__c();
                partialWinValueWBNext.Rate_Sheet__c = partialWinList[i].Rate_Sheet__c;
                partialWinValueWBNext.Deal_Summary__c = partialWinList[i].Deal_Summary__c;
                partialWinResult_WonBusinessNext.add(partialWinValueWBNext);
            }else if(partialWinList[i].Status__c == 'Won Business about to book this month'){
                System.debug('aaaaaaa WON THIS');            
                PartialWinRateSheet__c partialWinValueWBThis = new PartialWinRateSheet__c();
                partialWinValueWBThis.Rate_Sheet__c = partialWinList[i].Rate_Sheet__c;
                partialWinValueWBThis.Deal_Summary__c = partialWinList[i].Deal_Summary__c;
                partialWinResult_WonBusinessThis.add(partialWinValueWBThis);
            }
            i++;            
        }
        
        System.debug('aaaaaaa partial win lost: ' + partialWinResult_Lost );
        System.debug('aaaaaaa partial win open b: ' + partialWinResult_OpenBusiness);
        System.debug('aaaaaaa partial win won b next: ' + partialWinResult_WonBusinessNext);
        System.debug('aaaaaaa partial win won b this: ' + partialWinResult_WonBusinessThis);
        
        //Create new opportunities
        if(partialWinResult_Lost.size() > 0){
            
            newOpptyLost = CreateOpportunity(
                                        oldOppId,
                                        oldOppResult.Name, 
                                        'Lost', 
                                        oldOppResult.AccountId, 
                                        oldOppResult.OwnerId, 
                                        origDecisionMaker,
                                        oldOppResult.Estimated_Proposal_Date__c,
                                        partialWinResult_Lost[0].Reason_Won_Lost__c, 
                                        partialWinResult_Lost[0].Deal_lost_to_Won_from_whom__c, 
                                        partialWinResult_Lost[0].Competitor__c, 
                                        partialWinResult_Lost[0].Was_this_competitor_the_incumbent__c, 
                                        partialWinResult_Lost[0].Local_Provider_Name__c,
                                        oldOppResult.CloseDate,
                                        oldOppResult.Actual_Close_Date__c,
                                        oldOppResult.Assign_To__c
                                        );
            System.debug('aaaaaaa CreateOpportunity() Lost result: ' + newOpptyLost );
            System.debug('aaaaaaa CreateOpportunity() auto num result: ' + newOpptyLost.PipelineIDGenerator__c + ' - ' +  newOpptyLost.ext_pipeline_id__c);
                
            //Replace old opportunity id with the newly created opportunity id
            for(PartialWinRateSheet__c pwr : partialWinResult_Lost){
                partialWinResult_Lost[k].Opportunity__c = newOpptyLost.Id;
                partialWinResult_Lost[k].Name = newOpptyLost.Name;
                k++;
            }

            partialWinResultFinal.addall(partialWinResult_Lost);         
        }
        
        if(partialWinResult_OpenBusiness.size() > 0){
            
            //Create a new 'Open Business' opportunity
            newOpptyOpenB = CreateOpportunity(oldOppId, oldOppResult.Name, 'Overcome Concerns', oldOppResult.AccountId, oldOppResult.OwnerId, origDecisionMaker, System.today().addMonths(2).toStartOfMonth() - 1,null,null,null,null,null,null,null, oldOppResult.Assign_To__c);
            System.debug('aaaaaaa CreateOpportunity() Open Business result: ' + newOpptyOpenB );
            System.debug('aaaaaaa CreateOpportunity() auto num result: ' + newOpptyOpenB.PipelineIDGenerator__c + ' - ' +  newOpptyOpenB.ext_pipeline_id__c);
            
            //Replace old opportunity id with the newly created opportunity id
            for(PartialWinRateSheet__c pwr : partialWinResult_OpenBusiness){
                partialWinResult_OpenBusiness[m].Opportunity__c = newOpptyOpenB.Id;
                partialWinResult_OpenBusiness[m].Name = newOpptyOpenB.Name;
                m++;
            }
            
            partialWinResultFinal.addall(partialWinResult_OpenBusiness);
        }
        
        if(partialWinResult_WonBusinessNext.size() > 0){
            
            //Create a new 'Won Business about to book next month' opportunity
            newOpptyWonBusNext = CreateOpportunity(oldOppId, oldOppResult.Name, 'Signed', oldOppResult.AccountId, oldOppResult.OwnerId, origDecisionMaker, System.today().addMonths(2).toStartOfMonth() - 1,null,null,null,null,null,null,null, oldOppResult.Assign_To__c);
            System.debug('aaaaaaa CreateOpportunity() Won Business about to book next month result: ' + newOpptyWonBusNext );
            System.debug('aaaaaaa CreateOpportunity() auto num result: ' + newOpptyWonBusNext.PipelineIDGenerator__c + ' - ' +  newOpptyWonBusNext.ext_pipeline_id__c);
            
            //Replace old opportunity id with the newly created opportunity id
            for(PartialWinRateSheet__c pwr : partialWinResult_WonBusinessNext){
                partialWinResult_WonBusinessNext[w].Opportunity__c = newOpptyWonBusNext.Id;
                partialWinResult_WonBusinessNext[w].Name = newOpptyWonBusNext.Name;
                w++;
            }
            System.debug('aaaaaaa CreateOpportunity add all 1: ' + partialWinResult_WonBusinessNext);
            partialWinResultFinal.addall(partialWinResult_WonBusinessNext);
            System.debug('aaaaaaa CreateOpportunity add all 2: ' + partialWinResultFinal);            
        }  
        
        if(partialWinResult_WonBusinessThis.size() > 0){
            
            //Create a new 'Won Business about to book this month' opportunity
            newOpptyWonBusThis = CreateOpportunity(oldOppId, oldOppResult.Name, 'Signed', oldOppResult.AccountId, oldOppResult.OwnerId, origDecisionMaker, System.today().addMonths(1).toStartOfMonth() - 1,null,null,null,null,null,null,null, oldOppResult.Assign_To__c);
            System.debug('aaaaaaa CreateOpportunity() Won Business about to book this month result: ' + newOpptyWonBusThis );
            System.debug('aaaaaaa CreateOpportunity() auto num result: ' + newOpptyWonBusThis.PipelineIDGenerator__c + ' - ' +  newOpptyWonBusThis.ext_pipeline_id__c);
            
            //Replace old opportunity id with the newly created opportunity id
            for(PartialWinRateSheet__c pwr : partialWinResult_WonBusinessThis){
                partialWinResult_WonBusinessThis[x].Opportunity__c = newOpptyWonBusThis.Id;
                partialWinResult_WonBusinessThis[x].Name = newOpptyWonBusThis.Name;
                x++;
            }
            System.debug('aaaaaaa CreateOpportunity add all 1: ' + partialWinResult_WonBusinessThis);
            partialWinResultFinal.addall(partialWinResult_WonBusinessThis);
            System.debug('aaaaaaa CreateOpportunity add all 2: ' + partialWinResultFinal);            
        }  
                        
        //Update partial win records to 'Is Processed'
        UpdatePartialWin(partialWinList[0].Opportunity__c);
        
        System.debug('aaaaaaa partialWinResultFinal all: ' + partialWinResultFinal );
                
        return partialWinResultFinal;
    }

    public static Opportunity CreateOpportunity(String oldOppId, String oppName, String stageName, String accountId, String ownerId, String OriginalDecisionMaker, Date estimatedProposalDate, String reason, String dealReason, String competitor, String wasIncumbent, String localProviderName, Date origCloseDate, Date origActualCloseDate, String assignTo) {
        Opportunity opportunity = new Opportunity();
        Opportunity opportunityLost = new Opportunity();
        Opportunity opportunityOpenB = new Opportunity();
        Opportunity opportunityWonB = new Opportunity();
        
        opportunity.StageName = stageName;
        opportunity.Estimated_Proposal_Date__c = estimatedProposalDate;
        opportunity.AccountId = accountId;
        opportunity.OwnerId = ownerId;
        opportunity.Original_Decision_Maker__c = OriginalDecisionMaker;
        opportunity.CloseDate = estimatedProposalDate;
        opportunity.PW_RelatedOppty__c = oldOppId;
        opportunity.Assign_To__c = assignTo;
        if(stageName == 'Overcome Concerns'){  
            opportunity.Name = oppName + ' - ' + 'Still Open';
        
        }else if(stageName == 'Signed'){  
            opportunity.Name = oppName + ' - ' + 'Closing ' + estimatedProposalDate.month() + '/' + estimatedProposalDate.year();

        }else if(stageName == 'Lost'){
            opportunity.Name = oppName + ' - ' + stageName;
            opportunity.Reason_Won_Lost__c = reason;
            opportunity.Deal_lost_to_Won_from_whom__c = dealReason;
            opportunity.CMPT_ID__c = competitor;
            opportunity.Was_this_competitor_the_incumbent__c = wasIncumbent;
            opportunity.Local_Provider_Name__c = localProviderName;
            opportunity.CloseDate = origCloseDate;
            opportunity.Actual_Close_Date__c = origActualCloseDate;
        }
        
        //do 'insert' in different instances to prevent multiple insert issues 
        if(stageName == 'Lost'){
            opportunityLost = opportunity;
            insert opportunityLost; 
            
        }else if(stageName == 'Overcome Concerns') {
            opportunityOpenB = opportunity;
            insert opportunityOpenB; 
            
        }else if(stageName == 'Signed') {
            opportunityWonB = opportunity;
            insert opportunityWonB; 
        }
        
        return opportunity;
    }

    public static void UpdatePartialWin(String oppId){
    
        System.debug('aaaaaaa UpdatePartialWin: ' + oppId); 
        
        //Update record(s) as IsProcessed to prevent users from viewing
        List<PartialWinRateSheet__c> pw = [SELECT Id, IsProcessed__c FROM PartialWinRateSheet__c WHERE Opportunity__c = :oppId];
        System.debug('aaaaaaa pw : ' + pw ); 
        for (PartialWinRateSheet__c pwrs: pw){
            pwrs.IsProcessed__c = true;
        }     
        
        System.debug('aaaaaaa update pw : ' + pw ); 
        update pw;
        System.debug('aaaaaaa after update pw : ' + pw );         
    }     

 
}