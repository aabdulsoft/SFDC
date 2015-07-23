public without sharing class LeadManagement_Helper
{
    public static void ManageLeadOwner(List<Lead> listLead, Map<Id, Lead> mapLead)
    {
        List<Lead> listLeadupdate = new List<Lead>();
        Set<String> PostalCodes = new Set<String>();
        Set<String> sLeadIds = new Set<String>();
        Map<String, String> mapLeadqueue = new Map<String, String>();
        for(String QueueItems : String.ValueOf(LABEL.TSA_Lead_Assignment_Queue).split('#'))
        {
            List<String> Queue = QueueItems.split(',');
            mapLeadqueue.put(Queue[0], Queue[1]);
        }
        
        for(Lead leadnew : [SELECT Id, OwnerId, PostalCode FROM Lead WHERE Id in : listLead])
        {
            if(LABEL.TSA_Lead_Assignment_QueueIncluded.contains(Leadnew.OwnerId))
            {
                if(leadnew.PostalCode != null)
                {
                    PostalCodes.add(leadnew.PostalCode);
                    sLeadIds.add(leadnew.Id);                    
                }
                else
                {
                    leadnew.OwnerId = mapLeadqueue.get('General');
                }
                listLeadupdate.add(leadnew);
            }
            else if(String.ValueOf(LABEL.TSA_Lead_Assignment_Queue).contains(Leadnew.OwnerId))
            {               
                if(leadnew.PostalCode != null && (mapLead == null || mapLead.get(leadnew.Id).PostalCode == null || 
                    mapLead.get(leadnew.Id).PostalCode != leadnew.PostalCode))
                {
                    PostalCodes.add(leadnew.PostalCode);
                    sLeadIds.add(leadnew.Id);
                    listLeadupdate.add(leadnew);
                }
                else if(leadnew.PostalCode == null && (mapLead == null || mapLead.get(leadnew.Id).PostalCode != null))              
                {
                    leadnew.OwnerId = mapLeadqueue.get('General');
                    listLeadupdate.add(leadnew);
                }
            }
        }
        //listLeadupdate = [select Id, OwnerId, PostalCode from Lead where id in : sLeadIds];
        if(PostalCodes.size() > 0)
        {
            Map<String, Postal_Code__c> mapByPostalCode = new Map<String, Postal_Code__c>();
            Map<Id, Postal_Code__c> mapPostalCode = new Map<Id, Postal_Code__c>([Select p.Postal_Code__c, p.DOS__r.Region__c, 
                                                                                    p.DOS__c From Postal_Code__c p 
                                                                                    where Postal_Code__c in : PostalCodes 
                                                                                    and DOS__r.Region__c != null]);
            if(mapPostalCode != null && mapPostalCode.size() > 0)
            {
                for(Postal_Code__c PostalCode : mapPostalCode.values())
                {
                    mapByPostalCode.put(PostalCode.Postal_Code__c, PostalCode);
                }
            }
            if(mapByPostalCode.size() > 0)
            {
                for(Lead leadnew : listLeadupdate)
                {
                    Postal_Code__c PostalCode = mapByPostalCode.get(leadnew.PostalCode);
                    if(PostalCode != null)
                    {
                        String sQueueId = mapLeadqueue.get(PostalCode.DOS__r.Region__c);
                        if(sQueueId != null)
                        {
                            leadnew.OwnerId = (Id)sQueueId;
                        }
                    }
                }
            }           
        }
        if(listLeadupdate.size() > 0)
            update listLeadupdate;
    }
}