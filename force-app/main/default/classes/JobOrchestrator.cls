public class JobOrchestrator implements Schedulable {
    public static final String MARKETING_EMAIL_JOB = 'Marketing Email Sending';

    private static final Integer JOBS_IN_QUEUE_THRESHOLD = 50; 
    //put this number in CMTD, CS or Label to easily configure and manage if needed
    
    public void execute(SchedulableContext context){
        orchestrate();
    }
    
    public static void orchestrate(){
        List<Job_request__c> jobRequests = [
            SELECT Job_type__c, Job_parameters__c
            FROM Job_request__c
            WHERE Job_Status__c = 'New'
            ORDER BY CreatedDate ASC
            LIMIT :JOBS_IN_QUEUE_THRESHOLD            
        ];
        for(Job_request__c jobRequest : jobRequests){
            Integer numberOfJobsInTheQueue = getNumberOfJobsInTheQueue(); 
            //yes, line above is SOQL in FOR loop
            //but we want to receive up-to-date number each time we run new batch
            //and we know that jobRequests.size() is limited to 50
            
            if(numberOfJobsInTheQueue < JOBS_IN_QUEUE_THRESHOLD){
                executeJob(jobRequest);
            }
        }
        
        update jobRequests;
    }
    
    private static void executeJob(Job_request__c jobRequest){
        try{
            if(jobRequest.Job_type__c == MARKETING_EMAIL_JOB){
                SendCampaignEmails.CampaignEmailsJob params = (SendCampaignEmails.CampaignEmailsJob) 
                    JSON.deserialize(jobRequest.Job_parameters__c, SendCampaignEmails.CampaignEmailsJob.class);
                params.jobRequestId = jobRequest.Id;
                Database.executeBatch(new SendCampaignEmails(params), 10);
            } 
            /*
            else if (jobRequest.Job_type__c == another job type you need)){
                deserialize parameter to class with parameter for another batch
                execute another batch with needed parameters 
            }
            */ 
            
            jobRequest.Job_Status__c = 'Processing';
        } catch (Exception e){
            jobRequest.Job_Status__c = 'Failed to run';
            jobRequest.Status_Info__c = e.getLineNumber() + ':' + e.getStackTraceString();
        }               
    }
    
    private static Integer getNumberOfJobsInTheQueue(){
        return [
            SELECT COUNT() 
            FROM AsyncApexJob 
            WHERE JobType = 'BatchApex' AND Status IN ('Processing','Preparing','Queued','Holding')
        ];
    }
}
