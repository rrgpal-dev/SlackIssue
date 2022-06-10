/**
* Created by Emily on 4/20/2022.
*/
public with sharing class SlackController {
    @AuraEnabled
    public static void sendMessage(string channelName){
        String token = 'Bearer xoxb-2099680222902-3281750604020-73mIGDtoiAx7Zs9QwrQoOAcK';
        
        Case case1 = [SELECT Id, Priority, CaseNumber, Subject,  Description, Reason, Account.Name, AccountId, DateTime_Opened_c__c FROM Case WHERE Id =: channelName];
        
        String caseRecordLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+case1.Id;
        String accountRecordLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+case1.AccountId;
        
        List<String> emails = new List<String>{'smith.e@salesforce.com', 'raj.ramachandran@salesforce.com'};
            
        String channelId = SlackAPIHelper.createChannel(case1.CaseNumber, token);
        
        String userIds = SlackAPIHelper.getIds(emails, token);
        
        String titleBlock = SlackJSONHelper.createTitleBlock();
        
        String caseBlock = SlackJSONHelper.createCaseBlock(caseRecordLink, channelName);
        
        String caseDetailBlock = SlackJSONHelper.createCaseDetailBlock(case1.Subject, case1.Priority, case1.Account.Name, case1.DateTime_Opened_c__c, case1.Description);
        
        String accountBlock = SlackJSONHelper.createAccountBlock(accountRecordLink, case1.Account.Name);
        
        String message = EncodingUtil.urlEncode('['+titleBlock+','+caseBlock+','+caseDetailBlock+','+accountBlock+']', 'UTF-8');
        
        HttpResponse res = SlackAPIHelper.sendMessage(channelId, message, token);
        
        System.debug(res.getBody());
        
        SlackAPIHelper.pinMessage(channelId, token, res);
        
        SlackAPIHelper.addUsers(channelId, token, userIds);
        
       insert new DebugLog__c(
                Debug_details__c                 = 'Hello https://slack.com/api/conversations.create?name='+channelId+'&is_private=true&pretty=1');
    }  
    
  
    
   

}