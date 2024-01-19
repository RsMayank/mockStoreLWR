public without sharing class B2BProductController {
    @AuraEnabled(cacheable=true)
    public static ConnectApi.ProductDetail getProduct(
      String communityId,
      String productId,
      String effectiveAccountId
    ) {
      // Lookup the webstore ID associated with the community
      String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
  
      // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCatalog_static_methods.htm#apex_ConnectAPI_CommerceCatalog_static_methods
      return ConnectApi.CommerceCatalog.getProduct(
        webstoreId,
        productId,
        effectiveAccountID,
        null,
        false,
        null,
        false,
        true,
        false
      );
    }
  
    @AuraEnabled(cacheable=true)
    public static Boolean checkProductIsInStock(String productId) {
      /*
       * The following is an example of calling an external API.
       * The example API provided is extremely simple: It takes in a product id
       * and returns a true or false value for inStock based on whether the 15th char is odd or even.
       *
       * To access this endpoint on your org, go to Remote Site Settings in Setup as an admin user
       * click "New Remote Site" and provide "https://inventorymanagerdemo.herokuapp.com" for the "Remote Site URL" field
       */


      Http http = new Http();

      HttpRequest request = new HttpRequest();
      String endpoint = Url.getOrgDomainUrl().toExternalForm() +'/services/apexrest/Inventory__c/' + productId;
      System.debug('endPoint : ' + endPoint);
      request.setEndpoint(endpoint);
      request.setMethod('GET');
      request.setHeader('Authorization', 'Bearer '+UserInfo.getSessionID());
      request.setHeader('Content-Type', 'application/json');
      HttpResponse response = http.send(request);
      // If the request is successful, parse the JSON response.
      if (response.getStatusCode() == 200) {
        // Deserialize the JSON string into collections of primitive data types.
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(
          response.getBody()
        );
        if(results == null || results.isEmpty())
        {
          return false;
        }

        // System.debug('response : '  + JSON.serialize(results));
        Integer qty  = (Integer)results.get('Available_for_Purchase__c');
        if(qty > 0 )
        {
          return true;
        }
        else {
          return false;
        }
      }
      else
      {
      //  Map<String,Object> res = new Map<String,Object>();
      //   Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(
      //     response.getBody()
      //   );
        return false;
      }
    }
  
    @AuraEnabled
    public static ConnectApi.CartSummary getCartSummary(
      String communityId,
      String effectiveAccountId
    ) {
      // Lookup the webstore ID associated with the community
      String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
  
      //'current' is available in version 50.0 and later and indicates a cart with a status that isn’t Closed or PendingDelete
      //This is important for the product detail page since we are using the cart summary to check if the status is "Processing" or "Checkout"
      String activeCartOrId = 'current';
  
      // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
      return ConnectApi.CommerceCart.getCartSummary(
        webstoreId,
        effectiveAccountId,
        activeCartOrId
      );

      // public static ConnectApi.CartSummary getOrCreateActiveCartSummary(String webstoreId, String effectiveAccountId, String activeCartOrId)
      // return ConnectApi.CommerceCart.getOrCreateActiveCartSummary(webstoreId,effectiveAccountId,activeCartOrId);
    }

    // Updating Reserved
  @AuraEnabled
  public static Void clearUserCart(Map<String,Integer> mp)
  {
    try 
    {
      System.debug('Cart Cleared');
      
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
    

    @AuraEnabled(cacheable=false)
    public static Void updateReserved( String reservedQuantity1, String productId, Boolean clearCart, String cartItemId, Boolean decrease)
    {
      // if clear cart is true then it is deleting the cart item and restoring the reserve
      if(clearCart)
      {
            CartItem getpId = [SELECT Product2Id,quantity From CartItem Where Id =:cartItemId];
            String pId = String.valueOf(getpId.Product2Id);
            System.debug(pId);
            Decimal qty = getpId.quantity;
            Product2 Productsku = [SELECT StockKeepingUnit from Product2 WHERE Id =: pId];
            String sku = String.valueOf(Productsku.StockKeepingUnit);
            Map<String, Object> getdatamp = getInventroyData(pId);
            Decimal oldReservedQty = (Decimal)getdatamp.get('Reserve__c');
            Decimal reservedQuantity;
            if(oldReservedQty <= 0 )
            {
              reservedQuantity = 0;
            }
            else
            {
              reservedQuantity = oldReservedQty - qty;
            }
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/apexrest/Inventory__c/'+sku);
            request.setBody('{"Reserve__c":'+reservedQuantity+'}');
            request.setMethod('PATCH');
            request.setHeader('Authorization','Bearer '+UserInfo.getSessionId());
            request.setHeader('Content-Type', 'application/json');
            HttpResponse response = http.send(request);
            System.debug(response);

      }

      else
      {
          Product2 Productsku = [SELECT StockKeepingUnit from Product2 WHERE Id =: productId];

          String sku = String.valueOf(Productsku.StockKeepingUnit);
          system.debug(productId);
          Decimal reservedQuantity = Decimal.valueOf(reservedQuantity1);
          Map<String, Object> getdatamp = getInventroyData(productId);
          Decimal oldReservedQty = (Decimal)getdatamp.get('Reserve__c');
          if(decrease)
          {
          reservedQuantity = oldReservedQty - reservedQuantity ;
          }
          else
          {
            reservedQuantity = oldReservedQty + reservedQuantity ;
          }
          Http http = new Http();
          HttpRequest request = new HttpRequest();
          request.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/apexrest/Inventory__c/'+sku);
          request.setBody('{"Reserve__c":'+reservedQuantity+'}');
          request.setMethod('PATCH');
          request.setHeader('Authorization','Bearer '+UserInfo.getSessionId());
          request.setHeader('Content-Type', 'application/json');
          HttpResponse response = http.send(request);
          System.debug(response);
    }
    }
  
    @AuraEnabled
    public static ConnectApi.CartItem addToCart(
      String communityId,
      String productId,
      String quantity,
      String effectiveAccountId
    ) {
      // Lookup the webstore ID associated with the community
      String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
      
  
      ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();
      cartInput.productId = productId;
      cartInput.quantity = quantity;
      cartInput.type = ConnectApi.CartItemType.PRODUCT;

      updateReserved(quantity,productId,false,'NA',false);
      ConnectApi.CartSummary currentCart = ConnectApi.CommerceCart.getOrCreateActiveCartSummary(webstoreId,effectiveAccountId,'active');
      // String currentCartId = (String)currentCart.activeCartOrId;
      // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
      return ConnectApi.CommerceCart.addItemToCart(
        webstoreId,
        effectiveAccountId,
        'current',
        cartInput
      );
    }
  
    @AuraEnabled
    public static ConnectApi.Wishlist createAndAddToList(
      String communityId,
      String productId,
      String wishlistName,
      String effectiveAccountId
    ) {
      // Lookup the webstore ID associated with the community
      String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
  
      // Store the product in a WishlistItemInput to pass to the Wishlist
      ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();
      wishlistItemInput.productId = productId;
  
      //Create a wishlistInput to be created
      ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();
      wishlistInput.name = wishlistName;
      wishlistInput.products = new List<ConnectApi.WishlistItemInput>{
        wishlistItemInput
      };
  
      // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceWishlist_static_methods.htm#apex_ConnectAPI_CommerceWishlist_static_methods
      return ConnectApi.CommerceWishlist.createWishlist(
        webstoreId,
        effectiveAccountId,
        wishlistInput
      );
    }
     // Custom Method to fetch the data from inventory
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> getInventroyData(String productId){
      try {  
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = Url.getOrgDomainUrl().toExternalForm() +'/services/apexrest/Inventory__c/' + productId;
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer '+UserInfo.getSessionID());
        request.setHeader('Content-Type', 'application/json');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        Map<String, Object> results = new Map<String, Object>();
        if (response.getStatusCode() == 200) {
          // Deserialize the JSON string into collections of primitive data types.
          results = (Map<String, Object>) JSON.deserializeUntyped(
            response.getBody()
          );
          return results;
        }
        return results;
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }

    @AuraEnabled(cacheable=true)
    public static ConnectApi.ProductPrice getProductPrice(
      String communityId,
      String productId,
      String effectiveAccountId
    ) {
      // Lookup the webstore ID associated with the community
      String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
  
      // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceStorePricing_static_methods.htm#apex_ConnectAPI_CommerceStorePricing_static_methods
      return ConnectApi.CommerceStorePricing.getProductPrice(
        webstoreId,
        productId,
        effectiveAccountId
      );
    }
// creating a case when no product available
@AuraEnabled
    public static Case createCase(String descr, String userId){
         User cname = [SELECT Id, ContactId from User WHERE Id=:userId];
         Contact Cntname  = [SELECT Id, AccountId, Name from Contact WHERE Id=:cname.ContactId];
        Case cs = new Case();
        try {
            cs.Description = descr;
            cs.ContactId = Cntname.Id;
            cs.AccountId = Cntname.AccountId;
            insert cs;
            return cs;
           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getProductId(String sku){
      try {

        Product2 pId = [SELECT Id From Product2 Where StockKeepingUnit = :sku];
        String productId = String.valueOf(pId.Id);
        return productId;
        
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }

    // Reserving quantity in Inventory

   
  }