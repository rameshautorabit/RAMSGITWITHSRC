global class EmailtoLead implements Messaging.InboundEmailHandler {
	  global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		  Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
          IncomingEmail__c incoming = new IncomingEmail__c();
          string Messages;
          try{
              //dumping all incoming email into incomingemail object.
              incoming.From__c = email.fromAddress;
              incoming.Subject__c = email.subject;
              incoming.Body__c = email.htmlBody;
              insert incoming;
              //remove html/xml tags
                 string html = email.htmlbody;
			    System.debug('html body-========='+html);
			    //System.debug('plaintext is as follows==='+email.plainTextBody);
			    //regular expression to match all HTML/XML tags
			    string HTML_TAG_PATTERN = '<(?i).*?>';
			    //compile
			    pattern myPattern = pattern.compile(HTML_TAG_PATTERN);
			    matcher myMatcher = myPattern.matcher(html);
			    String resultbody = myMatcher.replaceAll('');
			    if(resultbody.contains('\n')){
			    resultbody = resultbody.replaceAll('\n','');
			}
		    // end of parsing html/xml tags in body
			    System.debug('Body of email is as follows=========='+resultbody);
			         if(email.subject != ''){
    			        Messages = 'New Lead from Registration Page';
    			        Lead l = new Lead();
    			        l.RecordTypeId = '012F0000001MFMs';
    			        l.LeadSource = 'Web Site';
    			        l.Status = 'Open';
    			        l.Company= 'test'; //debug only //email needs to expose organization
    			        //l.email = 'debug@test.com';//debug only
			        //system.debug('Lead to be inserted' + l);
    			            if(resultbody.contains('Name')){
        			            String leadname = resultbody.substringBetween('Name :', 'Email');
        					    	if(leadname.contains(' ')){
        			                     l.firstname = leadname.substring(0,leadname.indexOf(' '));
        			                     l.lastname = leadname.substring(leadname.indexOf(' ') + 1);
			            }
			                 else{
			                     l.lastname = leadname;
			                     system.debug('error is====' + l);
			                 
			            }
			                 if(resultbody.contains('Email ID')){
			                    String fromemail = resultbody.substringBetween('Email ID :', 'Infrastructure');
						        l.Email = fromemail;
			            }
			                if(resultbody.contains('Infrastructure')){
			                    string Infrastructure = resultbody.substringBetween('Infrastructure :','Country');
			                    l.Infrastructure__c = Infrastructure;
			                }
			                
			                if(resultbody.contains('Country')){
			                    string Countrystring = resultbody.substringBetween('Country :','Contact Number :');
			                    l.Country = Countrystring;
			                }
			                if(resultbody.contains('Contact Number :')){
			                    string phnumber = resultbody.substringBetween('Number :','Number');
			                    l.Phone = phnumber;
			                }
			                if(resultbody.contains('Number of Licenses :')){
			                    string license = resultbody.substringBetween('Number of Licenses :','Date');
			                    l.No_of_Users__c = Decimal.valueOf(license);
			                }
			                
			    }
			    system.debug('Lead to be inserted====' + l);
            insert l;
          }
		}
	Catch(exception e){
	   system.debug('Error is====='+ e);
	    
	}
	return result;
}
}