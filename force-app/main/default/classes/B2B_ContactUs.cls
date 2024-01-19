public with sharing class B2B_ContactUs {
    @AuraEnabled()
    public static void UserDefine(Id uID,String Comm) {
        User ConId = [Select ContactId from user where Id=:uID Limit 1];
        Contact AccId = [Select AccountId from contact where Id=:ConId.ContactId Limit 1];
        Group CaseQueue=[select Id from Group WHERE Name='OnlineEnquiry'];
        Case caseObj = new Case(
        ContactId = ConId.ContactId,
        AccountId = AccId.AccountId,
        Status = 'New',
        Origin = 'Web',
        Comments = Comm);
        caseObj.OwnerId=CaseQueue.Id;
        insert caseObj;
    }
    @AuraEnabled()
    public static void GuestDefine(string fn,string ln,string comp,string mail,String Comm) {
        Group leadQueue=[select Id from Group where Type='Queue' AND Name='B2BStoreLeads'];
        Lead l = new Lead(
        Company = comp,
        LastName = ln,
        FirstName = fn,
        Email= mail,
        Description = Comm,
        LeadSource = 'B2B Store');
        l.OwnerId=leadQueue.Id;
        insert l;
    }
}