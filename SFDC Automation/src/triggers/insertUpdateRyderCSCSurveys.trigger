trigger insertUpdateRyderCSCSurveys on Ryder_CSC_Surveys__c (before insert, before update) {
    Integer surveyScore=0;
    Integer numberOfQuestions=4;
    Integer questionWeight=100/numberofQuestions;
    string surveyRecordTypeId = '';
    
    Map<String, Id> surveyRecordTypes = CommonFunctions.getRecordTypeMap('Ryder_CSC_Surveys__c');
    surveyRecordTypeId = surveyRecordTypes.get('Pilot Survey');
    for (Ryder_CSC_Surveys__C rs : Trigger.new)
    {
        // check if the record is dirty for an update
        if(Trigger.isInsert  || (Trigger.isUpdate && rs.Was_your_call_resolved__c !=trigger.oldMap.get(rs.Id).Was_your_call_resolved__c  ||
           rs.Was_your_issue_addressed__c !=trigger.oldMap.get(rs.Id).Was_your_issue_addressed__c  ||
           rs.How_satisfied_are_you_with_the_agent__c !=trigger.oldMap.get(rs.Id).How_satisfied_are_you_with_the_agent__c  ||
           rs.Likelihood_of_calling_again__c !=trigger.oldMap.get(rs.Id).Likelihood_of_calling_again__c)
           && rs.RecordTypeId == surveyRecordTypeId)
        {
            //calculate the survey score
            if(rs.Was_your_call_resolved__c=='Yes') surveyScore=surveyScore+questionWeight;
            if(rs.Was_your_issue_addressed__c=='Yes')surveyScore=surveyScore+questionWeight;
            if(rs.How_satisfied_are_you_with_the_agent__c=='Satisfied')surveyScore=surveyScore+questionWeight;
            if(rs.Likelihood_of_calling_again__c=='Likely') surveyScore=surveyScore+questionWeight;
            rs.Survey_Score__c=surveyScore;
        }
    }
}