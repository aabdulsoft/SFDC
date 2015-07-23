public with sharing class OpportunityFilter_Controller
{
    ID AccIds;
    public List<Opportunity> OppData {get; set;}
    public String NewOppURL {get; set;}
    public String RecordTypeName {get; set;}
    public Boolean bMobile {get; set;}
    public OpportunityFilter_Controller(ApexPages.StandardController Control)
    {
    	bMobile = false;
    	String UserAgent = System.currentPageReference().getHeaders().get('User-Agent');
        system.debug('------------userAgent-->'+UserAgent);
        if(UserAgent.contains('Mobile') || UserAgent.contains('iPad'))
        	bMobile = true;
        system.debug('------------bMobile-->'+bMobile);
        AccIds = Control.getId();
        List<SelectOption> options = getRecordTypeNames();
        RecordTypeName = options[0].getValue();
        QueryOpportunity();
        NewOppURL = '/setup/ui/recordtypeselect.jsp?ent=Opportunity&retURL=%2F' + AccIds 
                    + '&save_new_url=%2F006%2Fe%3FretURL%3D%252F' + AccIds+ '%26accid%3D' + AccIds;
    }
    public List<SelectOption> getRecordTypeNames()
    {
        List<SelectOption> options = new List<SelectOption>();
        Global_Settings__c RecordTypeOpportunity = Global_Settings__c.getValues('9');
        if(RecordTypeOpportunity != null && RecordTypeOpportunity.IsActive__c && RecordTypeOpportunity.Value__c != null)
        {
            List<String> lRecordTypeIds = RecordTypeOpportunity.Value__c.split('&');
            for(String sRecordType : lRecordTypeIds)
            {
                options.add(new SelectOption(sRecordType.split('#')[1],sRecordType.split('#')[0]));
            }
        }
        return options;
    }
    public void QueryOpportunity()
    {
        List<Id> lRecordTypeIds = new List<Id>();
        lRecordTypeIds = RecordTypeName.split(',');
        OppData = [Select o.StageName, o.Num_of_vehicles__c, o.Owner.Name, 
                    o.OwnerId, o.Name, o.CloseDate, o.EST_DEAL_VAL__c, 
                    o.EVA__c, o.CreatedDate, o.Actual_Close_Date__c, o.AccountId 
                    From Opportunity o 
                    where RecordTypeId in: lRecordTypeIds 
                    and AccountId =: AccIds];
    }
    public void DeleteOpportunity()
    {
        String sOppId = ApexPages.currentPage().getParameters().get('recordid');
        if(sOppId != null && sOppId.length() > 0)
        {
            Opportunity Opp = null;
            for(Opportunity OppObj : OppData)
            {
                if(OppObj.Id == sOppId)
                    Opp = OppObj;
            }
            if(Opp != null)
            {
                delete Opp;
                QueryOpportunity();
            }
        }
        system.debug('--------------------------->'+sOppId);
    }
}