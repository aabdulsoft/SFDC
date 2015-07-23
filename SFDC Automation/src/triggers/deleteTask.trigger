/*
* Prevent deletetion of any Tasks except for Sys Admin profiles
*/
trigger deleteTask on Task (before delete) {
    Map<Id, Profile> sysAdminProfileMap = new Map<Id,Profile>([Select p.Name, p.Id From Profile p where p.Name in ('SSO System Administrator', 'System Administrator','Business Admin','Business Admin Non SSO')]);
    boolean addError = false;
    if (sysAdminProfileMap.get(UserInfo.getProfileId()) == null) {
        addError = true;
    }
    for(Task temp: Trigger.old) {
        if (addError == true) {
           temp.addError('Task can not be deleted');
        }
    }
}