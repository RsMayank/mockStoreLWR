/**
 * @author : Mayank Srivastava
 * @Date : July-10-2023
 * @LastModified :July-27-2023
 */
import {api, LightningElement} from 'lwc';
import fetchCarousels from '@salesforce/apex/B2BCarouselController.fetchCarousel';
import {applicationLogging} from 'c/b2bUtil';
import communityId from "@salesforce/community/Id";
import B2B_Spin_Message from '@salesforce/label/c.B2B_Spin_Message';

export default class b2bHomeCarousel extends LightningElement {

    /**
     *  Gets or sets the layout of this component. Possible values are: grid, list.
     *
     * @type {string}
     */
    @api
    propertyScroll;
    
    @api
    propertyScrollDuration;
    
    carousels = [];
    showCarousels = false;
    messageState = B2B_Spin_Message;
    connectedCallback() {
        this.messageState = B2B_Spin_Message;
        this.retrieveCarousels();
    }

    retrieveCarousels()
    {
        let dataMap ={
            communityId : communityId
        };
        fetchCarousels({'dataMap' : dataMap})
            .then((result) => {

                setTimeout(() => {
                    this.showCarousels = result.isSuccess;
                }, 2000);
                
               if(result.isSuccess)
               {
                   this.carousels = result.carouselObjs;
               }
                if(result && result.log)
                {
                    applicationLogging(result.log);
                }
            })
            .catch(() => {
                
            });
    }
    
}