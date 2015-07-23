trigger UpdateContactTaskAfterTrigger on Task (after update) 
{
/*Deployment - Customer Satisfaction
Purpose:  Once the survey task is updated with a Refusal, the corresponding contact record should be updated with
the Survey Opt-Out and Survey Opt-Out Reason*/

//A list to hold the Contact that needs to be updated

List<Contact> listofContact = new List<Contact>();
List<Customer_Branch__c> listofCustomerBranches = new List<Customer_Branch__c>();
Customer_Branch__c thewhat;

for (Task t : trigger.new)

{
    System.debug('t.Type: ' + t.Type);
    if (t.Type=='Survey') //Only do an update on contact for Survey tasks
    {
        System.debug('Survey task - check to udpate contact'); 
        //we save a soql query by instantiating a contact object with the id

        Contact thewho = new Contact(Id = t.whoId); //whoID represents the ID of the contact associated with the Task
        
        // Neelima-08/29/2011 to update last survey date on a customer branch
        // to do make sure the type is customer branch first
        if(t.WhatId!=null) thewhat= new Customer_Branch__c(id=t.WhatId) ;
        if(theWhat !=null)
        {
         //if(t.Survey_Opt_Out__c=='Yes' ||(t.CreatedDate <= System.today() && t.CreatedDate >= System.today()-366  && (t.Survey_Submission_Date__c != null || t.Call_Attempts__c == 3 )))
         if((t.Survey_Opt_Out__c=='Yes' && trigger.OldMap.get(t.Id).Survey_Opt_Out__c != 'Yes')||(trigger.OldMap.get(t.Id).Survey_Submission_Date__c == null && t.Survey_Submission_Date__c != null)  || (trigger.OldMap.get(t.Id).Call_Attempts__c<3 && t.Call_Attempts__c >= 3) )
        {
        	theWhat.LastSurveyDate__c= System.today();
        	if(t.Survey_Submission_Date__c != null) theWhat.LastSurveySubmissionDate__c=t.Survey_Submission_Date__c;
        	listofCustomerBranches.add(thewhat);
        }
         System.debug('*********updating Customer Branches  ' + listofCustomerBranches );
         if (listofCustomerBranches!= null && !listofCustomerBranches.isEmpty()) update listofCustomerBranches;
        }
        
        //Added by Raja to check if contact exists before updating it
        if(thewho !=null)
        {
            //check that the Task fields have changed from a different value earlier
                System.debug('contact found to update');
            if((t.Survey_Opt_Out__c == 'Yes') && (trigger.OldMap.get(t.Id).Survey_Opt_Out__c != 'Yes'))
            {
                thewho.HasOptedOutofSurvey__c = true;
                thewho.Survey_Opt_Out_Reason__c = t.Survey_Opt_Out_Reason__c;
                listofContact.add(thewho);
            }
            else if(t.Survey_Opt_Out__c == 'No' && trigger.OldMap.get(t.Id).Survey_Opt_Out__c != 'No')
            {
                thewho.HasOptedOutofSurvey__c = false;
                listofContact.add(thewho);
            }
            if (listofContact!= null && !listofContact.isEmpty())
            {
                System.debug('updating contact');
                try{Database.update(listofContact);}catch(Exception e){system.debug(e); }
            }
            else
            {
                System.debug('no change in survey opt out. No updates performed');
            }
            
        }
        else
        {
                System.debug('No contact to update');
        }
    }
    else
    {
        System.debug('Not a survey task');
    }
}
}