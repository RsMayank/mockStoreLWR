/**
 * Created by junaidm on 6/22/22.
 * Modified by Mayank Srivastava
 * July-21-2023
 */

 public with sharing class B2BCarouselController {

    private static final String CLASSNAME = 'B2BCarouselController';
    private static final String STOREFRONT = 'HeroBikes';
    private static final String MODULE_NAME = 'Home Module';
    
    @AuraEnabled
    public static Map<String,Object> fetchCarousel(Map<String,Object> dataMap) {
        String methodName = 'fetchCarousel';
        String supportData = '';
        Map<String,Object> mapResponse = new Map<String, Object>();
        try {
            mapResponse = B2BCarouselHelper.fetchHomePageCarousels(dataMap);
            dataMap.put(B2BCarouselHelper.IS_SUCCESS, true);
           } catch (Exception ex) 
        {
            mapResponse = mapResponse == null ? new Map<String, Object>() : mapResponse ;
            mapResponse.put(B2BCarouselHelper.IS_SUCCESS, false); mapResponse.put(B2BCarouselHelper.MESSAGE, ex.getMessage());
        } 

        return mapResponse;
    }

}