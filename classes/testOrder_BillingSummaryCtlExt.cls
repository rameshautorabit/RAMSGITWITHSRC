/*
 *  Methods to test Order_BillingSummaryCtlExt.cls and related classes/methods
 *
 */

@isTest
private class testOrder_BillingSummaryCtlExt {
  
  // Set up data for BillingSummaryTemplate custom setting
  @testSetup static void BillingSummaryTemplate() {
    List<BillingSummaryTemplate__c> bstList = new List<BillingSummaryTemplate__c>();
    List<CPULimitThreshold__c> cpuLimit = new List<CPULimitThreshold__c>();
    cpuLimit.add(new CPULimitThreshold__c(Name='Asynchronous', Milliseconds__c=60000));
    cpuLimit.add(new CPULimitThreshold__c(Name='Synchronous', Milliseconds__c=10000));
    insert cpuLimit; 
    
    BillingSummaryEmailService__c bses = new BillingSummaryEmailService__c(); 
    bses.Name = 'SendBillingSummaryEmail';
    bses.EmailServiceEmailAddress__c = 'pmandy@rh.com';
    insert bses;
    
    bstList.add(new BillingSummaryTemplate__c(
      Name = 'Contract',
      Email1__c = 'contractprojects@rh.com',
      Email2__c = 'contractprojects@RH.com',
      FromName__c = 'Contract Support',
      Phone1__c = '855-406-6199',
      Phone2__c = '8554066199',
      Phone3__c = '855-406-6199')
    );
    bstList.add(new BillingSummaryTemplate__c(
      Name = 'Corporate',
      Email1__c = 'cei@rh.com',
      Email2__c = 'cei@RH.com',
      FromName__c = 'Restoration Hardware',
      Phone1__c = '866-547-3364',
      Phone2__c = '8665473364',
      Phone3__c = '866-547-3364')
    );
    bstList.add(new BillingSummaryTemplate__c(
      Name = 'Platinum',
      Email1__c = 'platinumcs@rh.com',
      Email2__c = 'platinumcs@RH.com',
      FromName__c = 'Restoration Hardware',
      Phone1__c = '888-671-1699',
      Phone2__c = '8886711699',
      Phone3__c = '888-671-1699')
    );
    bstList.add(new BillingSummaryTemplate__c(
      Name = 'Standard',
      Email1__c = 'webcs@rh.com',
      Email2__c = 'webcs@RH.com',
      FromName__c = 'Restoration Hardware',
      Phone1__c = '877-777-7059',
      Phone2__c = '8777777059',
      Phone3__c = '877-777-7059')
    );
    insert bstList;
  }
  
  // Set up data for PaymentType custom setting
  @testSetup static void PaymentType() {
    List<PaymentType__c> ptList = new List<PaymentType__c>();
    String ltNone = 'NONE';
    String ltRH = 'RH';
    String doNotUse = 'DO NOT USE';
    String rhLogo = 'https://media.restorationhardware.com/is/image/rhis/rh-logo-35x20?wid=35&fmt=png&qlt=85,1&iccEmbed=0';
    String whitebox = 'https://media.restorationhardware.com/is/image/rhis/white-box-35x20?wid=35&fmt=png&qlt=85,1&iccEmbed=0';
    
    ptList.add(new PaymentType__c(
      Name = '1',
      Description__c = doNotUse,
      Logo_Type__c = ltNone,
      Logo_URL__c = whitebox)
    );
    ptList.add(new PaymentType__c(
      Name = '3',
      Description__c = 'AMERICAN EXPRESS',
      Logo_Type__c = 'AMEX',
      Logo_URL__c = 'https://media.restorationhardware.com/is/image/rhis/amex-straight-35x20?wid=35&fmt=png&qlt=85,1&iccEmbed=0')
    );
    ptList.add(new PaymentType__c(
      Name = '4',
      Description__c = 'VISA',
      Logo_Type__c = 'VISA',
      Logo_URL__c = 'https://media.restorationhardware.com/is/image/rhis/visa-straight-35x20?wid=35&fmt=png&qlt=85,1&iccEmbed=0')
    );
    ptList.add(new PaymentType__c(
      Name = '5',
      Description__c = 'MASTERCARD',
      Logo_Type__c = 'MASTERCARD',
      Logo_URL__c = 'https://media.restorationhardware.com/is/image/rhis/mcard-straight-35x20?wid=35&fmt=png&qlt=85,1&iccEmbed=0')
    );
    ptList.add(new PaymentType__c(
      Name = '6',
      Description__c = 'DISCOVER',
      Logo_Type__c = 'DISCOVER',
      Logo_URL__c = 'https://media.restorationhardware.com/is/image/rhis/discover-straight-35-20?wid=35&fmt=png&qlt=85,1&iccEmbed=0')
    );
    ptList.add(new PaymentType__c(
      Name = '7',
      Description__c = 'GC ACCOMMODATION)',
      Logo_Type__c = ltRH,
      Logo_URL__c = rhLogo)
    );
    ptList.add(new PaymentType__c(
      Name = '8',
      Description__c = 'NCR PAY TYPE',
      Logo_Type__c = ltRH,
      Logo_URL__c = rhLogo)
    );
    ptList.add(new PaymentType__c(
      Name = '9',
      Description__c = 'STORE RESTOCK ORDER',
      Logo_Type__c = ltRH,
      Logo_URL__c = rhLogo)
    );
    ptList.add(new PaymentType__c(
      Name = '11',
      Description__c = 'DO NOT USE REPLACED WITH 31',
      Logo_Type__c = ltNone,
      Logo_URL__c = whitebox)
    );
    ptList.add(new PaymentType__c(
      Name = '12',
      Description__c = 'DO NOT USE REPLACED WITH 31',
      Logo_Type__c = ltNone,
      Logo_URL__c = whitebox)
    );
    ptList.add(new PaymentType__c(
      Name = '13',
      Description__c = 'RH REWARDS CERTIFICATE',
      Logo_Type__c = ltRH,
      Logo_URL__c = rhLogo)
    );
    ptList.add(new PaymentType__c(
      Name = '19',
      Description__c = 'STORE PAYMENT RUNG THROUGH POS',
      Logo_Type__c = ltRH,
      Logo_URL__c = rhLogo)
    );
    ptList.add(new PaymentType__c(
      Name = '20',
      Description__c = doNotUse,
      Logo_Type__c = ltNone,
      Logo_URL__c = whitebox)
    );
    ptList.add(new PaymentType__c(
      Name = '21',
      Description__c = doNotUse,
      Logo_Type__c = ltNone,
      Logo_URL__c = whitebox)
    );
    ptList.add(new PaymentType__c(
      Name = '22',
      Description__c = doNotUse,
      Logo_Type__c = ltNone,
      Logo_URL__c = whitebox)
    );
    ptList.add(new PaymentType__c(
      Name = '23',
      Description__c = doNotUse,
      Logo_Type__c = ltNone,
      Logo_URL__c = whitebox)
    );
    ptList.add(new PaymentType__c(
      Name = '24',
      Description__c = doNotUse,
      Logo_Type__c = ltNone,
      Logo_URL__c = whitebox)
    );
    ptList.add(new PaymentType__c(
      Name = '25',
      Description__c = 'PLCC STANDARD REVOLVING',
      Logo_Type__c = ltRH,
      Logo_URL__c = rhLogo)
    );
    ptList.add(new PaymentType__c(
      Name = '26',
      Description__c = doNotUse,
      Logo_Type__c = ltNone,
      Logo_URL__c = whitebox)
    );
    ptList.add(new PaymentType__c(
      Name = '27',
      Description__c = 'CHECKS/WIRES',
      Logo_Type__c = ltRH,
      Logo_URL__c = rhLogo)
    );
    ptList.add(new PaymentType__c(
      Name = '28',
      Description__c = 'PLCC 12MO NO INT-PMT REQ/$1000',
      Logo_Type__c = ltRH,
      Logo_URL__c = rhLogo)
    );
    ptList.add(new PaymentType__c(
      Name = '30',
      Description__c = 'SWATCH PAY TYPE',
      Logo_Type__c = ltRH,
      Logo_URL__c = rhLogo)
    );
    ptList.add(new PaymentType__c(
      Name = '31',
      Description__c = 'GIFT CARD PAY',
      Logo_Type__c = ltRH,
      Logo_URL__c = rhLogo)
    );
    ptList.add(new PaymentType__c(
      Name = '40',
      Description__c = doNotUse,
      Logo_Type__c = ltNone,
      Logo_URL__c = whitebox)
    );
    ptList.add(new PaymentType__c(
      Name = '41',
      Description__c = doNotUse,
      Logo_Type__c = ltNone,
      Logo_URL__c = whitebox)
    );
    ptList.add(new PaymentType__c(
      Name = '43',
      Description__c = 'PLCC 24 MO EQL PAY 5.99% APR',
      Logo_Type__c = ltRH,
      Logo_URL__c = rhLogo)
    );
    ptList.add(new PaymentType__c(
      Name = '44',
      Description__c = 'PLCC 36 MO EQL PAY 5.99% APR',
      Logo_Type__c = ltRH,
      Logo_URL__c = rhLogo)
    );
    ptList.add(new PaymentType__c(
      Name = '45',
      Description__c = 'PLCC 48 MO EQL PAY 5.99% APR',
      Logo_Type__c = ltRH,
      Logo_URL__c = rhLogo)
    );
    ptList.add(new PaymentType__c(
      Name = '46',
      Description__c = 'PLCC 48 MO EQL PAY 5.99% APR',
      Logo_Type__c = ltRH,
      Logo_URL__c = rhLogo)
    );
    ptList.add(new PaymentType__c(
      Name = '47',
      Description__c = 'PLCC 48 MO EQL PAY 5.99% APR',
      Logo_Type__c = ltRH,
      Logo_URL__c = rhLogo)
    );
    ptList.add(new PaymentType__c(
      Name = '48',
      Description__c = 'PLCC 48 MO EQL PAY 5.99% APR',
      Logo_Type__c = ltRH,
      Logo_URL__c = rhLogo)
    );
    ptList.add(new PaymentType__c(
      Name = '55',
      Description__c = 'SUBSTITUE FOR CASH FR CONCIERG',
      Logo_Type__c = ltRH,
      Logo_URL__c = rhLogo)
    );
    ptList.add(new PaymentType__c(
      Name = '56',
      Description__c = 'PAY TYPE SUBSTITUTE(GIFT CARD)',
      Logo_Type__c = ltRH,
      Logo_URL__c = rhLogo)
    );
    ptList.add(new PaymentType__c(
      Name = '57',
      Description__c = 'PAYTYPE SUBSTITUTE(REWRD CARD)',
      Logo_Type__c = ltRH,
      Logo_URL__c = rhLogo)
    );
    insert ptList;
  }
  
  // Set up Application Settings data
  @testSetup static void applicationSettings() {
    List<Application_Settings__c> appSettings = PrepareData.createApplicationSettings();
    insert appSettings;
  }
  
  // Set up data for RH Brand custom setting
  @testSetup static void RHBrand() {
    List<RH_Brand__c> rhbList = new List<RH_Brand__c>();
    String rhBrand = 'RH & RH MODERN';
    String rhEmail = 'RH';
    String rhWidth = '65';
    String rhHeight = '27';
    String rhHome = 'https://www.restorationhardware.com';
    String rhLogo = 'https://media.restorationhardware.com/is/image/rhis/logo-rh-black?wid=114&fmt=png&qlt=85,1&iccEmbed=1';
    String bcBrand = 'RH BABY & CHILD';
    String bcEmail = 'RH Baby & Child';
    String bcWidth = '208';
    String bcHeight = '30';
    String bcHome = 'https://www.rhbabyandchild.com/';
    String bcLogo = 'https://media.rhbabyandchild.com/is/image/rhbcis/logo_nav_rhbc_20150430?wid=256&fmt=gif&qlt=75,0&op_sharpen=0&quantize=adaptive,diffuse,255,&resMode=sharp2&op_usm=0,0,0,0&iccEmbed=1';
    String teenBrand = 'RH TEEN';
    String teenEmail = 'RH Teen';
    String teenWidth = '192';
    String teenHeight = '27';
    String teenHome = 'https://www.rhteen.com';
    String teenLogo = 'https://media.rhteen.com/is/image/rhtnis/hdr_logo_rhteen?wid=356&fmt=png-alpha&iccEmbed=1';
    
    rhbList.add(new RH_Brand__c(
      Name = '10',
      Brand_Logo__c = rhBrand,
      Description__c = 'RH CATALOG',
      Email_Subject_Brand__c = rhEmail,
      Brand_Logo_Width__c = rhWidth,
      Brand_Logo_Height__c = rhHeight,
      Brand_Home_Page_URL__c = rhHome,
      Brand_Logo_URL__c = rhLogo)
    );
    rhbList.add(new RH_Brand__c(
      Name = '12',
      Brand_Logo__c = rhBrand,
      Description__c = 'RH WEB',
      Email_Subject_Brand__c = rhEmail,
      Brand_Logo_Width__c = rhWidth,
      Brand_Logo_Height__c = rhHeight,
      Brand_Home_Page_URL__c = rhHome,
      Brand_Logo_URL__c = rhLogo)
    );
    rhbList.add(new RH_Brand__c(
      Name = '13',
      Brand_Logo__c = rhBrand,
      Description__c = 'RH STORE SALES - US',
      Email_Subject_Brand__c = rhEmail,
      Brand_Logo_Width__c = rhWidth,
      Brand_Logo_Height__c = rhHeight,
      Brand_Home_Page_URL__c = rhHome,
      Brand_Logo_URL__c = rhLogo)
    );
    rhbList.add(new RH_Brand__c(
      Name = '14',
      Brand_Logo__c = rhBrand,
      Description__c = 'RH STORE SALES - CANADA',
      Email_Subject_Brand__c = rhEmail,
      Brand_Logo_Width__c = rhWidth,
      Brand_Logo_Height__c = rhHeight,
      Brand_Home_Page_URL__c = rhHome,
      Brand_Logo_URL__c = rhLogo)
    );
    rhbList.add(new RH_Brand__c(
      Name = '15',
      Brand_Logo__c = rhBrand,
      Description__c = 'RH MODERN CATALOG',
      Email_Subject_Brand__c = rhEmail,
      Brand_Logo_Width__c = rhWidth,
      Brand_Logo_Height__c = rhHeight,
      Brand_Home_Page_URL__c = rhHome,
      Brand_Logo_URL__c = rhLogo)
    );
    rhbList.add(new RH_Brand__c(
      Name = '16',
      Brand_Logo__c = rhBrand,
      Description__c = 'RH MODERN WEB',
      Email_Subject_Brand__c = rhEmail,
      Brand_Logo_Width__c = rhWidth,
      Brand_Logo_Height__c = rhHeight,
      Brand_Home_Page_URL__c = rhHome,
      Brand_Logo_URL__c = rhLogo)
    );
    rhbList.add(new RH_Brand__c(
      Name = '17',
      Brand_Logo__c = rhBrand,
      Description__c = 'RH MODERN STORE',
      Email_Subject_Brand__c = rhEmail,
      Brand_Logo_Width__c = rhWidth,
      Brand_Logo_Height__c = rhHeight,
      Brand_Home_Page_URL__c = rhHome,
      Brand_Logo_URL__c = rhLogo)
    );
    rhbList.add(new RH_Brand__c(
      Name = '20',
      Brand_Logo__c = bcBrand,
      Description__c = 'BABY AND CHILD CATALOG',
      Email_Subject_Brand__c = bcEmail,
      Brand_Logo_Width__c = bcWidth,
      Brand_Logo_Height__c = bcHeight,
      Brand_Home_Page_URL__c = bcHome,
      Brand_Logo_URL__c = bcLogo)
    );
    rhbList.add(new RH_Brand__c(
      Name = '21',
      Brand_Logo__c = bcBrand,
      Description__c = 'BABY AND CHILD WEB',
      Email_Subject_Brand__c = bcEmail,
      Brand_Logo_Width__c = bcWidth,
      Brand_Logo_Height__c = bcHeight,
      Brand_Home_Page_URL__c = bcHome,
      Brand_Logo_URL__c = bcLogo)
    );
    rhbList.add(new RH_Brand__c(
      Name = '22',
      Brand_Logo__c = bcBrand,
      Description__c = 'B&C STORE SALES',
      Email_Subject_Brand__c = bcEmail,
      Brand_Logo_Width__c = bcWidth,
      Brand_Logo_Height__c = bcHeight,
      Brand_Home_Page_URL__c = bcHome,
      Brand_Logo_URL__c = bcLogo)
    );
    rhbList.add(new RH_Brand__c(
      Name = '23',
      Brand_Logo__c = teenBrand,
      Description__c = 'TEEN CATALOG',
      Email_Subject_Brand__c = teenEmail,
      Brand_Logo_Width__c = teenWidth,
      Brand_Logo_Height__c = teenHeight,
      Brand_Home_Page_URL__c = teenHome,
      Brand_Logo_URL__c = teenLogo)
    );
    rhbList.add(new RH_Brand__c(
      Name = '24',
      Brand_Logo__c = teenBrand,
      Description__c = 'TEEN WEB',
      Email_Subject_Brand__c = teenEmail,
      Brand_Logo_Width__c = teenWidth,
      Brand_Logo_Height__c = teenHeight,
      Brand_Home_Page_URL__c = teenHome,
      Brand_Logo_URL__c = teenLogo)
    );
    rhbList.add(new RH_Brand__c(
      Name = '25',
      Brand_Logo__c = teenBrand,
      Description__c = 'TEEN STORE',
      Email_Subject_Brand__c = teenEmail,
      Brand_Logo_Width__c = teenWidth,
      Brand_Logo_Height__c = teenHeight,
      Brand_Home_Page_URL__c = teenHome,
      Brand_Logo_URL__c = teenLogo)
    );
    rhbList.add(new RH_Brand__c(
      Name = '30',
      Brand_Logo__c = rhBrand,
      Description__c = 'TO THE TRADE',
      Email_Subject_Brand__c = rhEmail,
      Brand_Logo_Width__c = rhWidth,
      Brand_Logo_Height__c = rhHeight,
      Brand_Home_Page_URL__c = rhHome,
      Brand_Logo_URL__c = rhLogo)
    );
    rhbList.add(new RH_Brand__c(
      Name = '54',
      Brand_Logo__c = rhBrand,
      Description__c = 'RH STORE RESTOCK',
      Email_Subject_Brand__c = rhEmail,
      Brand_Logo_Width__c = rhWidth,
      Brand_Logo_Height__c = rhHeight,
      Brand_Home_Page_URL__c = rhHome,
      Brand_Logo_URL__c = rhLogo)
    );
    rhbList.add(new RH_Brand__c(
      Name = '90',
      Brand_Logo__c = rhBrand,
      Description__c = 'RH FINE ART',
      Email_Subject_Brand__c = rhEmail,
      Brand_Logo_Width__c = rhWidth,
      Brand_Logo_Height__c = rhHeight,
      Brand_Home_Page_URL__c = rhHome,
      Brand_Logo_URL__c = rhLogo)
    );
    rhbList.add(new RH_Brand__c(
      Name = '91',
      Brand_Logo__c = rhBrand,
      Description__c = 'RHCA - ART GALLERY SALES',
      Email_Subject_Brand__c = rhEmail,
      Brand_Logo_Width__c = rhWidth,
      Brand_Logo_Height__c = rhHeight,
      Brand_Home_Page_URL__c = rhHome,
      Brand_Logo_URL__c = rhLogo)
    );
    rhbList.add(new RH_Brand__c(
      Name = '92',
      Brand_Logo__c = rhBrand,
      Description__c = 'RHCA - CORE STORE SALES',
      Email_Subject_Brand__c = rhEmail,
      Brand_Logo_Width__c = rhWidth,
      Brand_Logo_Height__c = rhHeight,
      Brand_Home_Page_URL__c = rhHome,
      Brand_Logo_URL__c = rhLogo)
    );
    rhbList.add(new RH_Brand__c(
      Name = '999',
      Brand_Logo__c = rhBrand,
      Description__c = 'DUMMY ENTITY',
      Email_Subject_Brand__c = rhEmail,
      Brand_Logo_Width__c = rhWidth,
      Brand_Logo_Height__c = rhHeight,
      Brand_Home_Page_URL__c = rhHome,
      Brand_Logo_URL__c = rhLogo)
    );
    insert rhbList;
  }
  
  // Set up data for SendGrid Credentials custom setting
  @testSetup static void SendGridCredentials() {
    List<SendGrid_Credentials__c> sgcList = new List<SendGrid_Credentials__c>();
    
    sgcList.add(new SendGrid_Credentials__c(
      BCC_Email__c = 'rhsalesforce@restorationhardware.com',
      Password__c = 'dry7pm8B2B!',
      Username__c = 'rhsalesforce')
    );
    insert sgcList;
  }
  
  // Set up data for SendGrid Email custom setting
  @testSetup static void SendGridEmail() {
    List<SendGrid_Email__c> sgeList = new List<SendGrid_Email__c>();
    
    sgeList.add(new SendGrid_Email__c(
      Name = 'Billing Summary',
      Template_Id__c = '0a0371fc-96bb-42a9-ba79-bad42927adaa')
    );
    sgeList.add(new SendGrid_Email__c(
      Name = 'Credit Card Declines - Final Attempt',
      Template_Id__c = 'ed2c0c99-d8b1-4bcf-95f0-267729e797d4')
    );
    sgeList.add(new SendGrid_Email__c(
      Name = 'Credit Card Declines - First Attempt',
      Template_Id__c = 'e7701a0c-60e8-4bc1-9f4f-eaa4627f90ff')
    );
    sgeList.add(new SendGrid_Email__c(
      Name = 'Delay Notification',
      Template_Id__c = '7c8c52dc-6be2-494a-b741-98162ba33af1')
    );
    insert sgeList;
  }
  
  // Set up Account and Contact for sending SendGrid email
  @testSetup static void SendGridAccountContact() {
    List<Account> accList = new List<Account>();
    List<Contact> conList = new List<Contact>();
    Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
    
    accList.add(new Account(
      Name = 'SendGrid Email',
      RecordTypeId = rtMap.get('Internal').getRecordTypeId(),
      Member_Since__c = system.today(),
      Type = 'System')
    );
    insert accList;
    
    conList.add(new Contact(
      LastName = 'SendGrid Email',
      AccountId = accList[0].Id,
      Email = 'cscmetrics@rh.com',
      Alternate_Email__c = 'orderprocessing@rh.com')
    );
    insert conList;
  }
  
  // Set up Product data
  @testSetup static void productData() {
    List<Product2> pList = new List<Product2>();
    
    // We need one product record for each SKU in the Invoice data
    pList.add(new Product2(
      Name = 'CASHACGWG110',
      CW_External_Id__c = 'CASHACGWG110',
      SKU_Type__c = 'Accommodation',
      IsActive = true,
      CW_Item_Description__c = 'RH CASH ACCOMMODATION',
      Ecommerce_Display_Name__c = 'Gift Wrap Refund')
    );
    pList.add(new Product2(
      Name = '17050043AZUR',
      CW_External_Id__c = '17050043AZUR',
      SKU_Type__c = '',
      IsActive = true,
      CW_Item_Description__c = 'PARADIGM 802 HAND TOWEL',
      Ecommerce_Display_Name__c = '802-Gram Turkish Hand Towel')
    );
    pList.add(new Product2(
      Name = '17050042AZUR',
      CW_External_Id__c = '17050042AZUR',
      SKU_Type__c = '',
      IsActive = true,
      CW_Item_Description__c = 'PARADIGM 802 BATH TOWEL',
      Ecommerce_Display_Name__c = '802-Gram Turkish Bath Towel')
    );
    pList.add(new Product2(
      Name = 'GCACRHBOS610',
      CW_External_Id__c = 'GCACRHBOS610',
      SKU_Type__c = 'Accommodation Gift Card',
      IsActive = true,
      CW_Item_Description__c = 'RH GC ACCOMMODATION',
      Ecommerce_Display_Name__c = 'RH Accommodation')
    );
    pList.add(new Product2(
      Name = '101797PTLCRIB',
      CW_External_Id__c = '101797PTLCRIB',
      SKU_Type__c = '',
      IsActive = true,
      CW_Item_Description__c = 'BOM FRAYED RUFFL SET',
      Ecommerce_Display_Name__c = '')
    );
    pList.add(new Product2(
      Name = '101755PTLBUMP',
      CW_External_Id__c = '101755PTLBUMP',
      SKU_Type__c = '',
      IsActive = true,
      CW_Item_Description__c = 'FRAYED RUFFLE BUMPER',
      Ecommerce_Display_Name__c = 'Frayed Ruffle Crib Bumper')
    );
    pList.add(new Product2(
      Name = '101756PTLCRIB',
      CW_External_Id__c = '101756PTLCRIB',
      SKU_Type__c = '',
      IsActive = true,
      CW_Item_Description__c = 'FRAYED RUFFLE BDSKRT',
      Ecommerce_Display_Name__c = 'Frayed Ruffle Skirt')
    );
    pList.add(new Product2(
      Name = '101674PTLCRIB',
      CW_External_Id__c = '101674PTLCRIB',
      SKU_Type__c = '',
      IsActive = true,
      CW_Item_Description__c = 'VINTAGE STRIPE SHEETS',
      Ecommerce_Display_Name__c = 'European Vintage Stripe Crib Fitted Sheet')
    );
    pList.add(new Product2(
      Name = 'CASHACSYSS410',
      CW_External_Id__c = 'CASHACSYSS410',
      SKU_Type__c = 'Accommodation Zero Dollar',
      IsActive = true,
      CW_Item_Description__c = 'RH SYSTEM LIMITATION',
      Ecommerce_Display_Name__c = 'Refund')
    );
    insert pList;
  }
  
  // Set up Order and Account/Opportunity for Billing Summary
  @testSetup static void orderData() {
    Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
     
    Account acc = new Account(
      Name = 'Contract Test Class Account',
      RecordTypeId = rtMap.get('Contract').getRecordTypeId(),
      Member_Since__c = system.today()
    );
    insert acc;
    
    Opportunity opp = new Opportunity(
      Name = 'Contract Test Class Opportunity',
      AccountId = acc.Id,
      StageName = 'Project Inquiry',
      CloseDate = system.today()
    );
    insert opp;
    
    RH_Order__c rhOrder = new RH_Order__c(
      Name = '298356',
      Opportunity__c = opp.Id,
      Sold_to_Address_1__c = '123 MAIN STREET',
      Sold_to_Address_2__c = '',
      Sold_to_City__c = 'SAN FRANCISCO',
      Sold_to_State__c = 'CA',
      Sold_to_Zip__c = '94107',
      Sold_to_First_Name__c = 'BILLY',
      Sold_to_Last_Name__c = 'BOB',
      Sold_to_Email__c = 'dummy@rh.com',
      Sold_to_Day_Phone__c = '555-555-5555',
      Order_Date__c = system.today(),
      Division__c = '12',
      Client_Type__c = 'Contract',
      To_Email_Address__c = '',
      Additional_To_Email_Addresses__c = ''
    );
    insert rhOrder;
  }
  
  @isTest static void orderBillingInteractiveTest() {
    // Test order with invoice data
        List<RH_Order__c> orderList = new List<RH_Order__c>();
        orderList = [select Id from RH_Order__c where Name = '298356'];
        
        // tell the Testing framework to use the mockHttpResponseGenerator 
        // for all Http Callouts in this test  
        Test.setMock(HttpCalloutMock.class, new MockInvoiceHttpResponseGenerator());
        Test.startTest();
        
        ApexPages.StandardController std = new ApexPages.StandardController(orderList[0]);
    Order_BillingIntCtrlExt ctl = new Order_BillingIntCtrlExt(std);
    List<CWInvoice> invoices = Order_BillingIntCtrlExt.getInvoiceData('298356');
    Test.stopTest();
  }
  
  @isTest static void testEmailNewCode() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
       // System.runAs() allows mixed DML operations in test context
        System.runAs(thisUser) {
            
             // Test order with invoice data
        List<RH_Order__c> orderList = new List<RH_Order__c>();
        orderList = [select Id from RH_Order__c where Name = '298356'];
         // tell the Testing framework to use the mockHttpResponseGenerator 
        // for all Http Callouts in this test  
        Test.setMock(HttpCalloutMock.class, new MockInvoiceHttpResponseGenerator());
        Test.startTest();
        
            // startTest/stopTest block to run future method synchronously
                    
            BillingSummaryEmail.processEmailService(orderList[0].Id, 'Contract');
            
            Map<String, String> subMap = new Map<String, String>();
            subMap.put('test', 'test');
            BillingSummaryEmail.saveContent(subMap, orderList[0].Id);
            //BillingSummaryEmail.writeEmailContent(orderList[0].Id, 'Contract');
            BillingSummaryEmail.sendEmail(orderList[0].Id, subMap, false);
            
             // create a new email and envelope object
  Messaging.InboundEmail email = new Messaging.InboundEmail() ;
  Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

  // setup the data for the email
  
  email.subject = orderList[0].Id;
  email.PlainTextBody = JSON.serialize(subMap);
  email.fromname = 'FirstName LastName';
  env.fromAddress = 'pmandy@rh.com';
             // call the email service class and test it with the data in the testMethod
             BillingSummaryEmailHandler emailProcess = new BillingSummaryEmailHandler();
             emailProcess.handleInboundEmail(email, env);

            
            Test.stopTest();
        }
        // The future method will run after Test.stopTest();
    
  }
  
    @isTest static void orderBSTest1() {
        
        // Test order with invoice data
        List<RH_Order__c> orderList = new List<RH_Order__c>();
        orderList = [select Id from RH_Order__c where Name = '298356'];
        
        // tell the Testing framework to use the mockHttpResponseGenerator 
        // for all Http Callouts in this test  
        Test.setMock(HttpCalloutMock.class, new MockInvoiceHttpResponseGenerator());
        Test.startTest();
        
        ApexPages.StandardController std = new ApexPages.StandardController(orderList[0]);
        Order_BillingSummaryCtlExt ctl = new Order_BillingSummaryCtlExt(std);
    
    //system.assertEquals(false, ctl.noInvoiceData);
    
    ctl.rhOrder.Client_Type__c = 'Contract';
    ctl.rhOrder.To_Email_Address__c = 'sthompto@rh.com';
    
    // Cause bad email address code to be executed
    ctl.rhOrder.Additional_To_Email_Addresses__c = 'bobby';
    ctl.sendBillingSummary();
    List<ApexPages.Message> msgs = ApexPages.getMessages();
    Boolean badEmail = false;
    for (ApexPages.Message msg :msgs) {
      if (msg.getDetail().contains('Addtional To Email Addresses must be valid and separated by a single comma')) {
        badEmail = true;
      }
    }
    system.assert(badEmail);
    
    // Cause the Billing Summary email to be sent
    ctl.rhOrder.Additional_To_Email_Addresses__c = '';
    ctl.sendBillingSummary();
    
    ctl.cancelBillingSummary();
    
    Test.stopTest();
    }
}