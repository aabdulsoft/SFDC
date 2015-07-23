trigger CalculateCSScore on Ryder_Surveys__c (before insert, before update) {
//Changed By:Saad Wali Jaan
//Changed Date: 8/23/2012
//Description: Instead of below logic, CS score would now be calculated the same way as the CSI score is calculated. Thats is in order to 
//calculate CS Score, atleast one one from FSL orRPM satisfaction score should exist along with Renewal Intent. If either of them is mssing, 
//we do not calculate CS Score  

	
//Calculates the Lease Customer Satisfaction score based on the results of the 7 questions
//answered during the survey.  This score is based on the direct synchronization of these questions
//from ClickTools into SFDC.  It is not intended to be the final result of the CS Index that is separately
//being prepared based on results that will eventually be migrated from CT to SFDC using the Ryder Survey Responses.

List<Ryder_Surveys__c> listofSurveys = new List<Ryder_Surveys__c>();
List<Customer_Branch__c> listofCustomerBranches = new List<Customer_Branch__c>();
//Integer CS_Score;
Integer cnt = 0;
//Decimal running_avg = 0.0;
Decimal overallSat = 0.0;
Decimal csScore = 0.0;
Decimal num1 = 0.0;
Decimal num2 = 0.0;
Decimal num3 = 0.0;
private string DONT_KNOW = 'Don\'t Know';
Customer_Branch__c cb;
boolean bCalculate = false;

	for (Ryder_Surveys__c rs:trigger.new)
	{
		//08/23/2012-Saad-calculate only if the following fields change.
	    if(Trigger.isInsert || (Trigger.isUpdate &&
	      (rs.Customer_Sat_Overall_Satisfaction_FSL__c !=trigger.oldMap.get(rs.Id).Customer_Sat_Overall_Satisfaction_FSL__c ||
	      rs.Customer_Sat_Overall_Satisfaction_RPM__c !=trigger.oldMap.get(rs.Id).Customer_Sat_Overall_Satisfaction_RPM__c ||
	      rs.Customer_Sat_Likelihood_to_Renew__c !=trigger.oldMap.get(rs.Id).Customer_Sat_Likelihood_to_Renew__c)))
	      bCalculate=true;
      
		if( bCalculate &&(((rs.Customer_Sat_Overall_Satisfaction_FSL__c != NULL) || (rs.Customer_Sat_Overall_Satisfaction_RPM__c != NULL)) 
		&& ((rs.Customer_Sat_Likelihood_to_Renew__c != NULL))))
		{
			system.debug('Inside Calculation');
			if (rs.Customer_Sat_Overall_Satisfaction_FSL__c != NULL && rs.Customer_Sat_Overall_Satisfaction_FSL__c != DONT_KNOW && rs.Customer_Sat_Overall_Satisfaction_FSL__c >= '0' && rs.Customer_Sat_Overall_Satisfaction_FSL__c <= '99' )
			{
			    num1 = Integer.valueof(rs.Customer_Sat_Overall_Satisfaction_FSL__c);
			    cnt++;
			}
			if (rs.Customer_Sat_Overall_Satisfaction_RPM__c != NULL && rs.Customer_Sat_Overall_Satisfaction_RPM__c != DONT_KNOW  && rs.Customer_Sat_Overall_Satisfaction_RPM__c>='0' && rs.Customer_Sat_Overall_Satisfaction_RPM__c<='99')
			{
			    num2 = Integer.valueof(rs.Customer_Sat_Overall_Satisfaction_RPM__c);
			    cnt++;
			}   
			if (cnt == 0)
			{
				csScore = 0;
			}
			else if (cnt > 0)
			{
				overallSat = ((num1 + num2)/cnt);
				
				if (rs.Customer_Sat_Likelihood_to_Renew__c != NULL && rs.Customer_Sat_Likelihood_to_Renew__c != DONT_KNOW  && rs.Customer_Sat_Likelihood_to_Renew__c>='0' && rs.Customer_Sat_Likelihood_to_Renew__c<='99')
				{
				    num3 = Integer.valueof(rs.Customer_Sat_Likelihood_to_Renew__c);
				    cnt++;
				}
				if (num3 > 0)
				{
					csScore = ((num3 + overallSat)/2)*10;
				}
				else
				{
					csScore = 0;
				}
				rs.CS_Score__c = csScore;
				/*if (csScore == 0)
		        {
		          return null;
		        }
		        else
		        {
					rs.CS_Score__c = csScore*10;
		        }*/ 
			}
			if (rs.Customer_Branch__c != NULL) cb = new Customer_Branch__c(id=rs.Customer_Branch__c);
		    if (cb != NULL)
	    	{
		        cb.Lease_CS_Score__c = csScore;
		        listofCustomerBranches.add(cb);
		        System.debug('****Updating Customer Branches' + listofCustomerBranches);
		        if (listofCustomerBranches!=null && !listofCustomerBranches.isEmpty()) 
		        {
		            System.debug('Updating Lease Customer Sat Score on Customer Branch');
		            try {update listofCustomerBranches;} catch(Exception e){system.debug(e);}
		        }
	    	}
	  	}
  		else rs.CS_Score__c = NULL;
	}
}
      
    	/*// 02/15/2012-neelima- calculate only if the following fields change.
		if(Trigger.isInsert || (Trigger.isUpdate &&
		  (rs.Customer_Sat_Overall_Satisfaction_FSL__c !=trigger.oldMap.get(rs.Id).Customer_Sat_Overall_Satisfaction_FSL__c ||
		  rs.Customer_Sat_Overall_Satisfaction_RPM__c !=trigger.oldMap.get(rs.Id).Customer_Sat_Overall_Satisfaction_RPM__c ||
		  rs.Customer_Sat_Likelihood_to_Renew__c !=trigger.oldMap.get(rs.Id).Customer_Sat_Likelihood_to_Renew__c||
		  rs.Customer_Sat_Willingness_to_Refer__c !=trigger.oldMap.get(rs.Id).Customer_Sat_Willingness_to_Refer__c ||
		  rs.Customer_Sat_Shop_Communications__c !=trigger.oldMap.get(rs.Id).Customer_Sat_Shop_Communications__c ||
		  rs.Customer_Sat_Maintenance_Satisfaction__c !=trigger.oldMap.get(rs.Id).Customer_Sat_Maintenance_Satisfaction__c ||
		  rs.Customer_Sat_Acct_Mgr_Satisfaction__c !=trigger.oldMap.get(rs.Id).Customer_Sat_Acct_Mgr_Satisfaction__c)))
		  bCalculate=true;*/
    
		/*  if( bCalculate &&(((rs.Customer_Sat_Overall_Satisfaction_FSL__c != NULL) || (rs.Customer_Sat_Overall_Satisfaction_RPM__c != NULL)) 
		&& ((rs.Customer_Sat_Likelihood_to_Renew__c !=NULL) || (rs.Customer_Sat_Willingness_to_Refer__c != NULL) 
		|| (rs.Customer_Sat_Shop_Communications__c !=NULL) || (rs.Customer_Sat_Maintenance_Satisfaction__c != NULL)
		|| (rs.Customer_Sat_Acct_Mgr_Satisfaction__c != NULL))))
		{
		system.debug('Inside Calculation');
		if (rs.Customer_Sat_Overall_Satisfaction_FSL__c != NULL && rs.Customer_Sat_Overall_Satisfaction_FSL__c>='0' && rs.Customer_Sat_Overall_Satisfaction_FSL__c <='99' )
		{
		    running_avg = Integer.valueof(rs.Customer_Sat_Overall_Satisfaction_FSL__c);
		    cnt++;
		}
		if (rs.Customer_Sat_Overall_Satisfaction_RPM__c != NULL && rs.Customer_Sat_Overall_Satisfaction_RPM__c>='0' && rs.Customer_Sat_Overall_Satisfaction_RPM__c<='99')
		{
		    running_avg = running_avg + Integer.valueof(rs.Customer_Sat_Overall_Satisfaction_RPM__c);
		    cnt++;
		}   
		if (rs.Customer_Sat_Likelihood_to_Renew__c != NULL && rs.Customer_Sat_Likelihood_to_Renew__c>='0' && rs.Customer_Sat_Likelihood_to_Renew__c<='99')
		{
		    running_avg = running_avg + Integer.valueof(rs.Customer_Sat_Likelihood_to_Renew__c);
		    cnt++;
		}
		if (rs.Customer_Sat_Willingness_to_Refer__c != NULL && rs.Customer_Sat_Willingness_to_Refer__c>='0'  && rs.Customer_Sat_Willingness_to_Refer__c<='99')
		{
		    running_avg = running_avg + Integer.valueof(rs.Customer_Sat_Willingness_to_Refer__c);
		    cnt++;
		}
		if (rs.Customer_Sat_Shop_Communications__c != NULL && rs.Customer_Sat_Shop_Communications__c>='0' && rs.Customer_Sat_Shop_Communications__c<='99')
		{
		    running_avg = running_avg + Integer.valueof(rs.Customer_Sat_Shop_Communications__c);
		    cnt++;
		}
		if (rs.Customer_Sat_Maintenance_Satisfaction__c != NULL && rs.Customer_Sat_Maintenance_Satisfaction__c>='0' && rs.Customer_Sat_Maintenance_Satisfaction__c<='99')
		{
		    running_avg = running_avg + Integer.valueof(rs.Customer_Sat_Maintenance_Satisfaction__c);
		    cnt++;
		}
		if (rs.Customer_Sat_Acct_Mgr_Satisfaction__c != NULL && rs.Customer_Sat_Acct_Mgr_Satisfaction__c>='0' && rs.Customer_Sat_Acct_Mgr_Satisfaction__c<='99')
		{
		    running_avg = running_avg + Integer.valueof(rs.Customer_Sat_Acct_Mgr_Satisfaction__c);
		    cnt++;
		}
    
    //Avoid Div by 0
    if (cnt==0) cnt = 1;

    running_avg = (running_avg/cnt) * 10;    
    rs.CS_Score__c = running_avg;
    if (rs.Customer_Branch__c != NULL) cb = new Customer_Branch__c(id=rs.Customer_Branch__c);
    if (cb != NULL)
    {
        cb.Lease_CS_Score__c = running_avg;
        listofCustomerBranches.add(cb);
        System.debug('****Updating Customer Branches' + listofCustomerBranches);
        if (listofCustomerBranches!=null && !listofCustomerBranches.isEmpty()) 
        {
            System.debug('Updating Lease Customer Sat Score on Customer Branch');
            try {update listofCustomerBranches;} catch(Exception e){system.debug(e);}
        }
    }
  }
  // 29March2012 - neelima-commented out the following logic to avoid resetting the already calculated score to null during ryder survey updates.
  //else rs.CS_Score__c = NULL;
}
    
}*/