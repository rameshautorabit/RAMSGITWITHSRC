public class MembershipRenewalEmailTemplateController{
    
   // Public parameters

  public String membershipId
  {
    get {  
      return membershipId;              
    }
    set {
        system.debug('MembershipRenewalEmailTemplateController -> set membershipId -> ' + value);
      this.membershipId = value;
        if (rhMembership == null || this.membershipId != this.rhMembership.Id) {
          this.rhMembership = MembershipRenewalService.getMembershipRecord(membershipId);
        }
      }
    }
  
  public Membership__c rhMembership{
    get {
      return rhMembership;
    }
    set {
      system.debug('MembershipRenewalEmailTemplateController -> set rhMembership -> ' + value);
      this.rhMembership = value;
      this.contentHeader = this.initialize();      
    }
  }
  
  // Private - build by initialization
  
  private String contentHeader;

  // Public - referenced in component

  public String preview{get;set;}
  //public String dayPhone{get;set;}
  //public String content{get;set;}
  //public String benefits{get;set;}
  public String action{get;set;}
  //public String bestWishes{get;set;}
  public String legal{get;set;}
  public String subject{get;set;}
  //public String specialLine{get;set;}
  public String body{get;set;}
  public String header{get;set;}
  public String actionLine{get;set;}
  
  /*
   * Helper methods
   */

  public static String setProperCase(String str){
      String upDatedstr = '';
      if(str != null){
          for(String s : str.split(' ') ){
                if(upDatedstr != '') {
                    upDatedstr += ' ';
                }
                if (String.isNotBlank(s)) {
          upDatedstr += s.substring(0,1).toUpperCase()+''+s.substring(1, s.length()).toLowerCase();
                }
          }

      }
        system.debug('setProperCase -> ' + str + ' -> ' + upDatedstr);
      return upDatedstr;
  }

  public static String membersProgramUrl(String renewalOrderCode){
      Map<String, RH_Brand__c> mapBrand = RH_Brand__c.getAll();
      if(mapBrand.ContainsKey(renewalOrderCode)){
          return mapBrand.get(renewalOrderCode).RH_Members_Program_Profile_URL__c;
      }
      return mapBrand.get('999').RH_Members_Program_Profile_URL__c;
  }

  public static String termsAndConditionsUrl(String renewalOrderCode){
      Map<String, RH_Brand__c> mapBrand = RH_Brand__c.getAll();
      if(mapBrand.ContainsKey(renewalOrderCode)){
          return mapBrand.get(renewalOrderCode).TermsAndConditionsURL__c;
      }
      return mapBrand.get('999').TermsAndConditionsURL__c;
  }
  

   public String getMainParagraph() {
     return this.body;
   }
   
   /*
    * Intialize all the content 
    */
   
   public String initialize() {
     
     system.debug('MembershipRenewalEmailTemplateController -> initialize');

      Map<String, MembershipAmount__c> mapTerm = MembershipAmount__c.getAll();
         MembershipRenewalEmailTemplateController.MembershipInfo m = new MembershipRenewalEmailTemplateController.MembershipInfo(rhMembership);
         MembershipRenewalService.MembershipRenewalProperties mrp = new MembershipRenewalService.MembershipRenewalProperties(rhMembership);

       if (ApexPages.currentPage() != null && ApexPages.currentPage().getParameters().get('daysOut') != null) {
         system.debug('override stored value with one passed in by URL, as this is more up to date');
        mrp.daysOut = Integer.valueOf(ApexPages.currentPage().getParameters().get('daysOut'));
       } else if (mrp.daysOut == null) {
        system.debug('m.membership.Renewal_Email_Notification__c NULL AND days out not set by component');
        return null;
       }

         String contentHeader = '';
         String contactName = '';
         if (m.membership.Contact__c != null && m.membership.Contact__r.FirstName != null   ) {
    contactName = '<p style="font-weight: lighter; font-size: 19px; color: #fff; line-height: 20px; letter-spacing: .02em; font-family: Verdana, Geneva, sans-serif">Dear ' + setProperCase(m.membership.Contact__r.FirstName) + ',</p>';

         //     if (m.membership.Create_Renewal_Order__c) {
      //      contentHeader += '<p style="line-height: 20px; color: #fff;">Your membership will be extended on ' + m.ExpirationDate + ' and your account charged ' + m.membershipAmount + ' for another ' + m.membershipTermUnit + '. We will use the valid method of payment we have on file.</p>';
         }
         
         // Get the content based on a generated key
         // Which is created from the properties specific to this membership record

        String generatedKey = MembershipRenewalEmailService.generateMatchKey(mrp);
        system.debug(rhMembership.Name + '-> ' + mrp);  
    system.debug(rhMembership.Name + '-> ' + generatedKey);
        
        //replace with main body from excel
        //String dynamicContent = MembershipRenewalEmailService.getParagraphLine(generatedKey);  
        this.body =   contactName + MembershipRenewalEmailService.getBody(generatedKey);  //new

    
    if (String.isBlank(body)) {
      system.debug(this.rhMembership.Id + ' -> no matching key found for body content -> ' + generatedKey);
            return null;
         }

         

         //not needed
        //this.bestWishes = MembershipRenewalEmailService.getBestWishes(generatedKey);    
    //this.benefits = MembershipRenewalEmailService.getBenefitLine(generatedKey);
    //this.action = MembershipRenewalEmailService.getActionLine(generatedKey);
    //end

    this.legal = MembershipRenewalEmailService.getLegalLine(generatedKey);
    this.subject = MembershipRenewalEmailService.getSubjectLine(generatedKey);
    this.preview = MembershipRenewalEmailService.getPreviewLine(generatedKey);
 //   this.specialLine = MembershipRenewalEmailService.getSpecialLine(generatedKey);
    this.header = MembershipRenewalEmailService.getHeader(generatedKey);
    this.actionLine = MembershipRenewalEmailService.getActionLine(generatedKey);
    
         
    // preview SMR-617
    // should be handled by above content but need to get past UAT
    /*
    if (new Set<Integer>{60, 30, 5}.contains(mrp.daysOut) && mrp.expiringCC) {
      preview = MembershipEmailTemplateStrings.previewC;      
    } else if (new Set<Integer>{60, 30, 5}.contains(mrp.daysOut) && mrp.noCC) {
      preview = MembershipEmailTemplateStrings.previewD;        
    } else if (mrp.daysOut == 1 && mrp.noCC) {
      preview = MembershipEmailTemplateStrings.previewF;      
    } else if (mrp.daysOut == 1 && mrp.expiringCC) {
      preview = MembershipEmailTemplateStrings.previewE;
    } else if (mrp.daysOut == -1) {
      preview = MembershipEmailTemplateStrings.previewG;
    } else if (!mrp.autoRenew) {
       preview = MembershipEmailTemplateStrings.previewB;  
    } else {
       preview = MembershipEmailTemplateStrings.previewA;    
    }
    */
    // end         

         MembershipAmount__c termAmounts;
         if(mapTerm.ContainsKey(m.membership.Renewal_Term__c)){
            termAmounts = mapTerm.get(m.membership.Renewal_Term__c);
         }else{
            termAmounts = mapTerm.get('Annual');
         }

    
         String membersProgramLink;
         
         /*  This code is deprecated.  This was creating urls for the text/body of emails.  These urls have been replace by one url which is the special line string.  
         if(dynamicContent.Contains('[memberProfileHyperlink]')){
            membersProgramLink =  '<a style="color:#fff;border:none;" href="' + membersProgramUrl(m.membership.Renewal_Order_Entity_Code__c) + '">please visit your RH Members Program profile</a>';
            dynamicContent = dynamicContent.replace('[memberProfileHyperlink]', membersProgramLink);
         } else if (dynamicContent.Contains('[reEnrollRHMembersProgram]')){
           membersProgramLink =  '<a style="color:#fff;border:none;" href="' + membersProgramUrl(m.membership.Renewal_Order_Entity_Code__c) + '">re-enroll in the RH Members Program here</a>';
           dynamicContent = dynamicContent.replace('[reEnrollRHMembersProgram]', membersProgramLink);
         } else if (dynamicContent.Contains('[updatePaymentMethod]')){
            membersProgramLink =  '<a style="color:#fff;border:none;" href="' + membersProgramUrl(m.membership.Renewal_Order_Entity_Code__c) + '">Update your payment method here</a>';
            dynamicContent =  dynamicContent.replace('[updatePaymentMethod]', membersProgramLink);
         } else if (dynamicContent.Contains('[reEnrollRHMembersProgram_Revised]')){
           membersProgramLink =  '<a style="color:#fff;border:none;" href="' + membersProgramUrl(m.membership.Renewal_Order_Entity_Code__c) + '">re-enroll</a>';
           dynamicContent = dynamicContent.replace('[reEnrollRHMembersProgram_Revised]', membersProgramLink);
         } else if (dynamicContent.Contains('[reEnrollRHMembersProgram_Revised_60R]')){
           membersProgramLink =  '<a style="color:#fff;border:none;" href="' + membersProgramUrl(m.membership.Renewal_Order_Entity_Code__c) + '">re-enroll here</a>';
           dynamicContent = dynamicContent.replace('[reEnrollRHMembersProgram_Revised_60R]', membersProgramLink);
         } else if (dynamicContent.Contains('[updatePaymentMethod_Revised]')){
            membersProgramLink =  '<a style="color:#fff;border:none;" href="' + membersProgramUrl(m.membership.Renewal_Order_Entity_Code__c) + '">here</a>';
            dynamicContent =  dynamicContent.replace('[updatePaymentMethod_Revised]', membersProgramLink);
         }*/

         
        //contentHeader +=
          //  '<p style="line-height: 18px; font-family: \'adobe-caslon-pro\',Times,\'Times New Roman\',serif">' + MembershipEmailTemplateStrings.P1 + '</p>' +
           // '<p style="line-height: 18px; font-family: \'adobe-caslon-pro\',Times,\'Times New Roman\',serif">' + this.benefits + '</p>' +
            //'<p style="line-height: 18px; font-family: \'adobe-caslon-pro\',Times,\'Times New Roman\',serif">' + MembershipEmailTemplateStrings.P3  + '</p>' +
            //'<p style="line-height: 18px; font-family: \'adobe-caslon-pro\',Times,\'Times New Roman\',serif">' + dynamicContent  + '</p>'        //Create link that is used for users for the emails where they are asked to update cc info or re-enroll
      //  if (this.specialLine != 'NULL')    
      //    contentHeader += '<p style="font-family: \'proxima-nova \', \'open-sans \', Arial, Helvetica, sans-serif; padding: 25px 0 25px 0; text-transform: uppercase"><a style="color:#fff; text-decoration: none;" href="' + membersProgramUrl(m.membership.Renewal_Order_Entity_Code__c) + '" target="_blank">' + this.specialLine + '</a></p>';


    if (legal != null && legal.Contains('[membersTermsAndConditions]')) {
            String membersTandCLink;
            if (mrp.isQuebecois){
                membersTandCLink = '<a style="color: #999; text-decoration: underline;" href="http://images.restorationhardware.com/content/customer-service/rhmembers-terms-Quebec.pdf">RH Members Program Terms &amp; Conditions</a>';
            }else{
                membersTandCLink= '<a style="color: #999; text-decoration: underline;"  href="' + termsAndConditionsUrl(m.membership.Renewal_Order_Entity_Code__c) + '">RH Members Program Terms &amp; Conditions</a>';
            }
            legal = legal.replace('[membersTermsAndConditions]', membersTandCLink);
          //  legal = '<p>' + legal + '</p>';
    }






      //   if(action != null && action.Contains('[memberProfileHyperlink]')){
        //  membersProgramLink =  '<a style="color:#fff;border:none;" href="' + membersProgramUrl(m.membership.Renewal_Order_Entity_Code__c) + '">My Account</a>';
        //  action = action.replace('[memberProfileHyperlink]', membersProgramLink);
      //   }
     //    if(action != null && action.Contains('[expirationdate]')){
       //   action = action.replace('[expirationdate]', m.ExpirationDate);
      //   }
      //   System.Debug('content pre subs -> ' + contentHeader);
     //    contentHeader = contentHeader.replace('[expirationdate]', m.ExpirationDate);
       

         if (m.membershipAmount == null) {
      m.membershipAmount = '$100';
         }

         //new 
         if(body != null)
           {
             if (body.Contains('[expirationdate]'))
               {
              body = body.replace('[expirationdate]', m.ExpirationDate);
             }
             if (body.Contains('[membershipamount]'))
               {
              body = body.replace('[membershipamount]', m.membershipAmount);
             }
             if(body.Contains('[memberProfileHyperlink]')){
                membersProgramLink =  membersProgramUrl(m.membership.Renewal_Order_Entity_Code__c);
                body = body.replace('[memberProfileHyperlink]', membersProgramLink);
              }
       }


/*
       contentHeader = contentHeader.replace('[membershipamount]', m.membershipAmount);
       contentHeader = contentHeader.replace('[membershiptermunit]', m.membershipTermUnit);
       contentHeader = contentHeader.replace('[membershiptermunit]', m.membershipTermUnit); // may appear twice
       contentHeader = contentHeader.replace('[membershiptaxamount]', m.membershipTaxAmount);
       contentHeader = contentHeader.replace('[applicablemembershiptaxamount]', m.applicablemembershiptaxamount);
       contentHeader = contentHeader.replace('[preamblecanadiancontent]', mrp.isNonCanada ? ' preferred financing† plans on the RH credit card (subject to approval),' : '');
*/
       // Canada Suppression (SMR-449)
       // Should we remove this? (TBD)
       
       //get rid of
     //  if(benefits != null && !mrp.isNonCanada){
       //   benefits = benefits.replace('<p>Preferred Financing† Plans on the RH Credit Card Available. Subject to Approval</p>', '');
      // }

       system.debug('body ->' + body);
       //system.Debug('contentHeader -> ' + contentHeader);
       //system.Debug('benefits -> ' + benefits);
       //system.Debug('action -> ' +  action );
       //system.Debug('bestWishes -> ' +   bestWishes);
       system.Debug('legal -> ' +  legal  );
       system.Debug('subject -> ' +  subject);
       system.Debug('preview -> ' +  preview);

       return body;
  }
  
   /*
    * Membership details method (used inside one of the components - probably redundant)
    */  

   public List<MembershipRenewalEmailTemplateController.MembershipInfo> getMembershipDetails() {
       List<MembershipRenewalEmailTemplateController.MembershipInfo> listMembershipDetails = new List<MembershipRenewalEmailTemplateController.MembershipInfo>();
       Membership__c m = MembershipRenewalService.getMembershipRecord(membershipId);
       listMembershipDetails.add(new MembershipInfo(m));
       return listMembershipDetails;
   }
   
   /*
    * Membership Information
    */
 
  public class MembershipInfo {

    public Membership__c membership{get;set;}
    public String EnrollmentDate{get;set;}
    public String ExpirationDate{get;set;}
    public String membershipAmount{get;set;}
    public String membershipTaxAmount{get;set;}
    public String membershipTermUnit{get;set;}
    public String applicablemembershiptaxamount{get;set;}

       public MembershipInfo(Membership__c m) {
        this.membership = m;
        Map<String, MembershipAmount__c> mapAmount = MembershipAmount__c.getAll();
        String renewalTerm;
        if(m.Renewal_Term__c == null){
          renewalTerm = 'Annual';
        }else{
          renewalTerm = m.Renewal_Term__c;
        }
        if(mapAmount.ContainsKey(renewalTerm)){
           Decimal delta = mapAmount.get(renewalTerm).Amount__c.setScale(2) - mapAmount.get(renewalTerm).Amount__c.setScale(0);
           if(delta > 0){
              this.membershipAmount = '$' + String.valueOf(mapAmount.get(renewalTerm).Amount__c.setScale(2));
           }else{
              this.membershipAmount = '$' + String.valueOf(mapAmount.get(renewalTerm).Amount__c.setScale(0));
           }
           Decimal taxdelta = mapAmount.get(renewalTerm).Tax__c.setScale(2) - mapAmount.get(renewalTerm).Tax__c.setScale(0);
           if (taxdelta > 0) {
              this.membershipTaxAmount = '$' + String.valueOf(mapAmount.get(renewalTerm).Tax__c.setScale(2));
           } else {
              this.membershipTaxAmount = '$' + String.valueOf(mapAmount.get(renewalTerm).Tax__c.setScale(0));
           }

           this.MembershipTermUnit = mapAmount.get(renewalTerm).Unit__c;
        }

        if (!MembershipService.livesInCanada(m)) {
          this.applicablemembershiptaxamount = 'a year';
        } else {
          this.applicablemembershiptaxamount = 'of ' + this.membershipTaxAmount;
        }

        String mmEnroll = String.valueOf(m.Enrollment_Date__c.Month());
        if(mmEnroll.length() == 1){mmEnroll = '0' + mmEnroll;}
        String dayEnroll = String.valueOf(m.Enrollment_Date__c.Day());
        if(dayEnroll.length() == 1){dayEnroll = '0' + dayEnroll;}

        String mmExp = String.valueOf(m.Expiration_Date__c.Month()); System.Debug('mmexp === ' + mmExp);
        if(mmExp.length() == 1){mmExp = '0' + mmExp;}   System.Debug('mmexp after === ' + mmExp);
        String dayExp = String.valueOf(m.Expiration_Date__c.Day());
        if(dayExp.length() == 1){dayExp = '0' + dayExp;}

        this.EnrollmentDate = mmEnroll + '/' + dayEnroll + '/' + String.valueOf(m.Enrollment_Date__c.Year()); //tility.usWrittenDate(m.Enrollment_Date__c, true);
        this.ExpirationDate = mmExp + '/' + dayExp + '/' + String.valueOf(m.Expiration_Date__c.Year()).substring(2,4); //m.Expiration_Date__c; //String.valueOf(m.Expiration_Date__c); //Utility.usWrittenDate(m.Expiration_Date__c, true);
     }
   }

 }