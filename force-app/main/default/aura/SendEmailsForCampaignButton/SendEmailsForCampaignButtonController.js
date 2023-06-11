({
    doInit : function(component, helper) {
        let recordId = component.get('v.recordId');
        var action = component.get("c.sendEmailsForCampaign");
        action.setParams({ 'campaignId' : recordId });
        action.setCallback(this, function(response) {
            $A.get("e.force:closeQuickAction").fire();
            component.find('notify').showToast({
                "variant": "success",
                "title": "Success",
                "message": "Emails will be sent soon!"
            });
        });
        $A.enqueueAction(action);
    }
})