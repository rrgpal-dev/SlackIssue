@RestResource(urlMapping='/slackeventlistener/*')
//  https://sdo-demo-main-166ce2cf6b6-17-178c766e471.secure.force.com/slackdemoendpoints/services/apexrest/slackeventlistener

global without sharing class SlackEventListener {
    @HttpPost
    @AuraEnabled
    global static void handlePost() {
        System.debug('here1');
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        
        Map<String, String> headers = req.headers;
        String httpMethod           = req.httpMethod;
        String remoteAddress        = req.remoteAddress;
        String requestURI           = req.requestURI;
        String resourcePath         = req.resourcePath;
        Map<String, String> params  = req.params;   //used by events
        String body                 = req.requestBody?.toString(); //used by URL verification / challenge
        
        Map<String, Object> bodyMap = new Map<String, Object>();
        try {
            bodyMap = (Map<String, Object>)JSON.deserializeUntyped(body);
        } catch (Exception e){
            System.debug(e);
        }
               
        Long reqTimestamp = headers.containsKey('X-Slack-Request-Timestamp') ? Long.valueOf(headers.get('X-Slack-Request-Timestamp')) : null;
        String slackSignature = headers.containsKey('X-Slack-Signature') ? headers.get('X-Slack-Signature') : null;
        System.debug('Pre VR response');
        SlackRequestValidator.ValidationResponse vr = SlackRequestValidator.validateRequest('IngoXMCv9vhdnTCc02Unkgvr', body, reqTimestamp, slackSignature);
        
        String outerEventType = '';
        if (bodyMap.containsKey('type')) {
            outerEventType = (String)bodyMap.get('type');
        }
        
        String innerEventType = '';
        String subtype = '';
        if (bodyMap.containsKey('event')) {
            Map<String, Object> eventObj = (Map<String, Object>)bodyMap.get('event');
            innerEventType = (String)eventObj.get('type');
            if (eventObj.containsKey('subtype')) {
                subtype = (String)eventObj.get('subtype');
            }
        }
        String userName = '';
        if (bodyMap.containsKey('event')) {
            Map<String, Object> eventObj = (Map<String, Object>)bodyMap.get('event');
            userName = (String)eventObj.get('user');
        }
        
        /*  insert new Slack_Payload__c(
        Calculated_Signature__c                 = vr.calculatedSignature,
        Signed_Request_Verification_Passed__c   = vr.isValid,
        Verification_Failure__c                 = vr.failureType,
        Outer_Event__c  = outerEventType,
        Inner_Event__c  = innerEventType,
        Subtype__c      = subtype,
        Headers__c      = (headers != null) ? JSON.serializePretty(headers) : null,
        HTTP_Method__c  = httpMethod,
        Remote_IP__c    = remoteAddress,
        Request_URI__c  = requestURI,
        Path__c         = resourcePath,
        Params__c       = (params != null) ? JSON.serializePretty(params) : null,
        Raw_Body_Hex__c = (req.requestBody) != null ? EncodingUtil.convertToHex(req.requestBody) : null,
        Raw_Body__c     = body,
        Body__c         = (!bodyMap.keySet().isEmpty()) ? JSON.serializePretty(bodyMap) : null
        ); */
        switch on outerEventType {
            when 'url_verification' {
                //first time setting up an Events Endpoint, this gets invoked to make sure it's legit
                urlVerification(res, bodyMap);
            }
           
            
        }
        try {
            switch on innerEventType {
                
                when 'app_mention' {
                    //first time setting up an Events Endpoint, this gets invoked to make sure it's legit
                    // System.debug('Call back');
                    
                //testChannelCreation(userName);
       
                    SlackController.sendMessage('5005e00000Eh61jAAB');
                    //updatecase();
                    
                }
                when 'member_joined_channel' {
                    //first time setting up an Events Endpoint, this gets invoked to make sure it's legit
                    System.debug('Call back');
                    // SlackController.sendMessageBack('5005e00000Eh61jAAB');
                }
                when 'app_home_opened' {
                    //first time setting up an Events Endpoint, this gets invoked to make sure it's legit
                    System.debug('Call back');
                    // SlackController.sendMessageBack('5005e00000Eh61jAAB');
                }
            }
        }
        
        catch(DmlException e) {
            
            insert new DebugLog__c(
                Debug_details__c                 = e.getMessage()
            );
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
    }
    
    public static void urlVerification(RestResponse res, Map<String, Object> bodyParams) {
        //echo back the challenge value from the parameters in the body
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf((String)bodyParams.get('challenge'));
    }
    
    public static void testChannelCreation(String userName) {
        String token = 'Bearer xoxb-2099680222902-3281750604020-73mIGDtoiAx7Zs9QwrQoOAcK';
        Integer randomNum = Integer.valueOf(Math.random()*10000);
        String name = 'A-Platform-event-'+String.valueOf(randomNum);


        String channelId = SlackAPIHelper.createChannel('5005e00000Eh61jAAB', token);
        HttpRequest req1 = new HttpRequest();
        req1.setEndpoint('https://slack.com/api/conversations.create?name='+name+'&is_private=true&pretty=1');
        req1.setMethod('POST');
        req1.setHeader('Authorization', token);
        Http http = new Http();
     HttpResponse res1;
        try{
              res1 = http.send(req1);
        }
        catch (Exception e)
        {
            insert new DebugLog__c(
                Debug_details__c                 = 'Exception: https://slack.com/api/conversations.create?name='+name+'&is_private=true&pretty=1');  
            insert new DebugLog__c(
                Debug_details__c                 = e.getMessage());   
        }
        
        
        Case case1 = [SELECT Id, Priority, CaseNumber, Subject,  Description, Reason, Account.Name, AccountId, DateTime_Opened_c__c FROM Case WHERE Id =: '5005e00000Eh61jAAB'];
        
        String caseRecordLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+case1.Id;
        String accountRecordLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+case1.AccountId;
        
        
        List<String> emails = new List<String>{'smith.e@salesforce.com', 'raj.ramachandran@salesforce.com','aobajuluwa@salesforce.com'};
            
         channelId = SlackAPIHelper.createChannel(name, token);
        String userIds = SlackAPIHelper.getIds(emails, token)+','+userName;
        String titleBlock = SlackJSONHelper.createTitleBlock();
        String caseBlock = SlackJSONHelper.createCaseBlock(caseRecordLink, name);
        String caseDetailBlock = SlackJSONHelper.createCaseDetailBlock(case1.Subject, case1.Priority, case1.Account.Name, case1.DateTime_Opened_c__c, case1.Description);
        String accountBlock = SlackJSONHelper.createAccountBlock(accountRecordLink, case1.Account.Name);
        String message = EncodingUtil.urlEncode('['+titleBlock+','+caseBlock+','+caseDetailBlock+','+accountBlock+']', 'UTF-8');
        
        HttpResponse res = SlackAPIHelper.sendMessage(channelId, message, token);
        
        SlackAPIHelper.pinMessage(channelId, token, res);
        SlackAPIHelper.addUsers(channelId, token, userIds);
        
        insert new DebugLog__c(
            Debug_details__c                 = '--------------------------------------------------------');  
        //    insert new DebugLog__c(
        //          Debug_details__c             = 'Response Body:'+ res1.getBody() +' Whole Response:' + res1.toString());    
        insert new DebugLog__c(
            Debug_details__c                 = '--->>>>Request EndPoint:' + req1.getEndpoint());  
  
        insert new DebugLog__c(
            Debug_details__c                 = 'Request Body:' +req1.getBody());   
        insert new DebugLog__c(
            Debug_details__c                 = 'userIds:'+ userIds);  
        insert new DebugLog__c(
            Debug_details__c                 = 'message'+ message);  
        insert new DebugLog__c(
            Debug_details__c                 = 'message Post Response:'+ res.toString());  
        insert new DebugLog__c(
            Debug_details__c                 = '--------------------------------------------------------');  
    }
    
    public static void updatecase() {
        try{
            Case case1 = [SELECT Id, Priority, CaseNumber, Subject,  Description, Reason, Account.Name, AccountId, DateTime_Opened_c__c FROM Case WHERE Id =: '5005e00000Eh61jAAB'];
            case1.Priority = 'Critical';
            update case1;
            insert new DebugLog__c(
                Debug_details__c                 = 'Success');   
        }
        catch (Exception e)
        {
            
            insert new DebugLog__c(
                Debug_details__c                 = e.getMessage());   
        }
        
    }
    
}