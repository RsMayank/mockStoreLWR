//
//Raja Patnaik - 08/10-2020
//

public class avaTaxResponseJSON{
    public string id;  //10981799925
    public String code; //91166822-4ca9-4613-82d7-57c50df48740
    public Decimal companyId;   //1042175
    //public String sdate; //2020-08-10
    public String status;   //Committed
    public String type; //SalesInvoice
    public String batchCode;    //
    public String currencyCode; //USD
    public String customerUsageType;    //
    public String entityUseCode;    //
    public String customerVendorCode;   //B2B - Stratsys
    public String customerCode; //B2B - Stratsys
    public String exemptNo; //
    public boolean reconciled;
    public String locationCode; //
    public String reportingLocationCode;    //
    public String purchaseOrderNo;  //
    public String referenceCode;    //
    public String salespersonCode;  //
    public String taxOverrideType;  //None
    public Decimal taxOverrideAmount;   //0
    public String taxOverrideReason;    //
    public Decimal totalAmount; //177
    public Decimal totalExempt; //0
    public Decimal totalDiscount;   //0
    public Double totalTax; //13.72
    public Decimal totalTaxable;    //177
    public Double totalTaxCalculated;   //13.72
    public String adjustmentReason; //NotAdjusted
    public String adjustmentDescription;    //
    public boolean locked;
    public String region;   //GA
    public String country;  //US
    public Decimal version; //1
    public String softwareVersion;  //20.7.1.3
    public Decimal originAddressId; //5655347123
    public Decimal destinationAddressId;    //5655347123
    //public String exchangeRateEffectiveDate;    //2020-08-10
    public Decimal exchangeRate;    //1
    public boolean isSellerImporterOfRecord;
    public String description;  //
    public String email;    //
    public String businessIdentificationNo; //
    //public String modifiedDate; //2020-08-10T12:40:46.9243643Z
    public Decimal modifiedUserId;  //435637
    //public String taxDate;  //2020-08-10T00:00:00Z
    public cls_lines[] lines;
    public cls_addresses[] addresses;
    public cls_locationTypes[] locationTypes;
    public cls_summary[] summary;
    public class cls_lines {
        public Decimal id;  //6115148273
        public Decimal transactionId;   //10981799925
        public String lineNumber;   //1
        public Decimal boundaryOverrideId;  //0
        public String customerUsageType;    //
        public String entityUseCode;    //
        public String description;  //
        public Decimal destinationAddressId;    //5655347123
        public Decimal originAddressId; //5655347123
        public Decimal discountAmount;  //0
        public Decimal discountTypeId;  //0
        public Decimal exemptAmount;    //0
        public Decimal exemptCertId;    //0
        public String exemptNo; //
        public boolean isItemTaxable;
        public boolean isSSTP;
        public String itemCode; //GPIX2
        public Decimal lineAmount;  //177
        public Decimal quantity;    //3
        public String ref1; //
        public String ref2; //
        public String reportingDate;    //2020-08-10
        public String revAccount;   //
        public String sourcing; //Destination
        public Double tax;  //13.72
        public Decimal taxableAmount;   //177
        public Double taxCalculated;    //13.72
        public String taxCode;  //P0000000
        public Decimal taxCodeId;   //8087
        public String taxDate;  //2020-08-10
        public String taxEngine;    //
        public String taxOverrideType;  //None
        public String businessIdentificationNo; //
        public Decimal taxOverrideAmount;   //0
        public String taxOverrideReason;    //
        public boolean taxIncluded;
        public cls_details[] details;
        public cls_nonPassthroughDetails[] nonPassthroughDetails;
        public cls_lineLocationTypes[] lineLocationTypes;
        public String hsCode;   //
        public Decimal costInsuranceFreight;    //0
        public String vatCode;  //
        public Decimal vatNumberTypeId; //0
    }
    public class cls_details {
        public Decimal id;  //1000213939784
        public Decimal transactionLineId;   //6115148273
        public Decimal transactionId;   //10981799925
        public Decimal addressId;   //5655347123
        public String country;  //US
        public String region;   //GA
        public String countyFIPS;   //
        public String stateFIPS;    //13
        public Decimal exemptAmount;    //0
        public Decimal exemptReasonId;  //4
        public boolean inState;
        public String jurisCode;    //13
        public String jurisName;    //GEORGIA
        public Decimal jurisdictionId;  //17
        public String signatureCode;    //AMPQ
        public String stateAssignedNo;  //
        public String jurisType;    //STA
        public String jurisdictionType; //State
        public Decimal nonTaxableAmount;    //0
        public Decimal nonTaxableRuleId;    //0
        public String nonTaxableType;   //RateRule
        public Double rate; //0.04
        public Decimal rateRuleId;  //1421526
        public Decimal rateSourceId;    //3
        public String serCode;  //
        public String sourcing; //Destination
        public Double tax;  //7.08
        public Decimal taxableAmount;   //177
        public String taxType;  //Sales
        public String taxSubTypeId; //S
        public String taxTypeGroupId;   //SalesAndUse
        public String taxName;  //GA STATE TAX
        public Decimal taxAuthorityTypeId;  //45
        public Decimal taxRegionId; //4003576
        public Double taxCalculated;    //7.08
        public Decimal taxOverride; //0
        public String rateType; //General
        public String rateTypeCode; //G
        public Decimal taxableUnits;    //177
        public Decimal nonTaxableUnits; //0
        public Decimal exemptUnits; //0
        public String unitOfBasis;  //PerCurrencyUnit
        public boolean isNonPassThru;
        public boolean isFee;
    }
    public class cls_nonPassthroughDetails {
    }
    public class cls_lineLocationTypes {
        public Decimal documentLineLocationTypeId;  //11037880198
        public Decimal documentLineId;  //6115148273
        public Decimal documentAddressId;   //5655347123
        public String locationTypeCode; //ShipFrom
    }
    public class cls_addresses {
        public Decimal id;  //5655347123
        public Decimal transactionId;   //10981799925
        public String boundaryLevel;    //Zip5
        public String line1;    //
        public String line2;    //
        public String line3;    //
        public String city; //
        public String region;   //GA
        public String postalCode;   //30005
        public String country;  //US
        public Decimal taxRegionId; //4003576
        public String latitude; //34.081568
        public String longitude;    //-84.220392
    }
    public class cls_locationTypes {
        public Decimal documentLocationTypeId;  //0
        public Decimal documentId;  //10981799925
        public Decimal documentAddressId;   //5655347123
        public String locationTypeCode; //ShipFrom
    }
    public class cls_summary {
        public String country;  //US
        public String region;   //GA
        public String jurisType;    //State
        public String jurisCode;    //13
        public String jurisName;    //GEORGIA
        public Decimal taxAuthorityType;    //45
        public String stateAssignedNo;  //
        public String taxType;  //Sales
        public String taxSubType;   //S
        public String taxName;  //GA STATE TAX
        public String rateType; //General
        public Decimal taxable; //177
        public Double rate; //0.04
        public Double tax;  //7.08
        public Double taxCalculated;    //7.08
        public Decimal nonTaxable;  //0
        public Decimal exemption;   //0
    }
    public static avaTaxResponseJSON parse(String json){
        return (avaTaxResponseJSON) System.JSON.deserialize(json, avaTaxResponseJSON.class);
    }

   
}