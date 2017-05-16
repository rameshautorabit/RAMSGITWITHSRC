public class WebtoCaseController
{

    public Attachment attach {get;set;}
    public Case c{get;set;}
    Public Contact contactObj;
    Public string companyName{get;set;}
    public string Emailval {get;set;}
    public string decriptopnVal{get;set;}
    public string phoneVal{get;set;}
    Public string subjectVal {get;set;}
    public string featureTypeVal{get;set;}
    public boolean webtoCasePage{get;set;}
    public string caseTypeVal{get;set;}
    public string loginurlTypeVal{get;set;}
    public string companyNameVal{get;set;}

    public WebtoCaseController() {
        attach = new Attachment();
        c = new Case();
        companyName = ApexPages.currentPage().getParameters().get('name');
        phoneVal = ApexPages.currentPage().getParameters().get('phone');
        Emailval = ApexPages.currentPage().getParameters().get('useremail');
        loginurlTypeVal = ApexPages.currentPage().getParameters().get('instanceurl');
        caseTypeVal = 'Web';
        companyNameVal = ApexPages.currentPage().getParameters().get('orgname');
    }
    public List<SelectOption> Category
    {
    get
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = case.Reason.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for( Schema.PicklistEntry f : ple)
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        return options;
    }
}
 
   /* public void searchdata()
    {
        
        If(string.isnotempty(companyName)||string.isnotempty(Emailval))
        {
            contactObj= [select id,name,email from Contact where (name = :companyName or email = :Emailval)][0];
                          
         }
            system.debug('@@@@@'+contactObj);
      }*/
    
    public PageReference Save()
    {
        //searchdata();
        Boolean okayToSave = true;
        webtoCasePage = true;
        
        try {
       /* if(contactObj!=null){
             c.Contactid = contactObj.id;
             }*/
             if (string.isblank(companyName))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'Please enter your name'));
                okayToSave = false;
                //return null;
            }
             if (string.isblank(Emailval))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'Please enter your email address'));
                okayToSave = false;
                //return null;
            }
             if (string.isblank(subjectVal))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'Please enter the Subject for your case'));
                okayToSave = false;
                //return null;
            }
            if( !okayToSave ) {
                return null;
            }
             c.SuppliedName = companyName;
             c.SuppliedPhone = phoneVal;
             c.SuppliedEmail = Emailval;
             c.CaseType__c = caseTypeVal;
             c.Subject = subjectVal;
             c.reason = featureTypeVal;
             c.description = decriptopnVal;
             c.Login_Url__c = loginurlTypeVal;
             c.SuppliedCompany = companyNameVal;
             
            insert c;
         if(attach.name!=null && attach.body!=null){
            attach.ParentId = c.id;
            insert attach;}
    } catch(System.DMLException e) {
        ApexPages.addMessages(e);
        return null;
    }
    PageReference pg = new PageReference('http://autorabit.force.com/thankyou');
    pg.setRedirect(true);
    return pg;
}

}