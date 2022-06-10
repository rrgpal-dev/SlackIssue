public class SlackJSONHelper {
	public static String createTitleBlock() {
        JSONGenerator block1 = JSON.createGenerator(true);
        
        block1.writeStartObject();
        block1.writeStringField('type', 'section');
        block1.writeFieldName('text');
        block1.writeStartObject();
        block1.writeObjectField('type', 'mrkdwn');
        block1.writeObjectField('text', 'Here is the Case Record we are Swarming on, I have pinned it to the channel for easy access.');
        block1.writeEndObject();
        block1.writeEndObject();
        
        return block1.getAsString();
    }
    
    public static String createCaseBlock(String caseRecordLink, String channelName) {
        JSONGenerator block2 = JSON.createGenerator(true);
        
        block2.writeStartObject();
        block2.writeStringField('type', 'section');
        block2.writeFieldName('text');
        block2.writeStartObject();
        block2.writeObjectField('type', 'mrkdwn');
        block2.writeObjectField('text', ':case_icon: Case | <'+caseRecordLink+' | '+ channelName+'>');
        block2.writeEndObject();
        block2.writeEndObject();
        
        return block2.getAsString();
    }
    
    public static String createCaseDetailBlock(String Subject, String Priority, String AccountName, DateTime DateTimeOpened, String Description) {
    	JSONGenerator block3 = JSON.createGenerator(true);
        
        block3.writeStartObject();
        block3.writeStringField('type', 'section');
        block3.writeFieldName('text');
        block3.writeStartObject();
        block3.writeObjectField('type', 'mrkdwn');
        block3.writeObjectField('text', '*Subject*: '+Subject+'\n *Priority*: '+Priority+'\n *AccountName*: '+AccountName+'*\n *Date Opened*: '+DateTimeOpened+'\n*Description*: '+Description);
        block3.writeEndObject();
        block3.writeEndObject();
        
        return block3.getAsString();
    }
    
    public static String createAccountBlock(String accountRecordLink, String accountName) {
		JSONGenerator block4 = JSON.createGenerator(true);
        
        block4.writeStartObject();
        block4.writeStringField('type', 'section');
        block4.writeFieldName('text');
        block4.writeStartObject();
        block4.writeObjectField('type', 'mrkdwn');
        block4.writeObjectField('text', ':account_icon: Account | <'+accountRecordLink+' | '+accountName+'>');
        block4.writeEndObject();
        block4.writeEndObject();

        return block4.getAsString();
    }    
        
    //@future(callout=true)
    //public static void archiveChannel(string channelName){

        //TODO: Make this more dynamic might need to rethink the object structure for the channel 
        //Case case1 = [SELECT Id FROM Case WHERE CaseNumber = :channelName];
        //name could be case name or we could find it based on the case Id 
        //Demo_Installation__c demoObj = [SELECT SlackChannel__c FROM Demo_Installation__c WHERE Name = 'Test'];
        //String token = 'Bearer xoxb-2099680222902-3281750604020-73mIGDtoiAx7Zs9QwrQoOAcK';

        //HttpRequest archiveReq = new HttpRequest();
        //archiveReq.setEndpoint('https://slack.com/api/conversations.archive?channel='+demoObj.SlackChannel__c+'&pretty=1');
        //archiveReq.setMethod('POST');
        //archiveReq.setHeader('Authorization',token);
        //System.debug(archiveReq);
        //Http archiveHttp = new Http();
        //HttpResponse archiveRes = archiveHttp.send(archiveReq);
        //System.debug(archiveRes.getBody());
    //}
}