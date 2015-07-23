public with sharing class CaseManagement_Helper
{
    /*
        Below method is called on Case creation from CaseManagement trigger
        This method checks if the Case record type is Legal Cases and Run Assignment Rule check box is check
        If match conditoins then this method Run the Assignment Rules
    */
    public static void RunAssignmentRuleForMobileLegalRecord(List<Case> lCase)
    {
        List<Case> lCasesUpdate = new List<Case>();
        List<Case> lCases = [select RecordTypeId, Run_Assign_Rule_From_Mobile__c from Case where Id in: lCase];
        String CaseProposalRecordTypeId = '';
        // Query the Custom settings where Name is 1 as the Case Proposal Record type is stored as 1 in Name
        Global_Settings__c CaseProposalRecordType = Global_Settings__c.getValues('5');
        // if the custom settings is not null then get the value from settings and out in a local variable
        if(CaseProposalRecordType != null)
            CaseProposalRecordTypeId = CaseProposalRecordType.Value__c;
        System.debug('------16-->'+CaseProposalRecordTypeId);
        if(CaseProposalRecordTypeId != '')
        {
            for(Case CaseObj : lCases)
            {
                System.debug('------23-->'+CaseObj.RecordTypeId);
                System.debug('------24-->'+CaseObj.Run_Assign_Rule_From_Mobile__c);
                if(CaseObj.RecordTypeId != null && CaseProposalRecordTypeId == CaseObj.RecordTypeId && CaseObj.Run_Assign_Rule_From_Mobile__c)
                {
                    Database.DMLOptions dmlOpts = new Database.DMLOptions();
                    dmlOpts.assignmentRuleHeader.useDefaultRule = true;
                    System.debug('------33-->'+dmlOpts);
                    CaseObj.setOptions(dmlOpts);
                    lCasesUpdate.add(CaseObj);
                }
            }
        }
        if(lCasesUpdate.size() > 0)
            update lCasesUpdate;
    }
    /*
        Below method is called on Case creation from CaseManagement trigger
        This method checks if the Case record type is Proposal Response or not
        If Case record type is Proposal Response then this method collect all those cases and send them to another method
    */
    public static void CreateChatterFeedonInsert(List<Case> lCase)
    {
        System.debug('------48-->'+lCase[0].OwnerId);
        Set<String> sCaseIds = new Set<String>();
        String CaseProposalRecordTypeId = '';
        // Query the Custom settings where Name is 1 as the Case Proposal Record type is stored as 1 in Name
        Global_Settings__c CaseProposalRecordType = Global_Settings__c.getValues('1');
        // if the custom settings is not null then get the value from settings and out in a local variable
        if(CaseProposalRecordType != null)
            CaseProposalRecordTypeId = CaseProposalRecordType.Value__c;
        for(Case CaseObj : lCase)
        {
            // Check if the Case Record Type match with the Proposal Response Record Type Id
            if(CaseObj.RecordTypeId != null && CaseProposalRecordTypeId == CaseObj.RecordTypeId)
            {
                sCaseIds.add(CaseObj.Id);
            }
        }
        // If the CaseId size is greater then 0 then send these Ids to process
        if(sCaseIds.size() > 0)
        {
            CreateFeedOnInsert(sCaseIds, UserInfo.getSessionId(), '2');
        }
    }
    /*
        Below method is called on Case update from CaseManagement trigger
        This method checks if the Case record type is Proposal Response or not
        If Case record type is Proposal Response then this method collect all those cases and 
        checks if the 4 fields updated or not, if yes then send them all to another method to process
    */
    public static void CreateChatterFeedonUpdate(List<Case> lCase, Map<Id, Case> mOldCase)
    {
        // List of fields which we need to check for updates
        Set<String> sFields = new Set<String>{'Proposal_Due_Date__c','Question_Due_Date__c','Resources_requeste__c'};
        Set<String> sCaseIds = new Set<String>();
        Set<String> sCaseClosedIds = new Set<String>();
        String CaseProposalRecordTypeId = '';
        // Query the Custom settings where Name is 1 as the Case Proposal Record type is stored as 1 in Name
        Global_Settings__c CaseProposalRecordType = Global_Settings__c.getValues('1');
        // if the custom settings is not null then get the value from settings and out in a local variable
        if(CaseProposalRecordType != null)
            CaseProposalRecordTypeId = CaseProposalRecordType.Value__c;
        for(Case CaseObj : lCase)
        {
            // Check if the Case Record Type match with the Proposal Response Record Type Id
            if(CaseObj.RecordTypeId != null && CaseProposalRecordTypeId == CaseObj.RecordTypeId)
            {
                if(!CaseObj.IsClosed)
                {
                    for(String sField : sFields)
                    {
                        String sNew = '';
                        String sOld = '';
                        if(CaseObj.get(sField) != null)
                            sNew = CaseObj.get(sField) + '';
                        if(mOldCase.get(CaseObj.Id).get(sField) != null)
                            sOld = mOldCase.get(CaseObj.Id).get(sField) + '';
                        // Check if the values of the fields are different
                        if(sNew != sOld)
                        {
                            sCaseIds.add(CaseObj.Id);
                        }
                    }
                }
                // Check if the Case is get closed
                if(CaseObj.IsClosed != mOldCase.get(CaseObj.Id).IsClosed && CaseObj.IsClosed)
                    sCaseClosedIds.add(CaseObj.Id);
            }
        }
        // Call the another method to insert a Case Feed
        if(sCaseIds.size() > 0)
        {
            CreateFeedOnInsert(sCaseIds, UserInfo.getSessionId(), '3');
        }       
        // Call the another method to insert a Case Feed
        if(sCaseClosedIds.size() > 0)
        {
            // One of the paramter is User Session as we need thi sin HTTP call and for the same user whi is creating the Case
            CreateFeedOnInsert(sCaseClosedIds, UserInfo.getSessionId(), '4');
        }
    }
    /*
        This method create the text which needs to be sent and call the method which will insert the feed on Case
    */
    @future(callOut=true)
    public static void CreateFeedOnInsert(Set<String> sCaseIds, String sSession, String sMsgNo)
    {
        Integer iCount = 0;
        List<Case> lCases = [Select c.OwnerId, c.Id, c.CaseNumber, c.Account.Name, c.AccountId From Case c where Id in: sCaseIds];
        for(Case CaseObj : lCases)
        {
            String sMsgBody = '';
            // Call Custom Settings and get the Feed Content
            Global_Settings__c CaseProposalEmailContent = Global_Settings__c.getValues(sMsgNo);
            if(CaseProposalEmailContent != null)
            {
                sMsgBody = CaseProposalEmailContent.Value__c;
                if(CaseObj.AccountId != null)
                    sMsgBody = sMsgBody.replace('AccountName', ' for ' + CaseObj.Account.Name);
                else
                    sMsgBody = sMsgBody.replace(' AccountName', '');
            }
            // Call the method to insert the Feed
            CreateFeed(sMsgBody, CaseObj, sSession);
            iCount++;
            if(iCount == 10 || Test.isRunningTest())
                break;
        }
    }
    /*
        This method insert the feed on Case for the Case Owner, if the Owner is a queue then add them all in the feed
        We can add @mention only by using the HTTP post there is no other way to make it.
    */
    public static void CreateFeed(String sMsgBody,Case CaseObj, String sSession)
    {
        String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
        // End point URL
        String url =  salesforceHost + '/services/data/v29.0/chatter/feeds/record/' + CaseObj.Id + '/feed-items';
        // Object for HTTP request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(url);
        // Content type is json
        req.setHeader('Content-type', 'application/json');
        // Set the User session
        req.setHeader('Authorization', 'OAuth ' + sSession);//UserInfo.getSessionId());
        String sMsg = '{ "body" : { "messageSegments" : [ ';
        Boolean bInsertChatterFeed = false;
        if(String.valueOf(CaseObj.OwnerId).startsWith('00G'))
        {
            // Query all the users in case the Case Owner is a Queue and set all the users in the Feed
            List<GroupMember> lGroupMember = [Select g.UserOrGroupId from GroupMember g where g.GroupId =: CaseObj.OwnerId];
            for(GroupMember GroupMemberObj : lGroupMember)
            {
                sMsg += '{ "type": "mention", "id" : "' + GroupMemberObj.UserOrGroupId + '" },';
                bInsertChatterFeed = true;
            }
        }       
        else if(String.valueOf(CaseObj.OwnerId).startsWith('005')) // If the case owner is a user then add the user only 
        {
            sMsg += '{ "type": "mention", "id" : "' + CaseObj.OwnerId + '" },';
            bInsertChatterFeed = true;
        }
        // Add the actual message in the Feed
        sMsg += '{ "type": "text",  "text" : "' + sMsgBody +'" } ] } }';
        req.setBody(sMsg);
        Http http = new Http();
        // Send the http request if the User is found and avoid sending the request in case of Test Methods
        if(bInsertChatterFeed && !Test.isRunningTest())
            HTTPResponse res = http.send(req);
    }
}