import { LightningElement,track } from 'lwc';
import storelogo from '@salesforce/resourceUrl/logo';
import checkForEmailExistence from '@salesforce/apex/B2B_RegistrationController.checkForEmailExistence';
import RegisterUser from '@salesforce/apex/B2B_RegistrationController.RegisterUser';
// import createLeadRecord from '@salesforce/apex/B2B_FooterController.createLeadRecord';
import ToastContainer from 'lightning/toastContainer';

export default class b2b_UserRegistration extends LightningElement {
    paclogo = storelogo;
    messageState = 'Loading';
    @track firstName='';
    @track lastName='';
    @track email='';
    @track phone='';
    @track accountName ='Hero Corps';
    @track password = '';
    @track confirmPassword='';
    loginUrl;
    showSpinner = true;
    emailExistErr = false;
    phoneExistErr = false;
    isShowModal = false;
    userCreated = false;
    @track message = '';
    errorMessage='';
    UserCreatError = '';

    showModalBox() {  
        this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;
    }
    emailChange(event) {
        this.email = event.target.value;
        this.validateEmail();
        this.checkEmail();
    }

    firstNameChange(event) {
        this.firstName = event.target.value;
        this.validateFirstName();
    }

    lastNameChange(event) {
        this.lastName = event.target.value;
        this.validateLastName();
    }
    phoneChange(event) {
        this.phone = event.target.value;
        this.validatePhone();
        this.checkPhone();
    }
    accountChange(event){
        this.accountName = event.target.value;
        this.validateAccount();
    }

    // passwordChange(event) {
    //     this.password = event.target.value;
    //     this.validatePassword();

    // }

    confirmPasswordChange(event) {
        this.confirmPassword = event.target.value;
        this.validateConfirmPassword();

    }

    showEmailErr = false;
    showFirstNameErr = false;
    showLastNameErr = false;
    showPhoneErr = false;
    showAccountErr = false;
    showPasswordMatchErr = false;

    passwordErrMsg = 'Please give valid password';
    showPasswordErr = false;

    confirmPasswordErrMsg = 'Please give valid password';
    showConfirmPasswordErr = false;

    connectedCallback(){
        this.messageState = 'Please wait :)';
        this.showSpinner = false;
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 5;
        
    }

    
    validateEmail() {
        let email = this.email;
        let re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if (re.test(String(email).toLowerCase())) {
            this.showEmailErr = false;
            if (this.email == null || this.email == '' || this.email.trim() == '') {
                this.showEmailErr = true;
                return false;
            }
            else {
                this.showEmailErr = false;
                return true;
            }
        }
        else {
            this.showEmailErr = true;
            return false;
        }
    }
    async checkEmail(){
        const dataMap = {'email': this.email };
        try {
            const response = await checkForEmailExistence({ dataMap: dataMap });
            if (response.isEmailExist) {
                this.emailExistErr = true;
                this.showEmailExistErr = 'Email Already Exist';
            } else {
                this.emailExistErr = false;
                this.showEmailExistErr = '';
            }
        } catch (error) {
            console.error('Error calling Apex method: ', error);
        }
    }

    validateFirstName() {
        if (this.firstName == null || this.firstName == '' || this.firstName.trim() == '') {
            this.showFirstNameErr = true;
            return false;
        } else {
            this.showFirstNameErr = false;
            return true;
        }
    }

    validateLastName() {
        if (this.lastName == null || this.lastName == '' || this.lastName.trim() == '') {
            this.showLastNameErr = true;
            return false;
        } else {
            this.showLastNameErr = false;
            return true;
        }
    }

    validatePhone() {
        let phone = this.phone;
        let phoneCheck = /^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4}$/;
        if(phoneCheck.test(String(phone))){
            this.showPhoneErr = false
            if (this.phone == null || this.phone == '' || this.phone.trim() == '') {
                this.showPhoneErr = true;
                return false;
            } else {
                this.showPhoneErr = false;
                return true;
            }
        }
        else{
            this.showPhoneErr = true;
            return false;
        }
    }

    async checkPhone(){
        const dataMap = {'phone': this.phone };
        console.log('inside Phone Check 1');
        try {
            console.log('inside Phone Check 2');
            const response = await checkForEmailExistence({ dataMap: dataMap });
            console.log('inside Phone Check 2'+JSON.stringify(response));
            if (response.isPhoneExist) {
                console.log('inside Phone Check 3'+JSON.stringify(response));
                this.phoneExistErr = true;
                this.showPhoneExistErr = 'Phone Number Already Exist';
            } else {
                this.phoneExistErr = false;
                this.showPhoneExistErr = '';
            }
        } catch (error) {
            console.error('Error calling Apex method: ', error);
        }
    }
    validatePassword() {
        let password = this.password;
        let pa = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/;
        if (pa.test(String(password))) {

            this.showPasswordErr = false;
            if (this.password == null || this.password == '' || this.password.trim() == '') {
                this.showPasswordErr = true;
                return false;
            }
            else {
                this.showPasswordErr = false;
                return true;
            }
        }
        else {
            this.showPasswordErr = true;
            return false;
        }
    }
    validateConfirmPassword() {
        let confirmPassword = this.confirmPassword;
        let cpa = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/;
        if (cpa.test(String(confirmPassword))) {
            this.showConfirmPasswordErr = false;
            if (this.confirmPassword === this.password) {
                this.showPasswordMatchErr = false;
                return true;
            } else {
                this.showPasswordMatchErr = true;
                return false;
            }
        } else {
            this.showConfirmPasswordErr = true;
            this.showPasswordMatchErr = false; // Reset the match error if the format is invalid
            return false;
        }
    }    
    validateAccount() {
        console.log('inside vaidate account');
        if (this.accountName == null || this.accountName == '' || this.accountName.trim() == '') {
            this.showAccountErr = true;
            return false;
        } else {
            this.showAccountErr = false;
            return true;
        }
    }
    // password strength

    showValidation;
    handleFocus() {
      this.showValidation = true;
    }
    handleBlur() {
      this.showValidation = false;
    }
    passwordChange(event) {
      // Validate lowercase letters
      this.password = event.target.value;
    //   this.validatePassword();
      let passwordValue = this.password;
      var lowerCaseLetters = /[a-z]/g;
      if (passwordValue.match(lowerCaseLetters)) {
        this.template
          .querySelector('[data-id="letter"]')
          .classList.remove("invalid");
        this.template.querySelector('[data-id="letter"]').classList.add("valid");
      } else {
        this.template
          .querySelector('[data-id="letter"]')
          .classList.remove("valid");
        this.template
          .querySelector('[data-id="letter"]')
          .classList.add("invalid");
      }
  
      // Validate capital letters
      var upperCaseLetters = /[A-Z]/g;
      if (passwordValue.match(upperCaseLetters)) {
        this.template
          .querySelector('[data-id="capital"]')
          .classList.remove("invalid");
        this.template.querySelector('[data-id="capital"]').classList.add("valid");
      } else {
        this.template
          .querySelector('[data-id="capital"]')
          .classList.remove("valid");
        this.template
          .querySelector('[data-id="capital"]')
          .classList.add("invalid");
      }
  
      // Validate numbers
      var numbers = /[0-9]/g;
      if (passwordValue.match(numbers)) {
        this.template
          .querySelector('[data-id="number"]')
          .classList.remove("invalid");
        this.template.querySelector('[data-id="number"]').classList.add("valid");
      } else {
        this.template
          .querySelector('[data-id="number"]')
          .classList.remove("valid");
        this.template
          .querySelector('[data-id="number"]')
          .classList.add("invalid");
      }
  
      // Validate length
      if (passwordValue.length >= 8) {
        this.template
          .querySelector('[data-id="length"]')
          .classList.remove("invalid");
        this.template.querySelector('[data-id="length"]').classList.add("valid");
      } else {
        this.template
          .querySelector('[data-id="length"]')
          .classList.remove("valid");
        this.template
          .querySelector('[data-id="length"]')
          .classList.add("invalid");
      }
    }

    // /--------------------------------------------------------------------/
    handleSignUp() {
        if(this.validate() && !this.emailExistErr && !this.phoneExistErr){
            this.initUserRegistration();
        }
        else{
            this.UserCreatError = 'Please Check all the fields once again.';
        }
    }

    validate(){
        let isValid = true;
        if(!this.validateFirstName()){
            isValid = false;
        }
        if(!this.validateLastName()){
            isValid = false;
        }
        if(!this.validateEmail()){
            isValid = false;
        }
        if(!this.validatePhone()){
            isValid = false;
        }
        if(!this.validateAccount){
            isValid = false;
        }
        if(!this.validatePassword){
            isValid = false;
        }
        if(!this.validateConfirmPassword){
            isValid = false;
        }
        return isValid;
    }
    initUserRegistration(){
        this.messageState = 'We are registering you as a user. Thank You! :)';
        let dataMap = {
            'firstName': this.firstName,
            'lastName': this.lastName,
            'email': this.email,
            'phone': this.phone,
            'accountName': this.accountName,
            'password':this.password

        }
        this.showSpinner = true;
        RegisterUser({
            'dataMap': dataMap
        }).then((result)=>{
            console.log('dataMap for create class'+JSON.stringify(result));
            if(result && result.isSuccess){
                console.log('dataMap for create class 1'+JSON.stringify(result));
                this.showSpinner = false;
                this.userCreated = true;
                console.log('user created successfully');
                this.loginUrl = result.loginUrl;
                this.template.querySelector('c-show-toast-l-w-r').showToast('Account Created Successfully','success');
                window.location.href = this.loginUrl;
            }
        })
        .catch((er)=>{
            this.showSpinner = false;
            console.log(er);
        });

    }

    // -------------create a lead - ------------------
    @track company = '';
    @track description='';

    leadChangefirst(event){
        this.firstName = event.target.value;
    }
    leadChangelast(event){
        this.lastName = event.target.value;
    }
    leadChangeemail(event){
        this.email = event.target.value;
    }
    leadChangecomp(event){
        this.company = event.target.value;
    }
    leadChangedesc(event){
        this.description = event.target.value;
    }
    // insertLeadAction() {
    //     const leadData = [
    //         {
    //             firstName: this.firstName,
    //             lastName: this.lastName,
    //             email: this.email,
    //             company: this.company,
    //             description: this.description
    //         }
    //     ];
    //     console.log('inside the lead creation');
    //     createLeadRecord({ dataMaps: leadData })
    //         .then(result => {
    //             console.log('lead'+JSON.stringify(result));
    //             if (result && result.length > 0) {
    //                 this.message = 'Form Submitted Successfully';
    //                 this.error = undefined;
    //                 this.clearFormFields();
    //                 this.showToast('Success', 'Form Submitted Successfully', 'success');
    //                 console.log(JSON.stringify(result));
    //             } else {
    //                 this.error = 'No leads were created';
    //                 this.showToast('Error', 'No leads were created.', 'error');
    //             }
    //         })
    //         .catch(error => {
    //             this.message = undefined;
    //             this.error = error.body.message;
    //             this.showToast('Failed to Save the record','please enter the details to reach us.', 'error');
    //             console.error(JSON.stringify(this.error));
    //         });
    //     }


        clearFormFields() {
            this.firstName = '';
            this.lastName = '';
            this.email = '';
            this.company = '';
            this.description = '';
        }
        showToast(title, message, variant) {
            const event = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            });
            this.dispatchEvent(event);
        }
}