@isTest
public class PerformanceInformationRollupTest
{
	static testmethod void unitTest()
	{
		RSMCreateTestData.GetCustomSettingsRecord();
		Account ac=new Account();
		ac.Name='Test Acc';
		ac.LesseeNo__c = '123';
        ac.RSM_CCMs__c = UserInfo.getUserId();
        ac.RSM_Onboarding__c = '';
        ac.RSM_AC_Classification__c  =  'National';
        ac.UpdatedFSLRPMFields__c = true;
		insert ac;
		
		Vehicle__c v=new Vehicle__c();
		v.Account__c=ac.Id;
		v.Last_12_Months_Fixed_Cost__c=100;
		v.Last_12_Months_Rated_Cost__c=100;
		v.Last_12_Months_Revenue__c=100;
		v.Life_to_Date_Fixed_Cost__c=100;
		v.Life_to_Date_Rated_Cost__c=100;
		v.Life_to_Date_Revenue__c=100;
		insert v;
		
		Vehicle__c v1=new Vehicle__c();
		v1.Account__c=ac.Id;
		v1.Last_12_Months_Fixed_Cost__c=100;
		v1.Last_12_Months_Rated_Cost__c=100;
		v1.Last_12_Months_Revenue__c=100;
		v1.Life_to_Date_Fixed_Cost__c=100;
		v1.Life_to_Date_Rated_Cost__c=100;
		v1.Life_to_Date_Revenue__c=100;
		v1.Product_line__c='FSL';
		insert v1;
		
		Vehicle__c v2=new Vehicle__c();
		v2.Account__c=ac.Id;
		v2.Last_12_Months_Fixed_Cost__c=100;
		v2.Last_12_Months_Rated_Cost__c=100;
		v2.Last_12_Months_Revenue__c=100;
		v2.Life_to_Date_Fixed_Cost__c=100;
		v2.Life_to_Date_Rated_Cost__c=100;
		v2.Life_to_Date_Revenue__c=100;
		v2.Product_line__c='RPM';
		insert v2;
		
		Vehicle__c v3=new Vehicle__c();
		v3.Account__c=ac.Id;
		v3.Last_12_Months_Fixed_Cost__c=100;
		v3.Last_12_Months_Rated_Cost__c=100;
		v3.Last_12_Months_Revenue__c=100;
		v3.Life_to_Date_Fixed_Cost__c=100;
		v3.Life_to_Date_Rated_Cost__c=100;
		v3.Life_to_Date_Revenue__c=100;
		insert v3;
		
		Vehicle__c v4=new Vehicle__c();
		v4.Account__c=ac.Id;
		v4.Last_12_Months_Fixed_Cost__c=100;
		v4.Last_12_Months_Rated_Cost__c=100;
		v4.Last_12_Months_Revenue__c=100;
		v4.Life_to_Date_Fixed_Cost__c=100;
		v4.Life_to_Date_Rated_Cost__c=100;
		v4.Life_to_Date_Revenue__c=100;
		v4.Product_line__c='FSL';
		insert v4;
		
		Vehicle__c v5=new Vehicle__c();
		v5.Account__c=ac.Id;
		v5.Last_12_Months_Fixed_Cost__c=100;
		v5.Last_12_Months_Rated_Cost__c=100;
		v5.Last_12_Months_Revenue__c=100;
		v5.Life_to_Date_Fixed_Cost__c=100;
		v5.Life_to_Date_Rated_Cost__c=100;
		v5.Life_to_Date_Revenue__c=100;
		v5.Product_line__c='RPM';
		insert v5;
		
		
		AccountFSLRPMFieldCalculationBatch AccFSLRPMFieldCalObj = new AccountFSLRPMFieldCalculationBatch(); 
        database.executebatch(AccFSLRPMFieldCalObj,1);
	
	}
}