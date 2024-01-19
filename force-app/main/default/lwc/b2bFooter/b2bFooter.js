import { LightningElement, wire, track, api} from 'lwc';
import getlinks from '@salesforce/apex/b2bFooterController.getLinks';
import icon from '@salesforce/resourceUrl/Icon';
import checkGuest from '@salesforce/user/isGuest';
import Id from '@salesforce/user/Id';
import userDetail from '@salesforce/apex/B2B_ContactUs.UserDefine';
import guestDetail from '@salesforce/apex/B2B_ContactUs.GuestDefine';
import logoPNG from '@salesforce/resourceUrl/logoPNG';
import B2B_Contact_Us from '@salesforce/label/c.B2B_Contact_Us';
import B2B_Terms from '@salesforce/label/c.B2B_Terms';
import B2B_TradeMark from '@salesforce/label/c.B2B_TradeMark';
import Privacy_Centre from '@salesforce/label/c.Privacy_Centre';

export default class NewFooter extends LightningElement {
    UserID=Id;
    mapData;
    @track isShowModalRegister = false;
    @track isShowModalGuest = false;
    firstName;
    lastName;
    company;
    email;
    commentsUser;
    commentsGuest;
   labels = {
    B2B_Contact_Us,
    B2B_TradeMark,
    B2B_Terms,
    Privacy_Centre
   };
    @wire(getlinks)
    wiredResult(result) { 
        if (result.data) {
            this.mapData = result.data;
        }
    }

    // <----------------------------------------------Accessing Icons------------------------------------------------------->
    progressIcon = logoPNG ;
    Youtube = icon + '/Icons/Youtube.png' ;
    Facebook = icon + '/Icons/facebook.png' ;
    Twitter = icon + '/Icons/twitter.png' ;
    Linkedin = icon + '/Icons/linkedin.png' ;

    
    showModalBox() { 
        if(checkGuest){
            this.isShowModalGuest=true;
        }
        else{
            this.isShowModalRegister=true;
        }
    }
    hideModalBox() {
        if(checkGuest){
            this.isShowModalGuest=false;
        }
        else{
            this.isShowModalRegister=false;
        }
    }

    registerComm(event){
        this.commentsUser=event.target.value;
    }

    eventhandlerForUser(event){
        // var inp=this.template.querySelectorAll("lightning-input");
        // inp.forEach(function(element){
        //     if(element.name=="commentregister")
        //         this.commentsUser=element.value;
        // },this);
        userDetail({uID:this.UserID,Comm:this.commentsUser})
        .then((result) => {
            this.result = result;
            console.log(this.commentsUser);
            console.log(this.result);
            console.log("Success");
        })
        .catch((error) => {
            this.error = error;
            console.log(this.error);
            console.log("Error");
        });
         this.isShowModalRegister = false;
    }

    GuestComm(event){
        this.commentsGuest=event.target.value;
    }
    eventhandlerForGuest(event){
        var inp=this.template.querySelectorAll("lightning-input");
        inp.forEach(function(element){
            // if(element.name=="commentGuest")
            //     this.commentsGuest=element.value;
            if(element.name=='fName')
                this.firstName=element.value;
            else if(element.name=='lName')
                this.lastName=element.value;
            else if(element.name=='email')
                this.email=element.value;
            else if(element.name=='cName')
                this.company=element.value;
        },this);
        
        guestDetail({fn:this.firstName,ln:this.lastName,comp:this.company,mail:this.email,Comm:this.commentsGuest})
        .then((result) => {
            this.result = result;
            console.log(this.commentsGuest);
            console.log(this.result);
            console.log("Success");
        })
        .catch((error) => {
            this.error = error;
            console.log(this.error);
            console.log("Error");
        });
         this.isShowModalGuest = false;
    }

}