public class SendEmailForCampaignButtonCtrl {
    @AuraEnabled
    public static void sendEmailsForCampaign(String campaignId){
        SendCampaignEmails.CampaignEmailsJob params = new SendCampaignEmails.CampaignEmailsJob();
        params.campaignId = campaignId;
        params.emailTemplateId = '00X7Q000002eyEHUAY';
        
        insert new Job_request__c(
            Job_Type__c = JobOrchestrator.MARKETING_EMAIL_JOB, 
            Job_Parameters__c = JSON.serialize(params),
            Job_Status__c = 'New'
        );
    }
}