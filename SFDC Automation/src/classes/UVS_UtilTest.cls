/*******************************************************************
Name  : UVS_UtilTest
Author: Hari Krishnan (Appirio)
Date  : February 27, 2015
Discription: Test Class for the UVS_UtilTest class.
*************************************************************************/
@isTest(seeAllData=true)
public with sharing class UVS_UtilTest{

    static testMethod void testUVSRecordType_Opp() {
        Id oppRecTypeId = UVS_Util.UVSRecordType_Opp;
        System.assert(oppRecTypeId != null);
    }
    
    static testMethod void testIsUVSProfile1() {
        Boolean isUserBelongsToUVSProfile = false;
        User uvsUser =  TestUtilUVS.createUser(true);
        System.runAs(uvsUser) {
           isUserBelongsToUVSProfile = UVS_Util.IsUVSProfile;
        }
        System.assert(isUserBelongsToUVSProfile, true);
    }
    
    static testMethod void testIsUVSProfile2() {
        Boolean isUserBelongsToUVSProfile = false;
        User u = TestUtil.createUser();
        System.runAs(u) {
            isUserBelongsToUVSProfile = UVS_Util.IsUVSProfile;
        }
        System.debug('$$$: isUserBelongsToUVSProfile  = ' + isUserBelongsToUVSProfile );
        System.assertEquals(isUserBelongsToUVSProfile, false);
    }
    
    static testMethod void testIsUVSProfile3() {
        Boolean isUserBelongsToUVSProfile = false;
        User uvsUser =  TestUtilUVS.createUser(true);
        isUserBelongsToUVSProfile = UVS_Util.IsUVSProfile(uvsUser.Id);
        System.assert(isUserBelongsToUVSProfile, true);
    }
    
    static testMethod void testIsUVSProfile4() {
        Boolean isUserBelongsToUVSProfile = false;
        User u = TestUtil.createUser();
        System.runAs(u) {
            isUserBelongsToUVSProfile = UVS_Util.IsUVSProfile;
        }
        System.debug('$$$: isUserBelongsToUVSProfile  = ' + isUserBelongsToUVSProfile );        
        System.assertEquals(isUserBelongsToUVSProfile, false);
    }
    
    static testMethod void testGetAllUsersOfAProfile() {
        Map<String, List<User>> mapUsers = UVS_Util.getAllUsersOfAProfile();
        System.assert(mapUsers.size() > 0);
    }
    
    static testMethod void testGetBTRUserType1() {
        User uvsUser =  TestUtilUVS.createUser(true);
        String userType;
        System.runAs(uvsUser) {
            userType = UVS_Util.getBTRUserType();
        }
        System.assertEquals(userType, 'VSM');
    }
    
    static testMethod void testGetBTRUserType2() {
        User uvsUser = TestUtilUVS.createUser(true);
        Profile p = [select p.id from Profile p where p.Name in ('FAM') LIMIT 1];
        uvsUser.ProfileId = p.Id;
        update uvsUser;
        String userType;        
        System.runAs(uvsUser) {
            userType = UVS_Util.getBTRUserType();
        }
        System.assertEquals(userType, 'FAM');
    }
    
    static testMethod void testGetBTRUserType3() {
        User uvsUser = TestUtilUVS.createUser(true);
        Profile p = [select p.id from Profile p where p.Name in ('DAM') LIMIT 1];
        uvsUser.ProfileId = p.Id;
        update uvsUser;        
        String userType;        
        System.runAs(uvsUser) {
            userType = UVS_Util.getBTRUserType();
        }
        System.assertEquals(userType, 'DAM');
    }
    
    static testMethod void testGetBTRUserType4() {
        User uvsUser = TestUtilUVS.createUser(true);
        Profile p = [select p.id from Profile p where p.Name in ('VP Asset Management') LIMIT 1];
        String userType;        
        uvsUser.ProfileId = p.Id;
        update uvsUser;        
        System.runAs(uvsUser) {
            userType = UVS_Util.getBTRUserType();
        }
        System.assertEquals(userType, 'VP');
    }
    
    static testMethod void testGetBTRUserType5() {
        User u = TestUtilUVS.createAdminUser(true);
        String userType;        
        System.runAs(u) {
            userType = UVS_Util.getBTRUserType();
        }
        System.assertEquals(userType, 'ADMIN');
    }
}