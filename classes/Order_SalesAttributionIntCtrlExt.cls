public with sharing class Order_SalesAttributionIntCtrlExt {

    public boolean editMode {get; set;} {editMode = false;} // flag for rendering of edit version of Order_SalesAttribution page
    public boolean editable {get; set;} {editable = false;} // flag for rendering of edit button
    public boolean addMode {get; set;} {addMode = false;} // flag for rendering of Add button
    
    private final RH_Order__c rhOrder;
    RH_Order__c theRHOrder = new RH_Order__c();
    List<Sales_Attribution__c> salesAttributions = new List<Sales_Attribution__c>();
    
    Set<Sales_Attribution__c> deletedSAs =  new Set<Sales_Attribution__c>();
    Set<Sales_Attribution__c> addedSAs =  new Set<Sales_Attribution__c>();
    
    ApexPages.standardController sc = null;
                      
    public Order_SalesAttributionIntCtrlExt(ApexPages.StandardController stdController){
        this.rhOrder = (RH_Order__c)stdController.getRecord();
        
        sc = stdController; 
    }
    
    public List<Sales_Attribution__c> getSalesAttributions(){
        if(salesAttributions.isEmpty() && deletedSAs.isEmpty()){
            salesAttributions = [SELECT name, Actual_Associate_Name__c, Attribution_ID__c, Associate_Name__c, Primary_Associate__c, Attribution_Percent__c, Associate_s_Gallery_Number__c FROM Sales_Attribution__c where Order__c = :this.rhOrder.Id];
            
            System.debug('Sales Attribution size: ' + salesAttributions.size());
            
        }
        if(salesAttributions.size() < 3){  // only display Add button if < 3 sales attributions
            addMode = true;
        }else{
            addMode = false;
        }
        if(salesAttributions.size() > 0 && salesAttributions.size() <= 3){ // only display Edit button if between 0 and 3 sales attributions
            editable = true;
        }else{
            editable = false;
        }
        return salesAttributions;
    }
    
    public String getSalesAttributionOrderNumberFieldId(){ // read the id of the Order Number field on the Sales Attribution from custom settings
        FieldIdLookup__c SalesAttributionOrderNumberCustomSetting = FieldIdLookup__c.getInstance('Sales Attribution Order Number');
        String SalesAttributionOrderNumberFieldId = SalesAttributionOrderNumberCustomSetting.FieldId__c;
        
        return SalesAttributionOrderNumberFieldId;
    }
    
    public PageReference deleteRow(){ 
    
        String SelectedRowId = ApexPages.CurrentPage().getParameters().get('rowId');
        
        for (Integer i = 0; i < salesAttributions.size(); i++) {
            Sales_Attribution__c sa = salesAttributions[i];
            if (sa.Id == SelectedRowId) {
                deletedSAs.add(sa);
                salesAttributions.remove(i);
            }
        }
        return null;        
    }
    
    public PageReference addRow(){
        Sales_Attribution__c sa = new Sales_Attribution__c(Order__c = this.rhOrder.Id);
        
        salesAttributions = getSalesAttributions();
        
        System.debug('Sales Attributions before add: ' + salesAttributions.size());
        
        addedSAs.add(sa);
        salesAttributions.add(sa);
        
        editMode = true;
        return null;
    }
    
    public PageReference edit(){
        salesAttributions = getSalesAttributions();
        
        editMode = true;
        return null;
    }
    
    public PageReference save(){
        try{
            System.debug('Deleted SAs: ' + deletedSAs);
            System.debug('Sales Attributions size: ' + salesAttributions.size());
            
            if(salesAttributions.size() >= 3){
                addMode = false;
            }
            
            if(validateSAs(SalesAttributions)){
                List<Sales_Attribution__c> deletedSAList = new List<Sales_Attribution__c>(deletedSAs);      
                delete deletedSAList;
                upsert SalesAttributions;
                
                addedSAs.clear();
                deletedSAs.clear();
                salesAttributions.clear();
    
                editMode = false;   
            }
        }catch(Exception ex){
                ApexPages.addMessages(ex);
        }
        
        return null;
    } 
    
    public PageReference cancel(){
        
        if(!deletedSAs.isEmpty()){
            for(Sales_Attribution__c sa: deletedSAs){
                salesAttributions.add(sa);
            }
            deletedSAs.clear();
        }

        if(!addedSAs.isEmpty()){
            for(Sales_Attribution__c sa: addedSAs){
                removeObjectFromList(salesAttributions, sa);
            }
            addedSAs.clear();
        }
        
        if(salesAttributions.size() >= 3){
            addMode = false;
        }
        
        salesAttributions.clear();
        editMode = false;
        return null;
    }
    
    
    public static void removeObjectFromList(List<SObject> lst, SObject o) {
        for (Integer i = lst.size() - 1; i >= 0 ; --i) {
            if (lst.get(i) == o || lst.get(i).get('id') == o.get('id')) {
                lst.remove(i); 
            }
        }
    }
    
    public boolean validateSAs(List<Sales_Attribution__c> sas){ // perform validations
        Boolean validSAs = true;
        
        Decimal totalPercentage = 0.00;
        integer numberOfPrimaryContacts = 0;
        
         if(sas.size() == 0){
                validSAs = false;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'A minimum of one Associate is required for Sales Attribution. A maximum of three Associates may be added for Sales Attribution. Please update your attribution to continue.');
                ApexPages.addmessage(myMsg);
        }
        
        if(sas.size() > 0){
            if(sas.size() > 3){
                validSAs = false;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Maximum: 3 Attributions');
                ApexPages.addmessage(myMsg);
            }
   
            Set<String> uniqueAssNames = new Set<String>();
            for(Integer i = sas.size() - 1; i >= 0 ; --i){
            	uniqueAssNames.add(sas[i].Associate_Name__c);
            	if(sas[i].Associate_Name__c == null){
                    validSAs = false;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Associate name cannot be blank.');
                    ApexPages.addmessage(myMsg);
                }
            }
  
            if(sas.size() != uniqueAssNames.size()){
            	validSAs = false;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Associate already added.');
                ApexPages.addmessage(myMsg);
            }
             
            for(Integer i = sas.size() - 1; i >= 0; --i){
                if(sas[i].Attribution_Percent__c == null || sas[i].Attribution_Percent__c < 1 || sas[i].Attribution_Percent__c > 100){
                    validSAs = false;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'All Associates must have a % between 1 and 100. Please adjust your breakdown or remove the Associate.');
                    ApexPages.addmessage(myMsg);
                }else{
                    totalPercentage = totalPercentage + sas[i].Attribution_Percent__c;
                }
            }
            
            if(totalPercentage != 100){
                validSAs = false;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The sum of the %s must equal 100%. Please adjust your breakdown to add up to 100%.');
                ApexPages.addmessage(myMsg);
            }
            
            integer n = 0;
            for(Integer i = sas.size() - 1; i >= 0; --i){
                if(sas[i].Primary_Associate__c){
                    n++;
                }
            }
            if(n != 1){
                validSAs = false;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select (only) one Primary Contact per Order.');
                ApexPages.addmessage(myMsg);
            }
        }
        return validSAs;
    }
}