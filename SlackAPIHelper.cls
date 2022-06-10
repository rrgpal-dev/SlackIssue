public class SlackAPIHelper {
    
    public static String createChannel(String channelName, String token){
        Integer randomNum = Integer.valueOf(Math.random()*1000);
        String name = 'case-swarm-'+channelName+'-'+String.valueOf(randomNum);
        String channelId;
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://slack.com/api/conversations.create?name='+name+'&is_private=true&pretty=1');
       // req.setEndpoint('https://slack.com/api/conversations.create?name=case-swarm-blah-3555&is_private=true&pretty=1');
        req.setMethod('POST');
        req.setHeader('Authorization', token);
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            JSONParser parser = JSON.createParser(res.getBody());
            while(parser.nextToken() != null){
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String fieldName = parser.getText();
                    parser.nextToken();
                    if(fieldName == 'id'){
                        System.debug('id: '+parser.getText());
                        channelId = parser.getText();
                    }
                }
            }
        } catch (Exception e)
        {
            insert new DebugLog__c(
                Debug_details__c                 = 'https://slack.com/api/conversations.create?name='+name+'&is_private=true&pretty=1');
            insert new DebugLog__c(
                Debug_details__c                 = 'Exception Message:' + e.getMessage());  
            
        }
        
        
        //  System.debug(res.getBody());
        
        
        
        return(channelId);
    }
    
    @future(callout = true)
    public static void createChannelCallout(String channelName, String token){
        
        String channelId;
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://slack.com/api/conversations.create?name='+channelName+'&is_private=true&pretty=1');
        req.setMethod('POST');
        req.setHeader('Authorization', token);
        Http http = new Http();
        HttpResponse res;
        try {
           res = http.send(req);
         
        } catch (Exception e)
        {
            insert new DebugLog__c(
                Debug_details__c                 = 'https://slack.com/api/conversations.create?name='+channelName+'&is_private=true&pretty=1');
            insert new DebugLog__c(
                Debug_details__c                 = 'Exception Message:' + e.getMessage());  
            
        }
        //insert new DebugLog__c(Debug_details__c = res.getBody());

        JSONParser parser = JSON.createParser(res.getBody());
        while(parser.nextToken() != null){
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String fieldName = parser.getText();
                parser.nextToken();
                if(fieldName == 'id'){
                    System.debug('id: '+parser.getText());
                    channelId = parser.getText();
                }
            }
        }
        
    }
    
    public static void pinMessage(String channelId, String token, HttpResponse createRes){
        String ts;
        
        JSONParser parser = JSON.createParser(createRes.getBody());
        while(parser.nextToken() != null){
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String fieldName = parser.getText();
                parser.nextToken();
                if(fieldName == 'ts'){
                    System.debug('ts: '+parser.getText());
                    ts = parser.getText();
                }
            }
        }
        
        System.debug(ts);
        
        HttpRequest pinReq = new HttpRequest();
        pinReq.setEndpoint('https://slack.com/api/pins.add?channel='+channelId+'&timestamp='+ts+'&pretty=1');
        pinReq.setMethod('POST');
        pinReq.setHeader('Authorization', token);
        Http pinHttp = new Http();
        HttpResponse pinRes = pinHttp.send(pinReq);
        System.debug('pinReq: '+pinRes);
    }
    
    public static void addUsers(String channelId, String token, String userIds){
        HttpRequest inviteReq = new HttpRequest();
        inviteReq.setEndpoint('https://slack.com/api/conversations.invite?channel='+channelId+'&users='+userIds+'&pretty=1&team_id=T022XL06JSJ');
        inviteReq.setMethod('POST');
        inviteReq.setHeader('Authorization', token);
        Http inviteHttp = new Http();
        HttpResponse inviteRes = inviteHttp.send(inviteReq);
        System.debug(inviteRes.getBody());
    }
    
    public static String getIds(List<String> emails, String token){
        String userIds = '';
        
        for(String email:emails){
            String userId;
            HttpRequest emailReq = new HttpRequest();
            emailReq.setEndpoint('https://slack.com/api/users.lookupByEmail?email='+email+'&pretty=1');
            emailReq.setMethod('GET');
            emailReq.setHeader('Authorization',token);
            Http emailHttp = new Http();
            HttpResponse emailRes = emailHttp.send(emailReq);
            System.debug(emailRes.getBody());
            JSONParser parser = JSON.createParser(emailRes.getBody());
            while(parser.nextToken() != null){
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String fieldName = parser.getText();
                    parser.nextToken();
                    if(fieldName == 'id'){
                        System.debug('id: '+parser.getText());
                        userId = parser.getText();
                    }
                }
            }
            
            if(userIds == ''){
                userIds = userId;
            }
            else{
                userIds = userIds+','+userId;
            }
        }
        
        System.debug(userIds);
        
        return userIds;
    }
    
    public static HttpResponse sendMessage(String channelId, String message, String token){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://slack.com/api/chat.postMessage?channel='+channelId+'&blocks='+message+'&pretty=1');
        req.setMethod('POST');
        req.setHeader('Authorization', token);
        Http http = new Http();
        return http.send(req);
    }
}