/**
 * Created by rpatnaik on 03/23/19.
 */
public class B2BAvalaraTaxUtil {
    
    public static Map<String,B2BAvalaraTaxModel > calculateTax(Map<String, cartItem> cartItemsBySKU,String postalCode, 
    String country,String transactionType) {
                       
        
        String taxServiceUrl = '/api/v2/transactions/create';
        //String userName = 'rpatnaik@docmation.com2';
        //String password = '0tJ$13cW9*eM';
        String companyCode = 'DCM';
        String customerCode = 'B2B - Stratsys';   
        
        //String taxCode,Decimal amount,    
        
        System.debug('cartItemsBySKU ' +cartItemsBySKU);      
                           
        HttpRequest req = getTaxServiceRequestHeader(taxServiceUrl);
        
        String body = getTaxServiceRequestBody( companyCode,  customerCode, postalCode,  country,transactionType
        ,cartItemsBySKU);
        
        req.setBody(body); 
        
        System.debug('Setting request body' + body);
        
        
        Map<String,B2BAvalaraTaxModel > mapAvaTaxModel = new Map<String,B2BAvalaraTaxModel>();
                           
        Http http = new Http();
        try {
            HTTPResponse res = null;
            if (!Test.isRunningtest())
                {
                    res = http.send(req); 
                }else{
                    res = new HTTPResponse();
                    Integer statusCode = 201;
                    res.setBody('{"totalTaxable":10.0,"rate":2.0,"totalTax":2.0,"country":"US"}');
                    res.setStatus('Success');
                    res.setStatusCode(statusCode);
                    //system.debug('... ' +json.serialize(AppLauncher.CommerceStoreController.getCommerceContext() ));

                }  
            System.debug('STATUS_CODE:'+res.getStatusCode());
            System.debug('Response body ' + res.getBody());
            Integer statusCode = res.getStatusCode();
            if (statusCode == 201) {
                String avaResponse = res.getBody();
                
                
                 avaTaxResponseJSON avaTaxJSON = (avaTaxResponseJSON) System.JSON.deserialize(avaResponse, avaTaxResponseJSON.class);
                 System.debug('avaTaxJSON ' + avaTaxJSON.lines);
                 List<avaTaxResponseJSON.cls_lines> lstAvaTax = avaTaxJSON.lines ;
                 System.debug('avaTaxJSON ' + lstAvaTax);
                 
                 for(avaTaxResponseJSON.cls_lines objTax : lstAvaTax)
                 {
                      B2BAvalaraTaxModel tax = new B2BAvalaraTaxModel();
                      
                      tax.taxAmount =objTax.taxCalculated;
                      
                      
                    System.debug('objTax ' + objTax.taxCalculated);
                    
                    System.debug('avaTaxDetails ' + objTax.details);
                    
                    List<avaTaxResponseJSON.cls_details> lstAvaTaxDetails = objTax.details ;
                    
                    System.debug('lstAvaTaxDetails ' + lstAvaTaxDetails);
                    
                    Decimal totalTaxRate = 0.0 ;
                    
                    for(avaTaxResponseJSON.cls_details objTaxDetails : lstAvaTaxDetails)
                    {
                        
                        System.debug('objTax ' + objTaxDetails.rate);
                        totalTaxRate += objTaxDetails.rate;
                    
                    }
                    System.debug('totalTaxRate ' + totalTaxRate);
                    tax.taxRate = totalTaxRate;
                    
                    mapAvaTaxModel.put(objTax.itemCode,tax);
                     
                    
                 }
                 
                
                
            } else if (statusCode == 400) {
                System.debug('Error retrieving Tax ' + statusCode);
                System.debug('Error retrieving Tax response ' + res.getBody());
                throw new B2BTaxException(B2BTaxException.EXCEPTION_TAX_INVALID_CODE);
            } else {
                System.debug('Error retrieving Tax ' + statusCode);
                System.debug('Error retrieving Tax response ' + res.getBody());
                throw new B2BTaxException(B2BTaxException.EXCEPTION_TAX_SERVICE_ERROR);
            }
        } catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new B2BTaxException(B2BTaxException.EXCEPTION_TAX_CALLOUT);
        }  
        
        system.debug('Tax Model '+mapAvaTaxModel);
        
        return mapAvaTaxModel;
    }
    
    public static HttpRequest getTaxServiceRequestHeader(String taxServiceUrl) {
        //Blob headerValue = Blob.valueOf(userName + ':' + password);
        //String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        //System.debug('Setting auth header ' + authorizationHeader);

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        req.setEndpoint('callout:Avalara'+taxServiceUrl);
        //req.setEndpoint(taxServiceUrl);
        System.debug('Setting request header');      
        //req.setHeader('Authorization', authorizationHeader);
        return req;        
    }
    
    public static String getTaxServiceRequestBody(String companyCode, String customerCode, 
                       String postalCode, String country,String transactionType,Map<String, cartItem> cartItemsBySKU) {
        String body = '';
        body += '{"type": "' + transactionType + '",';   
        body += '"businessIdentificationNo":"", '; 
        body += '"companyCode": "' + companyCode + '",   ';
        body += '"date":"' +  System.now() + '",    ';
        body += '"customerCode": "' + customerCode + '",   ';
        body += '"lines":   [       ';
        
        for(cartItem cartItemObj : cartItemsBySKU.values()){
        
        
            body += '       {    ';
            body += '           "itemCode" :"' + cartItemObj.Sku + '",';   
            body += '           "quantity" :"' + cartItemObj.Quantity + '",'; 
            body += '           "amount": ' +  cartItemObj.TotalLineAmount;
            body += '       },       ';
        }
        
        body = body.removeEnd(',');
        
        body += '   ],     ';
        
        
        body += '"addresses":  {            ';
        body += '   "singleLocation": {            ';
        body += '       "country": "' + country + '"';
        if (!String.isBlank(postalCode)) {
            body += '       ,"postalCode": "' + postalCode + '"';                        
        }
        body += '   }     ';
        body += '},  "commit": true,"currencyCode": "' + UserInfo.getDefaultCurrency() + '"'; 
        body += '}';
        return body;
    }

}