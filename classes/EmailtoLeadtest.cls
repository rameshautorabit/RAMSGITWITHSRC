@istest
public class EmailtoLeadtest {
    public static Lead testlead;
    
    @testsetup static void sampledata(){
        testlead = new Lead(lastname = 'TestLeademaillead', RecordTypeID = '012F0000001MFMs', LeadSource ='Web Site', Status = 'Open', Company = 'testcompany', email ='test@testemail.com' );
    }
        
        public static testmethod void testemailtoLead(){
            EmailtoLead e2l = new EmailtoLead();
            //case 1 
            Messaging.InboundEmail email = new Messaging.InboundEmail();
            email.fromAddress = 'prashanth.s@autorabit.com';
             email.subject = 'Request to activate AutoRABIT account';
             email.htmlBody = '<html><body>';
             email.htmlBody += '<div>Name := Eswar</div>';
             email.htmlBody += '<div>email := Eswar@testemail.com</div>';
             email.htmlBody += '<div>Infrastructure := Shared</div>';
             email.htmlBody += '<div>Country := US</div>';
             email.htmlBody += '<div>Contact Number := 1234567890</div>';
             email.htmlBody += '<div>Number of Licenses : = 1</div>';
             email.htmlbody += '</body></html>';
             Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            result = e2l.handleInboundEmail(email,env);
            //case 2
            email = new Messaging.InboundEmail();

            result = new Messaging.InboundEmailResult();
            env = new Messaging.InboundEnvelope();
            result = e2l.handleInboundEmail(email,env);
            email.htmlBody = '<html><body>';
            email.htmlBody += '<div>Name :Simon welshEmail ID :simon.w@autorabit.comInfrastructure :sharedCountry :USContact Number :5555555555Number of Licenses :5Date of Registration :29-Jun-2016 13:40</div>';
             email.htmlBody += '</body></html>';
            result = new Messaging.InboundEmailResult();
            env = new Messaging.InboundEnvelope();
            result = e2l.handleInboundEmail(email,env);    
        }
    }