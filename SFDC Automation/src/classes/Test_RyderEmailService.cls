/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_RyderEmailService {

    static testMethod void SendMail() 
    {
		RyderEmailService.SendEmailResponse_element resp = new RyderEmailService.SendEmailResponse_element();
		RyderEmailService.SendEmail_element ele = new RyderEmailService.SendEmail_element();
		RyderEmailService.RyderEmailServiceSoap sop = new RyderEmailService.RyderEmailServiceSoap();
        RyderEmailService.CRMCredential credential = new RyderEmailService.CRMCredential();
       	RyderEmailService.RyderEmailServiceSoap emailSvc = new RyderEmailService.RyderEmailServiceSoap();
       	RyderEmailService.DCRyderEmailResponseData mailResp = new RyderEmailService.DCRyderEmailResponseData();
       	credential.UserName = '';
		credential.Password = '';
		credential.SecurityToken = '';
       	emailSvc.endpoint_x = RyderGlobalVariables.RYDER_WS_ENDPOINT + RyderGlobalVariables.SEND_RYDER_EMAIL;
       	RyderEmailService.RyderEmailRequestData emailData = new RyderEmailService.RyderEmailRequestData();
       	List<RyderEmailService.Email> emailList = new List<RyderEmailService.Email>();
		RyderEmailService.Email emailReq = new  RyderEmailService.Email();
		emailReq.FromId = 'test@abc.com';
		emailReq.EmailIds = 'baskar.venugopal@hcl.com';
		emailReq.Subject = 'Test Subject';
		emailReq.Message = 'Test Message';
		emailReq.MessageBody = '';
		emailReq.Type_x = 'HTML';
		emailReq.Caller = 'CASE';
		emailList.add(emailReq);     
		RyderEmailService.ArrayOfEmail emailArray = new RyderEmailService.ArrayOfEmail();
		system.debug('Email List' + emailList);
		emailArray.Email = emailList;
		emailData.Emails = emailArray;
       	mailResp =emailSvc.SendEmail(credential, emailData);
       
    }
}