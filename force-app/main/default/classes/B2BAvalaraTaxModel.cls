/**
 * Created by rpatnaik on 03/23/19.
 */
global class B2BAvalaraTaxModel extends B2BBaseModel {
    
    
    
    global String country {get; set;}
    global Decimal taxAmount {get; set;}
    global Decimal taxRate {get; set;}
    global Decimal taxableAmount {get; set;}
    global Decimal totalAmount {get; set;}



}