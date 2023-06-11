public class SendCampaignEmails implements Database.Batchable<sObject> {
    CampaignEmailsJob params;
    
    public SendCampaignEmails(CampaignEmailsJob params){
        this.params = params;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Contact__r.Email FROM Campaign_Member__c WHERE Marketing_Campaign__c = \'' + this.params.campaignId +  '\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Campaign_Member__c> campaignMembers){
        String emailTempalteId = this.params.emailTemplateId;
        for(Campaign_Member__c campaignMember : campaignMembers){
            // send emails for campaign members using template and contact's email
        }
    }
    
    public void finish(Database.BatchableContext bc){
        AsyncApexJob batchJob = [
            SELECT Status
            FROM AsyncApexJob WHERE Id = :bc.getJobId()
        ];
        
        update new Job_request__c(
            Id = this.params.jobRequestId,
            Job_Status__c = batchJob.Status == 'Failed' ? 'Finished with an error' : 'Finished'
        );
    }
    
    public class CampaignEmailsJob{
        public String jobRequestId;
        public String campaignId;
        public String emailTemplateId;
    }
}