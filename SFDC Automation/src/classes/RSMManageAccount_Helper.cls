public with sharing class RSMManageAccount_Helper
{
    //FR001: logic to consider about an Account is Ket Account or not. Written by Nitin Gupta
    public static void ManageAccountCategory(List<Account> lAccount, Map<Id, Account> mAccount)
    {
        Set<Account> sAcc = new Set<Account>();
        Set<String> sFields = new Set<String>{'RSM_AC_Classification__c', 'RSM_Plus1_Total_Unit__c', 
                                                'RSM_Plus_Total_Unit__c', 'RSM_STD_Total_Unit__c', 'RSM_Manual_Update__c'};
        List<Account> accList=new List<Account>();
        // Check if any of the field get chnaged. If yes then re-calculate the logic
        for(Account AccObj: lAccount)
        {            
            if(!AccObj.RSM_Manual_Update__c)
            {
                for(String sField : sFields)
                {                   
                    String sNew = '';
                    String sOld = '';               
                    if(AccObj.get(sField) != null)
                        sNew = AccObj.get(sField) + '';
                    if(mAccount != null && mAccount.get(AccObj.Id).get(sField) != null)
                        sOld = mAccount.get(AccObj.Id).get(sField) + '';
                    if(sNew != sOld)
                    {
                        sAcc.add(AccObj);
                    }
                }
            }
        }
        // If field updated then re-calculate the logic of populating the Account Category
        for(Account AccObj : sAcc)
        {
            Boolean bKeyAccount = false;            
            if(AccObj.RSM_Plus1_Total_Unit__c > 9)
                bKeyAccount = true;
            else if(AccObj.RSM_Plus_Total_Unit__c > 29)
                bKeyAccount = true;
            else if(AccObj.RSM_STD_Total_Unit__c > 100)
                bKeyAccount = true;
            if(bKeyAccount)
            {
                AccObj.RSM_AC_Classification__c = 'Key Account';
            }
            else if(!bKeyAccount)
            {
                AccObj.RSM_AC_Classification__c = 'Non-Key Account';
            }
        }
        List<Messaging.SingleEmailMessage> lstSendEmail = new List<Messaging.SingleEmailMessage>();
        Set<ID> accountids = new Set<ID>();
        for(Account AccObj: lAccount)
        {
            String sNew = '';
            String sOld = '';               
            if(AccObj.RSM_AC_Classification__c != null)
                sNew = AccObj.RSM_AC_Classification__c + '';
            if(mAccount != null && mAccount.get(AccObj.Id).RSM_AC_Classification__c != null)
                sOld = mAccount.get(AccObj.Id).RSM_AC_Classification__c + '';
            if(sNew != sOld)
            {
                if(sNew == 'Key Account')
                    accountids.add(AccObj.Id);
                if(sNew == 'Key Account' && AccObj.Account_Capture_Date__c == null)
                    AccObj.Account_Capture_Date__c = System.today(); 
                else if(sNew == 'Non-Key Account' && AccObj.Non_Key_Account_Capture_Date__c == null)
                    AccObj.Non_Key_Account_Capture_Date__c = System.today();
            }
        }
        if(accountids.size() > 0)
        {
            List<account> lstaccount = [select Id, Name, RSM_CCMs__r.Name, RSM_CCMs__r.Email from account where id in : accountids];
            List<EmailTemplate> lstEmailtoCCM = [Select e.Subject, e.Id, e.Body From EmailTemplate e 
                                                    where DeveloperName = 'Key_Account_Email_to_CCM'];
            System.debug('-----74->'+lstaccount.size());
            if(lstEmailtoCCM.size() > 0 && lstaccount.size() > 0)
            {
                for(Account AccObj: lstaccount)
                {
                    String bodytemplate = lstEmailtoCCM[0].Body;
                    String subjecttemplate = lstEmailtoCCM[0].Subject;
                    subjecttemplate = subjecttemplate.replaceFirst('#AccountName#', Matcher.quoteReplacement(AccObj.Name));
                    bodytemplate = bodytemplate.replaceFirst('#AccountName#', Matcher.quoteReplacement(AccObj.Name));
                    bodytemplate = bodytemplate.replaceFirst('#UserName#', Matcher.quoteReplacement(AccObj.RSM_CCMs__r.Name));
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new list<String>{AccObj.RSM_CCMs__r.Email});                 
                    mail.setPlainTextBody(bodytemplate);
                    mail.setSubject(subjecttemplate);
                    mail.setSaveAsActivity(false);
                    lstSendEmail.add(mail);
                }
            }
        }
        System.debug('-----94->'+lstSendEmail.size());
	    if(lstSendEmail.size() > 0)
	        Messaging.sendEmail(lstSendEmail);
    }
    public static void RSMCCMUpdate(List<Account> lAccount, Map<Id,Account> mAccount)
    {
        Set<ID> sAccIds = new Set<ID>();
        Map<String,Account> actMap=new Map<String,Account>();
        Map<String,String> salesTerrCCMMap=new Map<String,String>();
        Set<String> sFields = new Set<String>{'RSM_AC_Classification__c', 'RSM_CCMs__c'};
        for(Account AccObj : lAccount)
        {
            if(!AccObj.RSM_CCM_manual_Update__c)
            {
                for(String sField : sFields)
                {
                    String sNew = '';
                    String sold = '';
                    if(AccObj.get(sField) != null)
                        sNew = AccObj.get(sField) + '';
                    if(mAccount != null && mAccount.get(AccObj.Id).get(sField) != null)
                        sOld = mAccount.get(AccObj.Id).get(sField) + '';
                    if(sNew != sOld)
                        sAccIds.add(AccObj.Id);
                }
            }
        }
        if(sAccIds.size() > 0)
        {
            List<Account> hqAccountList=[Select Id,Account_Classification__c,RSM_AC_Classification__c,RSM_Manual_Update__c,RSM_CCMs__c,RSM_CCM_manual_Update__c,Owner.Sales_Territory__c from Account where Id in : sAccIds];
            for(Account ac:hqAccountList)
            {
                actMap.put(ac.Owner.Sales_Territory__c,ac);
            }        
            List<Sales_Territory__c> stList=[select Name,RydeSmart_Owners__c from Sales_Territory__c where Name in : actMap.keyset()];
            for(Sales_Territory__c stc:stList){
                salesTerrCCMMap.put(stc.Name,stc.RydeSmart_Owners__c);        
            }
            List<Account> accList=new List<Account>();
            for(Account AccObj:hqAccountList)
            {
                if(salesTerrCCMMap != null && AccObj.RSM_AC_Classification__c == 'Key Account')
                {
                    AccObj.RSM_CCMs__c=salesTerrCCMMap.get(AccObj.Owner.Sales_Territory__c);
                }
                else if(AccObj.RSM_AC_Classification__c=='Non-Key Account')
                {
                    AccObj.RSM_CCMs__c = Label.RSMNonKeyAccountCCMUser;     
                }
                accList.add(AccObj);
            }
            if(accList!=null && accList.size()>0 && !Test.isRunningTest())
            {
                System.debug('****Before after****'+accList);
                update accList;
                System.debug('****List after****'+accList);
            }
        }
    }    
    public static void ValidateAccountLesseNumber(List<Account> lAccount, Map<Id, Account> mAccount)
    {
        Set<String> sAccLesse = new Set<String>();
        Set<String> sAccIds = new Set<String>();
        Set<String> sFields = new Set<String>{'LesseeNo__c'};
        List<Account> accList=new List<Account>();
        // Check if any of the field get chnaged. If yes then re-calculate the logic
        
        
        for(Account AccObj: lAccount)
        {            
            for(String sField : sFields)
            {                   
                String sNew = '';
                String sOld = '';               
                if(AccObj.get(sField) != null)
                    sNew = AccObj.get(sField) + '';
                if(mAccount != null && mAccount.get(AccObj.Id).get(sField) != null)
                    sOld = mAccount.get(AccObj.Id).get(sField) + '';
                if(sNew != '' && sNew != sOld)
                {
                    sAccLesse.add(sNew);
                    if(AccObj.Id != null)
                        sAccIds.add(AccObj.Id);
                }
            }
        }
        if(sAccLesse.size() > 0)
        {
            Integer iCount = [SELECT count() FROM Account where LesseeNo__c IN : sAccLesse and Id not IN : sAccIds];
            if(iCount > 0)
            {
                if(lAccount.size() == 1)
                    lAccount[0].LesseeNo__c.addError('This Lessee Number is already used!');
                else
                    lAccount[0].LesseeNo__c.addError('Duplicate Lessee Number in the List!');
            }
        }
    }
}