public class tokenGeneratorCalloutController{

    public tokenGeneratorCalloutController(){
        this.token = null;
    }

    public String token{get;private set;}

    public void callTokenWS(){
            TokenAuth.RyderAuthenticationServiceSoap ta = new TokenAuth.RyderAuthenticationServiceSoap();
            TokenAuth.RyderAuthUserOnlyRequestCriteria req = new TokenAuth.RyderAuthUserOnlyRequestCriteria();
            TokenAuth.RyderCredential cc = new tokenauth.RyderCredential ();
            cc.SharedToken='0c21b141395512be1367136583d514ca';
            TokenAuth.RyderAuthResponse rar;
            req.Source = 'MOBILE';
            //req.Username = 'testuser@ryder.com';
            req.username = userinfo.getUserName();
            
            rar = ta.ProcessRequest(cc, req);
            System.debug('=====RyderAuthResponse: ' + rar);
            this.token = rar.RyderUserToken;
            
    }

    public static testmethod void getsettoken(){
        PageReference pageRef = Page.tokenDisplay;
        Test.setCurrentPage(pageRef);

        tokenGeneratorCalloutController c = new tokenGeneratorCalloutController();
        System.assert(c.token ==null);
        c.callTokenWS();
        System.assert(c.token !=null);
    }
    
    public static testmethod void test1(){
        TokenAuth.RyderAuthResponse rar = new tokenauth.RyderAuthResponse();
        TokenAuth.RequestData rd = new tokenauth.RequestData();
        tokenauth.ProcessRequest_element pre = new tokenauth.ProcessRequest_element();
        tokenauth.ProcessRequestResponse_element prre = new tokenauth.ProcessRequestResponse_element();     
    }

}