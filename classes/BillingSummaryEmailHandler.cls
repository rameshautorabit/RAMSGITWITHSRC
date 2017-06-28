global class BillingSummaryEmailHandler implements Messaging.InboundEmailHandler {
      global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
          Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
          
          String subMapString = email.plainTextBody;
          String orderId = email.subject;
          orderId = orderId.Replace('Sandbox: ','');
          
          System.Debug('orderId ==== ' + orderId );
           Map<String, String> subMapDirty = (Map<String, String>) JSON.deserialize(subMapString, Map<String, String>.class);
           Map<String, String> subMap = new Map<String, String>();
        
           for(String tag:subMapDirty.keySet()){
              if(subMapDirty.get(tag) == null){
                 subMap.put(tag, '');        
              }else{
                 subMap.put(tag, subMapDirty.get(tag));
              }
           }
           
           RH_Order__c rhOrder = [SELECT Id from RH_Order__c where Id = :orderId];
           
           BillingSummaryEmail.sendEmailForEmailService(rhOrder.Id, subMap, false);
          
          return result;
      }
  }