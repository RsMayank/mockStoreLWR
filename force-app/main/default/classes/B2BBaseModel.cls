global virtual class B2BBaseModel {
    global String message;
    global Boolean status;
    global virtual void setErrorMessage(String errorMsg) {
        this.message = errorMsg;    
    }

    global virtual String getErrorMessage() {
        return message;    
    }

    global virtual void setStatus(Boolean status) {
        this.status = status;    
    }

    global virtual Boolean getStatus() {
        return status;    
    }
    
}