public with sharing class B2B_RegistrationController {
    private static final String CLASS_NAME = 'B2B_RegistrationController';
    private static final String STORE_FRONT = 'Trainig';
    private static final String MODULE_NAME = 'Registration Module';

    @AuraEnabled
    public static Map<String,Object> checkForEmailExistence(Map<String,Object> dataMap){
        try {
            dataMap = B2B_RegistrationHelper.checkForEmailPhoneExistence(dataMap);
            dataMap.put(B2B_Constants.IS_SUCCESS,true);
        } catch (Exception e) {
            dataMap = dataMap==null ? new Map<String,Object>() : dataMap ;
            dataMap.put(B2B_Constants.IS_SUCCESS,false);
            dataMap.put(B2B_Constants.ERROR_MSG,e.getMessage());
        }
        return dataMap;
    } 
    @AuraEnabled
    public static Map<String,Object> RegisterUser(Map<String,Object> dataMap){
        try {
            B2B_RegistrationHelper.createUser(dataMap);
            dataMap.put(B2B_Constants.IS_SUCCESS,true);
        } catch (Exception e) {
            dataMap = dataMap==null ? new Map<String,Object>() : dataMap ;
            dataMap.put(B2B_Constants.IS_SUCCESS,false);
            dataMap.put(B2B_Constants.ERROR_MSG,e.getMessage());
        }
        return dataMap;
    }
}