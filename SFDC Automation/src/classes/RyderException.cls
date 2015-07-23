public with sharing class RyderException extends Exception{
	
    public String dbResponse {get; set;}
    public String dbRequest {get; set;}
    public String dbCall {get; set;}
    public String errorMessage {get; set;}
    
    public RyderException(String errorMessage, String dbCall, String dbRequest, String dbResponse) {
    	this.dbCall = dbCall;
    	this.dbRequest = dbRequest;
    	this.dbResponse = dbResponse;
    	this.errorMessage = errorMessage;
    }
}