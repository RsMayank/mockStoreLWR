public without sharing class B2B_RegistrationHelper {
    private static final String CLASSNAME = 'B2B_RegistrationHelper';

    // CHECK IF EMAIL EXIST ON THE CONTACT
    public static Map<String, Object> checkForEmailPhoneExistence(Map<String, Object> dataMap) {
        if (dataMap == null) {
            throw new IllegalArgumentException('dataMap cannot be null');
        }
        
        String email = (String) dataMap.get(B2B_Constants.EMAIL);
        String phone = (String) dataMap.get(B2B_Constants.PHONE);
        
        boolean emailExists = false;
        boolean phoneExists = false;
    
        List<Contact> cnt = [SELECT Id, Email, Phone FROM Contact];
        for (Contact c : cnt) {
            if (c.Email != null && c.Email.equals(email)) {
                emailExists = true;
            }
            if (c.Phone != null && c.Phone.equals(phone)) {
                phoneExists = true;
            }
        }
        dataMap.put(B2B_Constants.IS_EMAIL_EXIST, emailExists);
        dataMap.put(B2B_Constants.IS_PHONE_EXIST,phoneExists);
        return dataMap;
    }    
    //ACCOUNT CREATION
    public static void createAccount(Map<String,Object> dataMap){
        String methodName = 'createAccount';

        if(dataMap!=null){
            // String email = (String)dataMap.get(B2B_Constants.EMAIL);
            // Account userAccount = new Account();
            // userAccount.Name = (String)dataMap.get(B2B_Constants.ACCOUNT_NAME);
            // userAccount.Website = ('www.'+ (String)dataMap.get(B2B_Constants.ACCOUNT_NAME)+'.com').deleteWhitespace();
            // userAccount.Description = 'this Account belongs to '+ (String)dataMap.get(B2B_Constants.FIRST_NAME) + (String)dataMap.get(B2B_Constants.LAST_NAME);
            // insert userAccount;
            dataMap.put(B2B_Constants.ACCOUNT_ID,'0018G00000W7c0lQAB');
            // enableAccountsAsBuyers(userAccount.Id);
        }
    }
    public static void enableAccountsAsBuyers(String accountIds) {
        String methodName = 'enableAccountsAsBuyers';
        List<B2B_User_Registration_Settings__mdt> BGName = getRegistrationMetaData();
        String buyerGroupName = (String)BGName[0].Buyer_Group_Name__c;
        List<BuyerGroup> bgId = [SELECT Id FROM BuyerGroup WHERE Name=:buyerGroupName LIMIT 1];

        if(accountIds!=null){
            List<BuyerAccount> buyerList = new List<BuyerAccount>([SELECT Id FROM BuyerAccount WHERE BuyerId =:accountIds]);
            if(buyerList.isEmpty()) {
                List<BuyerAccount> buyerAccounts = new List<BuyerAccount>();
                for (Account account: [SELECT Id,Name FROM Account WHERE Id =:accountIds]) {
                    buyerAccounts.add(new BuyerAccount(BuyerId = account.Id, Name = account.Name, IsActive = true, BuyerStatus = B2B_Constants.ACTIVE));
                }
                insert buyerAccounts;
            }
            List<BuyerGroupMember> bgmList = [SELECT Id,Name FROM BuyerGroupMember WHERE BuyerId=:accountIds LIMIT 1];
            if(bgmList.isEmpty()){
                BuyerGroupMember bgm = new BuyerGroupMember();
                bgm.BuyerId = accountIds;
                bgm.BuyerGroupId = bgId[0].Id;
                insert bgm;
            }
        }
    }  
    //CONTACT CREATTION
    public static void createContact(Map<String,Object> dataMap){
        String methodName = 'createContact';

        if(dataMap!=null && (dataMap.containsKey(B2B_Constants.ACCOUNT_ID) && dataMap.get(B2B_Constants.ACCOUNT_ID)!=null)){
            String accountId = (String)dataMap.get(B2B_Constants.ACCOUNT_ID);
            Contact userContact = new Contact();
            userContact.FirstName = (String)dataMap.get(B2B_Constants.FIRST_NAME);
            userContact.LastName = (String)dataMap.get(B2B_Constants.LAST_NAME);
            userContact.Email = (String)dataMap.get(B2B_Constants.EMAIL);
            userContact.Phone = (String)dataMap.get(B2B_Constants.PHONE);
            userContact.AccountId = accountId;           
            insert userContact;
            dataMap.put(B2B_Constants.CONTACT_ID,userContact.Id);
        }
    }
    public static Map<String,Object> createUser(Map<String,Object> dataMap){
        System.debug('data map : '+dataMap);
        String methodName = 'createUser';
        createAccount( dataMap);
        createContact(dataMap);
        String contactId = (String)dataMap.get(B2B_Constants.CONTACT_ID);
        String userAlias='';
        String firstName = (String)dataMap.get(B2B_Constants.FIRST_NAME);
        String lastName = (String)dataMap.get(B2B_Constants.LAST_NAME);
        userAlias = firstName.substring(0, 1);
        if(lastName.length() >6){
            userAlias+= lastName.substring(0, 6);
        }else {
            userAlias+=lastName;
        }
        Set<String> existingAliases = new Set<String>();
        for (User existingUser : [SELECT Alias FROM User WHERE Alias LIKE :userAlias + '%']) {
            existingAliases.add(existingUser.Alias);
        }

        // Generate a unique userAlias
        Integer aliasSuffix = 1;
        String uniqueUserAlias = userAlias;
        while (existingAliases.contains(uniqueUserAlias)) {
            uniqueUserAlias = userAlias + aliasSuffix;
            aliasSuffix++;
        }
        // Set the unique userAlias
        userAlias = uniqueUserAlias;
        List<B2B_User_Registration_Settings__mdt> BGName = getRegistrationMetaData();
        String profileName = (String)BGName[0].Profile_Name__c;
        String pId =  [SELECT Id, Name FROM Profile WHERE Name=:profileName]?.Id;

        User user = new User();
        user.FirstName = (String)dataMap.get(B2B_Constants.FIRST_NAME);
        user.LastName = (String)dataMap.get(B2B_Constants.LAST_NAME);
        user.Phone = (String)dataMap.get(B2B_Constants.PHONE);

        String communityNickName = firstName.toLowerCase() + lastName.toLowerCase() + userAlias;
        Set<String> existingNicknames = new Set<String>();
        for (User existingUser : [SELECT CommunityNickName FROM User WHERE CommunityNickName LIKE :communityNickName + '%']) {
            existingNicknames.add(existingUser.CommunityNickName);
        }
        Integer nicknameSuffix = 1;
        String uniqueCommunityNickName = communityNickName;
        while (existingNicknames.contains(uniqueCommunityNickName)) {
            uniqueCommunityNickName = communityNickName + nicknameSuffix;
            nicknameSuffix++;
        }

        user.CommunityNickName = uniqueCommunityNickName;
        user.Alias = userAlias;
        user.ContactId = contactId;
        user.Email = (String)dataMap.get(B2B_Constants.EMAIL);
        user.UserName = (String)dataMap.get(B2B_Constants.EMAIL);
        user.ProfileId = pId;         
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.LocaleSidKey='en_US';
        user.LanguageLocaleKey='en_US';
        user.EmailEncodingKey='ISO-8859-1';
        System.debug('before insert');
        //insert user;
        dataMap.put(B2B_Constants.USER_NAME,user.userName);
        String username = (String)dataMap.get(B2B_Constants.USER_NAME);
        String password = (String)dataMap.get(B2B_Constants.PASSWORD);
        try{
            String userId = Site.createExternalUser(user, (String)dataMap.get(B2B_Constants.ACCOUNT_ID),password);
            user.Id =  userId;
            dataMap.put(B2B_Constants.USER_ID,user.Id);
            assignpermissionSets(user.Id);

            string startUrl = 'https://training202104--fkhan.sandbox.my.site.com/zstore/';
            ApexPages.PageReference pageRef = Site.login(username, password, startUrl);
            if(pageRef != null){
                dataMap.put(B2B_Constants.LOGIN_URL,pageRef.getUrl());
            }
        }catch(Site.ExternalUserCreateException ex) {
            List<String> errors = ex.getDisplayMessages();
            for (String error : errors)  {
                System.debug('error : '+error);
            }
            System.debug(ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
        return dataMap;
    }
    @future
    public static void assignpermissionSets(String userId) {
        String methodName = 'assignpermissionSets';

        if(userId!=null) {
            List<B2B_User_Registration_Settings__mdt> BGName = getRegistrationMetaData();
            String permissionNames = (String)BGName[0].Permission_SetGroupName__c;
            String psGroup = [SELECT Id FROM PermissionSetGroup WHERE
                                      developername=:permissionNames LIMIT 1]?.Id;
            List<PermissionSetAssignment> psAssignment= new List<PermissionSetAssignment>();
            PermissionSetAssignment assignment = new PermissionSetAssignment(
                permissionSetGroupId = psGroup,AssigneeId=userId
            );
            psAssignment.add(assignment);
            try{

                upsert psAssignment;
            }
            catch(DmlException de) {
                System.debug(de.getMessage());
            }
            catch(Exception e){
                System.debug(e.getMessage());
            }  
        }
    }
    public static List<B2B_User_Registration_Settings__mdt> getRegistrationMetaData(){
        List<B2B_User_Registration_Settings__mdt> usrData = [
            SELECT Id, Buyer_Group_Name__c, EmailRegex__c,Permission_SetGroupName__c,Profile_Name__c
            FROM B2B_User_Registration_Settings__mdt
            ];
        return usrData;
    }
}