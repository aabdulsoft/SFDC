trigger Updateowner on Account (before insert,before update) {
for (account acc:Trigger.new)
    acc.owner_copy__c=acc.ownerId;

}