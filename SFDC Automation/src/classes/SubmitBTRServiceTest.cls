@isTest(seeAlldata = true)
public with sharing class SubmitBTRServiceTest
{
	static User uvsUser;
	static testMethod void submitBTRTest()
	{
 		UserRole userRoleId_fam = [select Id from UserRole where name = 'VSM/VSR Calgary'];

        User sysAdmin_fam = TestUtilUvs.createAdminUser(false);
        sysAdmin_fam.UserRoleId = userRoleId_fam.id;
        sysAdmin_fam.Username = 'uvs@rydertest_fam.com';                        
        insert sysAdmin_fam;

		UserRole userRoleId_dam = [select Id from UserRole where name = 'DAM Canada'];
        User sysAdmin_dam = TestUtilUvs.createAdminUser(false);
        sysAdmin_dam.UserRoleId = userRoleId_dam.id;
        sysAdmin_dam.Username = 'uvs@rydertest_dam.com';
        insert sysAdmin_dam;            
            
        UserRole userRoleId_vam = [select Id from UserRole where name = 'VP Asset Management'];
        User sysAdmin_vam = TestUtilUvs.createAdminUser(false);
        sysAdmin_vam.UserRoleId = userRoleId_vam.id;
        sysAdmin_vam.Username = 'uvs@rydertest_vam.com';
        insert sysAdmin_vam;
        
		//uvsUser = TestUtilUVS.createUser(true);
  		system.runAs(sysAdmin_fam)
  		{			
	    	Product2 prod = new Product2();
	      	prod.Name = 'Standard Price Book UVS'; 
	      	prod.CurrencyIsoCode = 'CAD';
	      	insert prod;
	            
	    	PriceBookEntry pbe = [SELECT Id, Pricebook2Id FROM PriceBookEntry WHERE Product2Id = :prod.Id LIMIT 1];
	      	pbe.isActive = true;
	      	update pbe;   
	    
	    	Quote q = TestUtilUVS.createQuote('UVS',false);
	    	q.Pricebook2Id = pbe.Pricebook2Id;
	    	q.Requester_Comments__c = 'test' ;
	    	insert q;
	    
	        BTR__c btr = new BTR__c();
	        btr.Status__c = 'Submitted - With FAM';
	        btr.quote__c = q.id;
	        btr.Third_Approver__c = sysAdmin_vam.id;
	        btr.First_Approver__c= sysAdmin_fam.id;
	        btr.Second_Approver__c= sysAdmin_dam.id;
	        insert btr;
	                
	    	test.starttest();            
	    	QuoteLineItem qLI = new QuoteLineItem();
	    	qli.Approval_Level__c=2;
	    	qLi.QuoteId = q.Id;
	    	qLi.PricebookEntryId = pbe.Id;
	    	qLi.Product2Id = prod.id;
	    	qLi.Quantity = 123;
	    	qLi.UnitPrice = 100; 
	   	 	insert qLI;
	    	SubmitBTRService.checkAlreadySubmitted(q.id);
	    	SubmitBTRService.CheckIfQLIHasZeroSalesPrice(q.id);
	    	 
	    	if (UVS_Approval_Setting__c.getInstance() == null)
	    	{
	      		insert new UVS_Approval_Setting__c(Role_Names__c = 'VSM/VSR Calgary;VSM/VSR Dartmouth;VSM/VSR London;VSM/VSR Montreal;VSM/VSR Toronto;VSM/VSR Vancouver;VSM/VSR Export;DAM Canada;DAM Export');
	    	}
	    	SubmitBTRService.submitBTR(q.id);
	    
	    	
	    	qli.Approval_Level__c=3;
	   	 	update qli;
	    	SubmitBTRService.submitBTR(q.id);       
	    
	    	q.Requester_Comments__c = '' ;
	    	update q;
	    	SubmitBTRService.submitBTR(q.id) ;
	    
	    	btr.Status__c = 'Approved';
	    	update btr;
	    	SubmitBTRService.checkAlreadySubmitted(q.id); 
	    	SubmitBTRService.checkAlreadySubmitted('test'); 
	    	SubmitBTRService.submitBTR(q.id);
	    
	    	q.status = 'Denied';
	    	update q;
	    	qli.Approval_Level__c=0;
	    	update qli;
	    	SubmitBTRService.submitBTR(q.id);
	    
	    	qli.UnitPrice = 0;
	    	update qli;
	    	SubmitBTRService.CheckIfQLIHasZeroSalesPrice(q.id);
	     
	    	test.stoptest(); 
	  	}   
 	}
 	static testMethod void Test_SubmitBTRifBTRExistWithSubmitStatus()
 	{
		UserRole userRoleId_fam = [select Id from UserRole where name = 'VSM/VSR Calgary'];

        User sysAdmin_fam = TestUtilUvs.createAdminUser(false);
        sysAdmin_fam.UserRoleId = userRoleId_fam.id;
        sysAdmin_fam.Username = 'uvs@rydertest_fam.com';                        
        insert sysAdmin_fam;

		UserRole userRoleId_dam = [select Id from UserRole where name = 'DAM Canada'];
        User sysAdmin_dam = TestUtilUvs.createAdminUser(false);
        sysAdmin_dam.UserRoleId = userRoleId_dam.id;
        sysAdmin_dam.Username = 'uvs@rydertest_dam.com';
        insert sysAdmin_dam;            
            
        UserRole userRoleId_vam = [select Id from UserRole where name = 'VP Asset Management'];
        User sysAdmin_vam = TestUtilUvs.createAdminUser(false);
        sysAdmin_vam.UserRoleId = userRoleId_vam.id;
        sysAdmin_vam.Username = 'uvs@rydertest_vam.com';
        insert sysAdmin_vam;
        
        Account Acc1 = new Account();
        Acc1.name = 'Test';
        Acc1.account_classification__c = 'Key Account';
        Acc1.central_decisionmaking__c = False;
        Acc1.Type = 'Customer';
        Acc1.Account_Classification__c = 'National';
        Acc1.LesseeNo__c = '0123123';
        insert Acc1;
        Acc1.Account_Classification__c = 'Local';
        update Acc1;
    	
    	Customer_Branch__c CustomerBranch = new Customer_Branch__c();
	    CustomerBranch.Name = 'Test Customer Branch';
	    CustomerBranch.Ryder_HQ_Account__c = Acc1.Id;
	    insert CustomerBranch;
	    
    	Vehicle__c Vehicle = new Vehicle__c(Unit__c = '123456');
	    Vehicle.Name = '1234';
	    Vehicle.CUSTOMER_BRANCH__c = CustomerBranch.Id;
	    Vehicle.RSM__c = 'Approved';
	    Vehicle.Account__c = Acc1.Id;
	    insert Vehicle;
	    Vehicle.CUSTOMER_BRANCH__c = CustomerBranch.Id;
	    Vehicle.Days_At_UTC__c = 110;
		update Vehicle;
		
		//uvsUser = TestUtilUVS.createUser(true);
  		system.runAs(sysAdmin_fam)
  		{
	    	Product2 prod = new Product2();
	      	prod.Name = 'Standard Price Book UVS'; 
	      	prod.CurrencyIsoCode = 'CAD';
	      	insert prod;
	            
	    	PriceBookEntry pbe = [SELECT Id, Pricebook2Id FROM PriceBookEntry WHERE Product2Id = :prod.Id LIMIT 1];
	      	pbe.isActive = true;
	      	update pbe;   
	    
	    	Quote q = TestUtilUVS.createQuote('UVS',false);
	    	q.Pricebook2Id = pbe.Pricebook2Id;
	    	q.Requester_Comments__c = 'test' ;
	    	insert q;
	    	
	        BTR__c btr = new BTR__c();
	        btr.Status__c = 'Submitted - With FAM';
	        btr.quote__c = q.id;
	        btr.Third_Approver__c = sysAdmin_vam.id;
	        btr.First_Approver__c= sysAdmin_fam.id;
	        btr.Second_Approver__c= sysAdmin_dam.id;
	        insert btr;
	                
	    	test.starttest();
	    	
		    	QuoteLineItem qLI = new QuoteLineItem();
		    	qli.Approval_Level__c = 1;
		    	qLi.QuoteId = q.Id;
		    	qLi.PricebookEntryId = pbe.Id;
		    	qLi.Product2Id = prod.id;
		    	qLi.Quantity = 1;
		    	qLi.UnitPrice = 10; 
		    	qLi.Take_Price2__c = 2;
		    	qLI.Vehicle__c = Vehicle.Id;		    	
		   	 	insert qLI;
		   	 	
		    	if (UVS_Approval_Setting__c.getInstance() == null)
		    	{
		      		insert new UVS_Approval_Setting__c(Role_Names__c = 'VSM/VSR Calgary;VSM/VSR Dartmouth;VSM/VSR London;VSM/VSR Montreal;VSM/VSR Toronto;VSM/VSR Vancouver;VSM/VSR Export;DAM Canada;DAM Export');
		    	}
		    	// There is already a existing submitted BTR now if the user submit a new BTR the previous one should become Rejected
		    	String sMSG = SubmitBTRService.submitBTR(q.id);
		    	system.debug('---------sMSG->'+sMSG);
				List<BTR__c> lBTR = [select Id, Status__c from BTR__c where Id =: btr.Id];
				
				if(lBTR != null && lBTR.size() > 0)
					System.assertEquals('Rejected', lBTR[0].Status__c);
	     
	    	test.stoptest(); 
	  	}
	}
}