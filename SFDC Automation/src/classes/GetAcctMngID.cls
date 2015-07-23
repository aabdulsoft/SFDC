public with sharing class GetAcctMngID {
//This class is used to get the email address of the Account Management Team.
//Created on 04/03/2012 Saad Wali Jaan.

    @future (Callout=true)
    Public static void GetDetails(string surveyId, string objType)
    {
        List<Ryder_Surveys__c> rs = [Select r.Contact__c, r.Activity_ID__c, r.CS_Score__c, r.Customer_Branch__c, r.Customer_Branch__r.Customer_Branch_Owner__c, r.Customer_Branch__r.Name, r.Customer_Branch__r.Ryder_Branch__c, r.Customer_Branch__r.Ryder_HQ_Account__c, r.Customer_Sat_Acct_Mgr_Satisfaction__c, r.Customer_Sat_Likelihood_to_Renew__c, r.Customer_Sat_Maintenance_Satisfaction__c, r.Customer_Sat_Shop_Communications__c, r.Customer_Sat_Willingness_to_Refer__c, r.Id, r.Survey_Conducted_By__c, r.Survey_Submission_Date__c, r.Ryder_Customer__c from Ryder_Surveys__c r WHERE r.Id = :surveyId];
        for(Ryder_Surveys__c r : rs)
        {
            // Retrieve id of Account Management Team         
            List<Ryder_Branch__c> ids = [SELECT rb.Account_Manager_Email__c , rb.Director_of_Asset_Management_Email__c, rb.Director_of_Ops_Email__c, rb.Director_of_Rental_Email__c, rb.Director_of_Sales_Email__c, rb.Maintenance_Manager_Email__c, rb.Rental_Manager_Email__c, rb.Senior_VP_Email__c, rb.Senior_VP_of_Ops_Email__c, rb.Service_Manager_Email__c,rb.Quality_Manager_Email__c, rb.Quality_VP_Email__c, rb.Quality_Director_Email__c, rb.Finance_Manager_Email__c, rb.Finance_Director_Email__c, rb.Finance_VP_Email__c, rb.SAC_Email__c, rb.SAC2_Email__c, rb.Inside_Sales_Email__c, rb.MOS_Email__c, rb.MOS_Name__c, rb.MOS_Phone__c, rb.MOS_UserId__c FROM Ryder_Branch__c rb WHERE rb.Id = :r.Customer_Branch__r.Ryder_Branch__c];
            sendEmailToList(ids, r, objType); 
        }    
    }
    
    Public static void sendEmailToList(List<Ryder_Branch__c> ids, Ryder_Surveys__c rs, string objType)
    {
        //list for storing id's of recipient
        String[] idList = new List<String>();
        
        string staticEmailList = RyderGlobalVariables.Ryder_Survey_PDF_Recipients;
        if(staticEmailList != null) idList = staticEmailList.split(',');
        
        string customerBranchOwner = rs.Customer_Branch__r.Customer_Branch_Owner__c;
        
        String emailBranchOwnerEmail = '';
        List<User> userBranchOwner;
        if(customerBranchOwner != null) userBranchOwner = [Select u.Email from User u where u.Id = :customerBranchOwner];
     
        if(userBranchOwner != null && userBranchOwner.size()>0)
        {
            emailBranchOwnerEmail  = userBranchOwner[0].Email;
            idList.add(emailBranchOwnerEmail);
        }
        
        // Go through fields and send emails         
        if(ids <> null)
        {
            if(ids[0].Account_Manager_Email__c != customerBranchOwner)
            {
                system.debug('***** ids[0].Account_Manager_Email__c = ' + ids[0].Account_Manager_Email__c);
            
                if((ids[0].Account_Manager_Email__c != null) && (ids[0].Account_Manager_Email__c != ''))
                {
                    idList.add(ids[0].Account_Manager_Email__c);
                }
            }
            
            if(ids[0].Director_of_Asset_Management_Email__c != customerBranchOwner)
            {
                system.debug('***** ids[0].Director_of_Asset_Management_Email__c = ' + ids[0].Director_of_Asset_Management_Email__c);
            
                if((ids[0].Director_of_Asset_Management_Email__c != null) && (ids[0].Director_of_Asset_Management_Email__c != ''))
                {
                    idList.add(ids[0].Director_of_Asset_Management_Email__c);
                }
            }

            if(ids[0].Director_of_Ops_Email__c != customerBranchOwner)
            {
                system.debug('***** ids[0].Director_of_Ops_Email__c = ' + ids[0].Director_of_Ops_Email__c);
            
                if((ids[0].Director_of_Ops_Email__c != null) && (ids[0].Director_of_Ops_Email__c != ''))
                {
                    idList.add(ids[0].Director_of_Ops_Email__c);
                }
            }

            if(ids[0].Director_of_Rental_Email__c != customerBranchOwner)
            {
                system.debug('***** ids[0].Director_of_Rental_Email__c = ' + ids[0].Director_of_Rental_Email__c);

                if((ids[0].Director_of_Rental_Email__c != null) && (ids[0].Director_of_Rental_Email__c != ''))
                {
                    idList.add(ids[0].Director_of_Rental_Email__c);
                }
            }
            
            if(ids[0].Director_of_Sales_Email__c != customerBranchOwner)
            {
                system.debug('***** ids[0].Director_of_Sales_Email__c = ' + ids[0].Director_of_Sales_Email__c);
            
                if((ids[0].Director_of_Sales_Email__c != null) && (ids[0].Director_of_Sales_Email__c != ''))
                {
                    idList.add(ids[0].Director_of_Sales_Email__c);
                }
            }
            
            if(ids[0].Maintenance_Manager_Email__c != customerBranchOwner)
            {
                system.debug('***** ids[0].Maintenance_Manager_Email__c = ' + ids[0].Maintenance_Manager_Email__c);
            
                if((ids[0].Maintenance_Manager_Email__c != null) && (ids[0].Maintenance_Manager_Email__c != ''))
                {
                    idList.add(ids[0].Maintenance_Manager_Email__c);
                }
            }
            
            if(ids[0].Rental_Manager_Email__c != customerBranchOwner)
            {
                system.debug('***** ids[0].Rental_Manager_Email__c = ' + ids[0].Rental_Manager_Email__c);
            
                if((ids[0].Rental_Manager_Email__c != null) && (ids[0].Rental_Manager_Email__c != ''))
                {
                    idList.add(ids[0].Rental_Manager_Email__c);
                }
            }
            
            if(ids[0].Senior_VP_Email__c  != customerBranchOwner)
            {
                system.debug('***** ids[0].Senior_VP_Email__c = ' + ids[0].Senior_VP_Email__c);
            
                if((ids[0].Senior_VP_Email__c != null) && (ids[0].Senior_VP_Email__c != ''))
                {
                    idList.add(ids[0].Senior_VP_Email__c);
                }
            }
            
            if(ids[0].Senior_VP_of_Ops_Email__c != customerBranchOwner)
            {
                system.debug('***** ids[0].Senior_VP_of_Ops_Email__c = ' + ids[0].Senior_VP_of_Ops_Email__c);
            
                if((ids[0].Senior_VP_of_Ops_Email__c != null) && (ids[0].Senior_VP_of_Ops_Email__c != ''))
                {
                    idList.add(ids[0].Senior_VP_of_Ops_Email__c);
                }
            }
            
            if(ids[0].Service_Manager_Email__c != customerBranchOwner)
            {
                system.debug('***** ids[0].Service_Manager_Email__c = ' + ids[0].Service_Manager_Email__c);
            
                if((ids[0].Service_Manager_Email__c != null) && (ids[0].Service_Manager_Email__c != ''))
                {
                    idList.add(ids[0].Service_Manager_Email__c);
                }
            }
            
            if(ids[0].Quality_Manager_Email__c != customerBranchOwner)
            {
                system.debug('***** ids[0].Quality_Manager_Email__c = ' + ids[0].Quality_Manager_Email__c);
            
                if((ids[0].Quality_Manager_Email__c != null) && (ids[0].Quality_Manager_Email__c != ''))
                {
                    idList.add(ids[0].Quality_Manager_Email__c);
                }
            }
            
            if(ids[0].Quality_VP_Email__c != customerBranchOwner)
            {
                system.debug('***** ids[0].Quality_VP_Email__c = ' + ids[0].Quality_VP_Email__c);
            
                if((ids[0].Quality_VP_Email__c != null) && (ids[0].Quality_VP_Email__c != ''))
                {
                    idList.add(ids[0].Quality_VP_Email__c);
                }
            }
            
            if(ids[0].Quality_Director_Email__c != customerBranchOwner)
            {
                system.debug('***** ids[0].Quality_Director_Email__c = ' + ids[0].Quality_Director_Email__c);
            
                if((ids[0].Quality_Director_Email__c != null) && (ids[0].Quality_Director_Email__c != ''))
                {
                    idList.add(ids[0].Quality_Director_Email__c);
                }
            }
            
            if(ids[0].Finance_Manager_Email__c != customerBranchOwner)
            {
                system.debug('***** ids[0].Finance_Manager_Email__c = ' + ids[0].Finance_Manager_Email__c);
            
                if((ids[0].Finance_Manager_Email__c != null) && (ids[0].Finance_Manager_Email__c != ''))
                {
                    idList.add(ids[0].Finance_Manager_Email__c);
                }
            }
            
            if(ids[0].Finance_Director_Email__c != customerBranchOwner)
            {
                system.debug('***** ids[0].Finance_Director_Email__c = ' + ids[0].Finance_Director_Email__c);
            
                if((ids[0].Finance_Director_Email__c != null) && (ids[0].Finance_Director_Email__c != ''))
                {
                    idList.add(ids[0].Finance_Director_Email__c);
                }
            }
            
            if(ids[0].Finance_VP_Email__c != customerBranchOwner)
            {
                system.debug('***** ids[0].Finance_VP_Email__c = ' + ids[0].Finance_VP_Email__c);
            
                if((ids[0].Finance_VP_Email__c != null) && (ids[0].Finance_VP_Email__c != ''))
                {
                    idList.add(ids[0].Finance_VP_Email__c);
                }
            }   
                 
            if(ids[0].SAC_Email__c != customerBranchOwner)
            {
                system.debug('***** ids[0].SAC_Email__c = ' + ids[0].SAC_Email__c);
            
                if((ids[0].SAC_Email__c != null) && (ids[0].SAC_Email__c != ''))
                {
                    idList.add(ids[0].SAC_Email__c);
                }
            }
            
            if(ids[0].SAC2_Email__c != customerBranchOwner)
            {
                system.debug('***** ids[0].SAC2_Email__c = ' + ids[0].SAC2_Email__c);
            
                if((ids[0].SAC2_Email__c != null) && (ids[0].SAC2_Email__c != ''))
                {
                    idList.add(ids[0].SAC2_Email__c);
                }
            }
            
            if(ids[0].Inside_Sales_Email__c != customerBranchOwner)
            {
                system.debug('***** ids[0].Inside_Sales_Email__c = ' + ids[0].Inside_Sales_Email__c);
            
                if((ids[0].Inside_Sales_Email__c != null) && (ids[0].Inside_Sales_Email__c != ''))
                {
                    idList.add(ids[0].Inside_Sales_Email__c);
                }
            }   
            
            if(ids[0].MOS_Email__c != customerBranchOwner)
            {
                system.debug('***** ids[0].MOS_Email__c = ' + ids[0].MOS_Email__c);
            
                if((ids[0].MOS_Email__c != null) && (ids[0].MOS_Email__c != ''))
                {
                    idList.add(ids[0].MOS_Email__c);
                }
             }  
        }
        system.debug('Saad - idList = ' + idList);
                 
        if(idList.size() <= 0)
        {
            return;
        } 
        else
        {  
            EmailContent.sendMail(idList, rs, objType);
        }
    }
}