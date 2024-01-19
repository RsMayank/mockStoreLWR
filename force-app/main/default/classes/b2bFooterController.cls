public with sharing class b2bFooterController {
    @AuraEnabled(cacheable=true)
	public static Map<String,String> getLinks()
	{
		Map<String,String> newMap= new Map<String,String>();

		for (b2bFooter__mdt var : [SELECT DeveloperName,URL_link__c FROM b2bFooter__mdt ]) {
			newMap.put(var.DeveloperName,var.URL_link__c);
		}
		return newMap;
	}

}