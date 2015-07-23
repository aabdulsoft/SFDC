public class RSMManageContracts
{
    public static void ManageEqipmentRequisition(List<RSM_Contract__c> listContract, Map<Id, RSM_Contract__c> MapContract)  
    {
        Map<Id, list<RSM_ContractDetail__c>> mapcontractdetails = new Map<Id, list<RSM_ContractDetail__c>>();
        Set<ID> setCont = new Set<ID>();
        Set<ID> setvehicle = new Set<ID>();
        Set<ID> sAccIds = new Set<ID>();
        List<RSM_Contract__c> listContracttoprocess = new List<RSM_Contract__c>();
        for(RSM_Contract__c contr : listContract)
        {
            if(contr.Status_Name__c == 'Approved' && (MapContract == null || 
                    (MapContract.get(contr.Id).Status_Name__c != null && 
                    MapContract.get(contr.Id).Status_Name__c != 'Approved')))
            {
                setCont.add(contr.Id);
                listContracttoprocess.add(contr);
                if(contr.Account__c != null)
                    sAccIds.add(contr.Account__c);
            }
        }
        if(setCont.size() > 0)
        {
            
            Map<Id, RSM_ContractDetail__c> mapcontdetails = new Map<Id, RSM_ContractDetail__c>([Select r.Valid__c, r.Unit_Number__c, 
                                                                r.Name, r.Id, r.Contract_Number__c From RSM_ContractDetail__c r where 
                                                                Contract_Number__c in : setCont]);
            for(RSM_Contract__c contr : listContracttoprocess)
            {
                List<RSM_ContractDetail__c> listdetails = new List<RSM_ContractDetail__c>();
                for(RSM_ContractDetail__c contractdetail : mapcontdetails.values())
                {
                    if(contractdetail.Contract_Number__c == contr.Id)
                    {
                        //listdetails.add(contractdetail);
                        setvehicle.add(contractdetail.Unit_Number__c);
                    }
                }
                if(listdetails.size() > 0)
                    mapcontractdetails.put(contr.Id, listdetails);
            }
        }
        System.debug('--34----------mapcontractdetails-----'+mapcontractdetails);
        if(setvehicle.size() > 0)
        {
            Map<ID, List<Vehicle__c>> mapVelicle = new Map<ID, List<Vehicle__c>>();
            Map<Id, Vehicle__c> mapVehicle = new Map<Id, Vehicle__c>([Select v.CUSTOMER_BRANCH__r.Ryder_Branch__c, 
                                                                        v.CUSTOMER_BRANCH__c, v.Account__c, v.RSM_Service_Level__c 
                                                                        From Vehicle__c v where id in : setvehicle and 
                                                                        RSM_Service_Level__c != null]);
            Set<ID> setAccount = new Set<ID>();
            for(Vehicle__c Vehicle : mapVehicle.values())
            {
                setAccount.add(Vehicle.Account__c);
            }
            for(ID accId : setAccount)
            {
                List<Vehicle__c> listVehicle = new List<Vehicle__c>();
                for(Vehicle__c Vehicle : mapVehicle.values())
                {
                    if(accId == Vehicle.Account__c)
                        listVehicle.add(Vehicle);
                }
                if(listVehicle.size() > 0)
                    mapVelicle.put(accId, listVehicle);
            }
            
            Map<ID, List<RSM_Component__c>> mapvehComp = new Map<ID, List<RSM_Component__c>>();
            
            Map<Id, RSM_Component__c> mapComponent = new Map<Id, RSM_Component__c>([Select r.Unit_Number__c, r.Is_Current__c, r.Id, 
                                                        r.Equipment_Type__c From RSM_Component__c r where 
                                                        Unit_Number__c in : mapVehicle.keySet() 
                                                        and Is_Current__c = true]);
            for(ID vehicleid : setvehicle)
            {
                List<RSM_Component__c> listComponent = new List<RSM_Component__c>();
                for(RSM_Component__c Component : mapComponent.values())
                {
                    if(Component.Unit_Number__c == vehicleid)
                        listComponent.add(Component);
                }
                if(listComponent.size() > 0)
                    mapvehComp.put(vehicleid, listComponent);
            }
            
            
        }
        if(sAccIds.size() > 0)
        {
            updateAccount(sAccIds);
        }
    }
    @future
    public static void updateAccount(Set<ID> sAccIds)
    {
        List<Account> lAcc = new List<Account>();
        for(ID AccId : sAccIds)
        {
            Account Acc = new Account(Id = AccId, Update_Revenue__c = true);
            lAcc.add(Acc);
        }
        if(lAcc.size() > 0)
        {
            update lAcc;
        }
    }
    public static void AccountSendEmail(List<RSM_Contract__c> listContract)  
    {
        
        Set<ID> setaccountid = new Set<ID>();
        for(RSM_Contract__c RSM_Contract : listContract)
        {
            if(RSM_Contract.Account__c != null)
                setaccountid.add(RSM_Contract.Account__c);
        }
        if(setaccountid.size() > 0)
        {
            List<AggregateResult> ContractAgg = [SELECT Count(Id) CountId, Account__c Acc FROM RSM_Contract__c WHERE 
                                                    Account__c in: setaccountid  
                                                    Group by Account__c];
            setaccountid = new Set<ID>();
            for(AggregateResult AggResult : ContractAgg)
            {
                Integer iContractCount = ((integer)AggResult.get('CountId'));
                if(iContractCount == 1)
                {
                    setaccountid.add(((Id)AggResult.get('Acc')));
                }
            }
        }
        if(setaccountid.size() > 0)
        {
            List<Account> accforemail = [select Id, RSM_CCMs__c from Account where Id in : setaccountid];
            List<Messaging.SingleEmailMessage> lstSendEmail = new List<Messaging.SingleEmailMessage>();
            List<EmailTemplate> lstemailtemplate = [Select Id from EmailTemplate where DeveloperName = 'First_Contract_Email_CCM'];
            
            if(lstemailtemplate.size() > 0)
            {
                for(Account a : accforemail)
                {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(a.RSM_CCMs__c);                 
                    mail.setTemplateId(lstemailtemplate[0].Id);
                    mail.setSaveAsActivity(false);
                    lstSendEmail.add(mail);
                }
            }
            if(lstSendEmail.size() > 0)
                Messaging.sendEmail(lstSendEmail);              
        }
    }
}