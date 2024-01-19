/**
 * Created by junaidm on 6/22/22.
 */

 public without sharing class B2BCarouselHelper {

    private static final String CHAR_HASH = '#';
    private static final String FILE_ASSET_PUBLIC = 'file-asset-public';
    private static final String CHAR_FORWARD_SLASH = '/';
    private static final String ASSET = 'Asset';
    private static final String URL = 'URL';
    private static final String FILE = 'File';
    private static final String CAROUSEL_OBJS = 'carouselObjs';
    public static final String IS_SUCCESS = 'isSuccess' ;
    public static final String MESSAGE = 'msg' ;

    private static final String CLASSNAME = 'B2BCarouselHelper';
    private static final String STOREFRONT = 'Axon';
    private static final String MODULE_NAME = 'Home Module';
    private static final String B2B_Storefront_Site_Url = 'https://training2021org1--mayank2.sandbox.my.site.com/herobike/';

    public static Map<String,Object> fetchHomePageCarousels(Map<String,Object> mapRequestParams)
    {
        
        String methodName = 'fetchHomePageCarousels';
        if(mapRequestParams == null)
        {
            return mapRequestParams;
        }
        Boolean blnShowCarousel = false;
        Map<String,Object> mapResponse = new Map<String,Object>();
        List<B2BCarouselVO> lstB2BCarouselVOS = new List<B2BCarouselVO>();
        Map<String, String> contentVersionPublicURL = new Map<String, String>();
        Map<String, String> mapAccountBuyerGroups = new Map<String, String>();
        String strEffectiveAccountId = null;
        List<B2BCarousel__c> lstCarousels = fetchCarousels();
        if(lstCarousels!=null && lstCarousels.size()>0)
        {
            contentVersionPublicURL = retrieveFileImageURL(lstCarousels);
            Account effectiveAccountObject = getUserAccount();
            if(effectiveAccountObject!=null)
            {
                strEffectiveAccountId = effectiveAccountObject.Id;
                mapAccountBuyerGroups = fetchBuyerGroupsMap(strEffectiveAccountId);
            }
            
            for(B2BCarousel__c b2BCarousel : lstCarousels)
            {
                blnShowCarousel = false;
                B2BCarouselVO b2BCarouselVO = new B2BCarouselVO();
                if(UserInfo.getUserType() == 'Guest' && b2BCarousel.AvailableForGuest__c)
                {
                    blnShowCarousel = true;
                }
                else if(b2BCarousel.ActiveConfiguration__c>0)
                {
                    List<B2BCarouselConfiguration__c> lstB2BCarouselConfigurations = b2BCarousel.B2BCarouselConfigurations__r;
                    if(lstB2BCarouselConfigurations!=null && lstB2BCarouselConfigurations.size()>0)
                    {
                        for(B2BCarouselConfiguration__c b2bCarouselConfiguration : lstB2BCarouselConfigurations)
                        {
                             if(String.isNotBlank(strEffectiveAccountId) && b2bCarouselConfiguration.Account__c == strEffectiveAccountId ||
                                    (mapAccountBuyerGroups.containsKey(b2bCarouselConfiguration.BuyerGroup__c) &&
                                            String.isNotBlank(mapAccountBuyerGroups.get(b2bCarouselConfiguration.BuyerGroup__c))) )
                            {
                                blnShowCarousel = true;
                                break;
                            }
                        }
                    }else
                    {
                        blnShowCarousel = true;
                    }
                }else
                {
                    blnShowCarousel = true;
                }
               if(blnShowCarousel)
                {
                    b2BCarouselVO.Id = b2BCarousel.Id;
                    if (String.isNotBlank(b2BCarousel.Link__c)) {
                        b2BCarouselVO.link = b2BCarousel.Link__c;
                    } else {
                        b2BCarouselVO.link = CHAR_HASH ;
                    }
                    if (b2BCarousel.ImageSource__c == ASSET) {
                        b2BCarouselVO.imageURL = B2B_Storefront_Site_Url +
                                CHAR_FORWARD_SLASH + FILE_ASSET_PUBLIC +
                                CHAR_FORWARD_SLASH + b2BCarousel.AssetName__c;
                    } else if (b2BCarousel.ImageSource__c == URL) {
                        b2BCarouselVO.imageURL = b2BCarousel.ImageURL__c;
                    } else if (b2BCarousel.ImageSource__c == FILE &&
                            contentVersionPublicURL != null && b2BCarousel.ContentDocumentLinks != null &&
                            b2BCarousel.ContentDocumentLinks.size() > 0) {
                        ContentDocumentLink contentDocumentLinkObject = b2BCarousel.ContentDocumentLinks[0];
                        if (contentDocumentLinkObject.ContentDocument != null &&
                                String.isNotBlank(contentDocumentLinkObject.ContentDocument.LatestPublishedVersionId) &&
                                contentVersionPublicURL.containsKey(contentDocumentLinkObject.ContentDocument.LatestPublishedVersionId) &&
                                contentVersionPublicURL.get(contentDocumentLinkObject.ContentDocument.LatestPublishedVersionId) != null
                        ) {
                            b2BCarouselVO.imageURL = contentVersionPublicURL.get(contentDocumentLinkObject.ContentDocument.LatestPublishedVersionId);
                        }
                    }
                    if (String.isNotBlank(b2BCarouselVO.imageURL))
                    {
                        lstB2BCarouselVOS.add(b2BCarouselVO);
                    }
                }
            }
            if(lstB2BCarouselVOS!=null && lstB2BCarouselVOS.size()>0)
            {
                mapResponse.put(CAROUSEL_OBJS, lstB2BCarouselVOS);
                mapResponse.put(IS_SUCCESS, true);
            }
        }
        return mapResponse;
    }

    public static Map<String,String> retrieveFileImageURL( List<B2BCarousel__c> lstCarousels)
    {
        String methodName = 'retrieveFileImageURL';
        Map<String,Object> mapFileImageURL = new Map<String,Object>();
        Map<String, String> contentVersionPublicURL = new Map<String, String>();
        if(lstCarousels!=null && lstCarousels.size()>0)
        {
            for (B2BCarousel__c b2bCarouselFileObject : lstCarousels)
            {
                if (String.isNotBlank(b2bCarouselFileObject.ImageSource__c) && b2bCarouselFileObject.ImageSource__c == FILE)
                {
                    if (b2bCarouselFileObject.ContentDocumentLinks != null && b2bCarouselFileObject.ContentDocumentLinks.size() > 0)
                    {
                        ContentDocumentLink contentDocumentLinkObject = b2bCarouselFileObject.ContentDocumentLinks[0];
                        if (contentDocumentLinkObject.ContentDocument != null && contentDocumentLinkObject.ContentDocument.LatestPublishedVersion != null)
                        {
                             mapFileImageURL.put(contentDocumentLinkObject.ContentDocument.LatestPublishedVersionId,
                                    contentDocumentLinkObject.ContentDocument.LatestPublishedVersion);
                        }
                    }
                }
            }
        }
        System.debug('fetchHomePageCarousels:mapFileImageURL: '+JSON.serialize(mapFileImageURL));
        if(mapFileImageURL!=null && mapFileImageURL.size()>0)
        {
            contentVersionPublicURL = generatePublicUrl( mapFileImageURL);
        }
        System.debug('fetchHomePageCarousels:contentVersionPublicURL: '+JSON.serialize(contentVersionPublicURL));
        return contentVersionPublicURL;
    }

    public static List<B2BCarousel__c> fetchCarousels()
    {
        List<B2BCarousel__c> lstCarousels = [SELECT Id,Active__c,AssetName__c,Name,EndDate__c,ImageSource__c,Link__c,ImageURL__c,ActiveConfiguration__c,
                AvailableForGuest__c, Sequence__c, (SELECT Id, Account__c, Account__r.Id,
                BuyerGroup__r.Id, BuyerGroup__c FROM B2BCarouselConfigurations__r WHERE Active__c =TRUE),
        (SELECT Id, ContentDocumentId, ContentDocument.Id, ContentDocument.FileType, ContentDocument.Title,
                ContentDocument.LatestPublishedVersionId,  ContentDocument.LatestPublishedVersion.Id ,
                ContentDocument.LatestPublishedVersion.Title, ContentDocument.LatestPublishedVersion.IsLatest,
                ContentDocument.LatestPublishedVersion.FileExtension
        FROM ContentDocumentLinks)
        FROM B2BCarousel__c
        WHERE Active__c=TRUE AND StartDate__c<=TODAY AND EndDate__c>=TODAY
        WITH SYSTEM_MODE ORDER BY Sequence__c ASC ] ;
        return lstCarousels;
    }

    public static List<BuyerGroupMember> fetchBuyerGroupMembers(String strEffectiveAccountId)
    {
        List<BuyerGroupMember> lstBuyerGroupMembers = null;
        if(String.isNotBlank(strEffectiveAccountId))
        {
            lstBuyerGroupMembers  = [SELECT Id, BuyerGroupId, BuyerId FROM BuyerGroupMember
            WHERE BuyerId =:strEffectiveAccountId  WITH SYSTEM_MODE ];
        }
        return lstBuyerGroupMembers;
    }

    public static Map<String, String> fetchBuyerGroupsMap(String strEffectiveAccountId)
    {
        Map<String,String> mapBuyerGroupMembers = new Map<String,String>();
        if(String.isNotBlank(strEffectiveAccountId))
        {
            List<BuyerGroupMember> lstBuyerGroupMembers =  fetchBuyerGroupMembers(strEffectiveAccountId);
            if(lstBuyerGroupMembers!=null && lstBuyerGroupMembers.size()>0)
            {
                for(BuyerGroupMember buyerGroupMemberObject : lstBuyerGroupMembers)
                {
                    mapBuyerGroupMembers.put(buyerGroupMemberObject.BuyerGroupId , buyerGroupMemberObject.BuyerId);
                }
            }
        }
        return mapBuyerGroupMembers;
    }

    public static Map<String, String>  generatePublicUrl( Map<String,Object> mapLatestPublishedVersion)
    {
        String methodName = 'generatePublicUrl';
        Map<String, String> mapContentVersionURL = new Map<String, String>();
        Map<String, ContentDistribution> mapContentDistributionObject = new Map<String, ContentDistribution>();
        Set<String> setContentVersionId = new Set<String>();
        Map<String,Object> mapLatestPublishedVersionCloned = new Map<String,Object>();
        if(mapLatestPublishedVersion!=null && mapLatestPublishedVersion.size()>0)
        {
            setContentVersionId = mapLatestPublishedVersion.keySet();
            mapLatestPublishedVersionCloned = mapLatestPublishedVersion.clone();
            mapContentDistributionObject = mapContentDistributionsByVersionId(setContentVersionId);
            if(mapContentDistributionObject!=null && mapContentDistributionObject.size()>0)
            {
                mapLatestPublishedVersion.keySet().removeAll(mapContentDistributionObject.keySet());
            }
            if(mapLatestPublishedVersion!=null && mapLatestPublishedVersion.size()>0)
            {
                createContentDistribution(mapLatestPublishedVersion.values());
            }
            //Finally Returning latest File
            mapContentVersionURL = populateContentVersionPublicURL(mapLatestPublishedVersionCloned);
        }
        return mapContentVersionURL;
    }

    public static Map<String, String> populateContentVersionPublicURL(Map<String, Object> mapLatestPublishedVersion)
    {
        String baseURL = System.URL.getOrgDomainUrl().toExternalForm();
        String methodName = 'populateContentVersionPublicURL';
        String imageURLEndPoint = '/sfc/dist/version/renditionDownload?rendition=ORIGINAL_';
        Map<String,String> populateContentVersionPublicURL = new Map<String, String>();
        if(mapLatestPublishedVersion!=null && mapLatestPublishedVersion.size()>0)
        {
            List<ContentDistribution> lstContentDistributions = fetchFileContentDistribution(mapLatestPublishedVersion.keySet());
            if(lstContentDistributions!=null && lstContentDistributions.size()>0)
            {
                for(ContentDistribution contentDistributionObject : lstContentDistributions)
                {
                    String contentId = contentDistributionObject.ContentDocumentId;
                    List<String> urlList = contentDistributionObject.DistributionPublicUrl.split('/');
                    String versionId = contentDistributionObject.ContentVersionId;
                    String publicURL = baseURL;
                    if(String.isNotBlank(imageURLEndPoint))
                    {
                        publicURL += imageURLEndPoint;
                    }else
                    {
                        publicURL +=  '/sfc/dist/version/renditionDownload?rendition=ORIGINAL_';
                    }
                    String strContentVersionId = contentDistributionObject.ContentVersionId;
                     if(mapLatestPublishedVersion.containsKey(strContentVersionId) &&
                            mapLatestPublishedVersion.get(strContentVersionId)!=null)
                    {
                        ContentVersion contentVersionObject = (ContentVersion) mapLatestPublishedVersion.get(strContentVersionId);
                        publicURL += contentVersionObject.FileExtension;
                    }else
                    {
                        publicURL += 'Jpeg';
                    }
                    publicURL += '&versionId=' + versionId;
                    publicURL += '&operationContext=DELIVERY';
                    publicURL += '&contentId=' + contentId + '&page=0&d=/' + urlList[6] + '/' + urlList[7] + '/' + urlList[8];
                    publicURL += '&oid=' + UserInfo.getOrganizationId() + '&dpt=null&viewId=';
                    populateContentVersionPublicURL.put(strContentVersionId , publicURL);
                 }
            }
        }
        return populateContentVersionPublicURL;
    }
    
    public static List<ContentDistribution> fetchFileContentDistribution(Set<String> setContentVersionIds)
    {
        List<ContentDistribution> distributionsToList = [ SELECT Id,Name, DistributionPublicUrl,ContentDownloadUrl,ContentVersionId,
                ContentDocumentId
        FROM ContentDistribution WHERE ContentVersionId = :setContentVersionIds WITH SYSTEM_MODE ];
        return distributionsToList;
    }

    public static Map<String, ContentDistribution> mapContentDistributionsByVersionId(Set<String> setContentVersionIds)
    {
        Map<String,ContentDistribution> contentDistributionMap = new Map<String, ContentDistribution>();
        if(setContentVersionIds!=null && setContentVersionIds.size()>0)
        {
            List<ContentDistribution> lstContentDistributions = fetchFileContentDistribution(setContentVersionIds);
            if(lstContentDistributions!=null && lstContentDistributions.size()>0)
            {
                for(ContentDistribution contentDistributionObject : lstContentDistributions)
                {
                    contentDistributionMap.put(contentDistributionObject.ContentVersionId , contentDistributionObject);
                }
            }
        }
        return contentDistributionMap;
    }

    public static void createContentDistribution(List<Object> lstContentVersion)
    {
        List<ContentDistribution> contentDistributionList = new List<ContentDistribution>();
        String methodName = '';
        String supportData = '';
        try {
            for (Object sObjectVersionObject : lstContentVersion) {
                ContentVersion contentVersionObject = (ContentVersion) sObjectVersionObject;
                ContentDistribution cd = new ContentDistribution();
                cd.Name = contentVersionObject.Title;
                cd.ContentVersionId = contentVersionObject.Id;
                cd.PreferencesAllowViewInBrowser = true;
                cd.PreferencesLinkLatestVersion = true;
                cd.PreferencesNotifyOnVisit = false;
                cd.PreferencesPasswordRequired = false;
                cd.PreferencesAllowOriginalDownload = true;
                contentDistributionList.add(cd);
            }
            if (contentDistributionList != null && contentDistributionList.size() > 0) {
                insert contentDistributionList;
            }
        }catch(Exception expObj)
        {
        }
    }


    //B2BAccountHelper in AEE
    public static Account getUserAccount() {
        String userId = UserInfo.getUserId();
        Account effectiveAccount = null;
        List<User> lstUsers = [SELECT ContactId,Contact.AccountId,Contact.Account.Name,
                Contact.Account.Id  FROM User WHERE Id = :userId WITH SYSTEM_MODE ];
        if(lstUsers!=null && lstUsers.size()>0)
        {
            if(lstUsers[0].Contact!=null)
            {
                effectiveAccount = lstUsers[0].Contact.Account;
            }
        }
        return effectiveAccount;
    }

}