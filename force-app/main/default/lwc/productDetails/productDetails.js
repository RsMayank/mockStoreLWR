import { LightningElement, wire, api,track } from 'lwc';

import communityId from '@salesforce/community/Id';
import getProduct from '@salesforce/apex/B2BProductController.getProduct';
import getCartSummary from '@salesforce/apex/B2BProductController.getCartSummary';
import checkProductIsInStock from '@salesforce/apex/B2BProductController.checkProductIsInStock';
import addToCart from '@salesforce/apex/B2BProductController.addToCart';
import createAndAddToList from '@salesforce/apex/B2BProductController.createAndAddToList';
import getInventroyData from '@salesforce/apex/B2BProductController.getInventroyData';
import getProductPrice from '@salesforce/apex/B2BProductController.getProductPrice';
import updateReserved from '@salesforce/apex/B2BProductController.updateReserved';
import { resolve } from 'c/cmsResourceResolver';
import contextApi from 'commerce/contextApi';
import { refreshApex } from '@salesforce/apex';


/**
 * A detailed display of a product.
 * This outer component layer handles data retrieval and management, as well as projection for internal display components.
 */
export default class ProductDetails extends LightningElement {
    /**
     * Gets the effective account - if any - of the user viewing the product.
     *
     * @type {string}
     */
    @api
    get effectiveAccountId() {
        return this._effectiveAccountId;
    }

    /**
     * Sets the effective account - if any - of the user viewing the product
     * and fetches updated cart information
     */
    set effectiveAccountId(newId) {
        this._effectiveAccountId = newId;
        this.updateCartInformation();
    }

    /**
     * Gets or sets the unique identifier of a product.
     *
     * @type {string}
     */
    @api
    recordId;

    /**
     * Gets or sets the custom fields to display on the product
     * in a comma-separated list of field names
     *
     * @type {string}
     */
    @api
    customDisplayFields;
    isLoading = false;
    get messageState()
    {
        return this.isLoading?'Please Wait...':'Loading product information...';
    }
// API For avail product


    @track data ={};
    // @wire(getInventroyData,{
    //     productId: '$recordId'
    // })
    // inventoryData(result){
    //     if(result.data)
    //     {
    //         let parsedData = JSON.parse(JSON.stringify(result));
    //         this.data = parsedData.data;    
    //     }
    // }


    refreshInventoryData()
    {
        getInventroyData({productId : this.recordId})
        .then((result)=>
        {
            this.data = result;
            // console.log(this.data);
        })
        .catch((error)=>
        {
            console.log(error);
        });
    }
    
    /**
     * The cart summary information
     *
     * @type {ConnectApi.CartSummary}
     * @private
     */
    cartSummary;

    /**
     * The stock status of the product, i.e. whether it is "in stock."
     *
     * @type {Boolean}
     * @private
     */
    @wire(checkProductIsInStock, {
        productId: '$recordId'
    })
    inStock;

// @wire(checkProductIsInStock,{productId :'$recordId'})
//   async wiredStocks({ error, data }) 
//   {
//     console.log('wire call');
//     if (data) {
      
//       console.log('data wire : '  + data);
//       this.inStock = data;
//     } else if (error) {
//       console.log('error wire : '  + error);
//     }
//   }

    /**
     * The full product information retrieved.
     *
     * @type {ConnectApi.ProductDetail}
     * @private
     */
    @wire(getProduct, {
        communityId: communityId,
        productId: '$recordId',
        effectiveAccountId: '$resolvedEffectiveAccountId'
    })
    product;

    /**
     * The price of the product for the user, if any.
     *
     * @type {ConnectApi.ProductPrice}
     * @private
     */
    @wire(getProductPrice, {
        communityId: communityId,
        productId: '$recordId',
        effectiveAccountId: '$resolvedEffectiveAccountId'
    })
    productPrice;

    /**
     * The connectedCallback() lifecycle hook fires when a component is inserted into the DOM.
     */
    connectedCallback() {

                //fetch product inventory
                // checkProductIsInStock({productId:this.recordId})
                // .then((res)=> 
                // {
                //     console.log(JSON.stringify(res)  + '  : Imperative call in stock ');
                //     this.inStock = res;
                    // contextApi Call
                    console.log('productId : ' + this.recordId);
                    const result = contextApi.getSessionContext();
                    result.then((response) => {
                    console.log( "getSessionContext result" );
                    this._effectiveAccountId = response.effectiveAccountId;
                    console.log('getter : ' +  this.effectiveAccountId);
                    // other method calln
                    this.updateCartInformation();
                    this.refreshInventoryData();
                })
                .catch( ( error ) => {
                    console.log( "getSessionContext error" );
                    console.log( error );
                });
                // End of ContextApi
                // })
                // .catch((err) => 
                // {
                //     console.log(err);
                // });

    }
    disconnectedCallback()
    {
        console.log('Disconnected');
        this.refreshInventoryData();
        
    }

    /**
     * Gets the normalized effective account of the user.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get resolvedEffectiveAccountId() {
        const effectiveAccountId = this.effectiveAccountId || '';
        let resolved = null;

        if (
            effectiveAccountId.length > 0 &&
            effectiveAccountId !== '000000000000000'
        ) {
            resolved = effectiveAccountId;
        }
        return resolved;
    }

    /**
     * Gets whether product information has been retrieved for display.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get hasProduct() {
        return this.product.data !== undefined;
    }

    /**
     * Gets the normalized, displayable product information for use by the display components.
     *
     * @readonly
     */
    get displayableProduct() {
        return {
            categoryPath: this.product.data.primaryProductCategoryPath.path.map(
                (category) => ({
                    id: category.id,
                    name: category.name
                })
            ),
            description: this.product.data.fields.Description,
            image: {
                alternativeText: this.product.data.defaultImage.alternativeText,
                url: resolve(this.product.data.defaultImage.url)
            },
            inStock: this.inStock.data === true,
            name: this.product.data.fields.Name,
            price: {
                currency: ((this.productPrice || {}).data || {})
                    .currencyIsoCode,
                negotiated: ((this.productPrice || {}).data || {}).unitPrice
            },
            sku: this.product.data.fields.StockKeepingUnit,
            customFields: Object.entries(
                this.product.data.fields || Object.create(null)
            )
                .filter(([key]) =>
                    (this.customDisplayFields || '').includes(key)
                )
                .map(([key, value]) => ({ name: key, value }))
        };
    }

    /**
     * Gets whether the cart is currently locked
     *
     * Returns true if the cart status is set to either processing or checkout (the two locked states)
     *
     * @readonly
     */
    get _isCartLocked() {
        const cartStatus = (this.cartSummary || {}).status;
        return cartStatus === 'Processing' || cartStatus === 'Checkout';
    }

    /**
     * Handles a user request to add the product to their active cart.
     * On success, a success toast is shown to let the user know the product was added to their cart
     * If there is an error, an error toast is shown with a message explaining that the product could not be added to the cart
     *
     * Toast documentation: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_toast
     *
     * @private
     */


    @track cartDeadLock = false;  // it will not allow another add to cart until previous one finished
    
        get _isAddToCartDisabled() {
        return true //this._invalidQuantity || this.cartDeadLock;
    }

    addToCart(event) {
        this.isLoading = true;
        if(!(this.cartDeadLock))
        {
            
            this.cartDeadLock = true;
            // this._isAddToCartDisabled();
            console.log(this.cartDeadLock);
            if(event.detail.quantity > this.data.Available_for_Purchase__c)
            {
                let message = 'You Can Not Add More than ' + this.data.Available_for_Purchase__c;
                this.template.querySelector('c-show-toast-l-w-r').showToast(message,'info');
                return;
            }

            addToCart({
                communityId: communityId,
                productId: this.recordId,
                quantity: event.detail.quantity,
                effectiveAccountId: this.resolvedEffectiveAccountId
            })
                .then(() => {
                    this.refreshInventoryData();
                    this.dispatchEvent(
                        new CustomEvent('cartchanged', {
                            bubbles: true,
                            composed: true
                        })
                    );
                    this.isLoading = false;
                    this.template.querySelector('c-show-toast-l-w-r').showToast( 'Your cart has been updated.','success');
                    

                    // window.location.href = window.location.href;
                    // this.refreshInventoryData();
                })
                .catch((err) => {
                    console.log(JSON.stringify(err));
                    this.isLoading = false;
                    this.template.querySelector('c-show-toast-l-w-r').showToast( '{0} could not be added to your cart at this time. Please try again later.','error');
                });
        }
        else
        {
            this.isLoading = false;
            this.template.querySelector('c-show-toast-l-w-r').showToast( '{0} could not be added to your cart at this time. Please try again later.','error');

        }
        this.cartDeadLock = false;
    }

    /**
     * Handles a user request to add the product to a newly created wishlist.
     * On success, a success toast is shown to let the user know the product was added to a new list
     * If there is an error, an error toast is shown with a message explaining that the product could not be added to a new list
     *
     * Toast documentation: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_toast
     *
     * @private
     */
    createAndAddToList() {
        let listname = this.product.data.primaryProductCategoryPath.path[0]
            .name;
        createAndAddToList({
            communityId: communityId,
            productId: this.recordId,
            wishlistName: listname,
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
            .then(() => {
                this.dispatchEvent(new CustomEvent('createandaddtolist'));
                this.template.querySelector('c-show-toast-l-w-r').showToast( '{0} was added to a new list called "{1}"','error');
            })
            .catch(() => {
                this.template.querySelector('c-show-toast-l-w-r').showToast( '{0} could not be added to a new list. Please make sure you have fewer than 10 lists or try again later','error');
            });
    }

    /**
     * Ensures cart information is up to date
     */
    updateCartInformation() {
        console.log('account Id  CART: ' + this.resolvedEffectiveAccountId);
        getCartSummary({
            communityId: communityId,
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
            .then((result) => {
                this.cartSummary = result;
            })
            .catch((e) => {
                // Handle cart summary error properly
                // For this sample, we can just log the error
                console.log(e);
            });
    }
}