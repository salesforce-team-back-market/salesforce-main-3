global with sharing class AP01Backwatch {

    @InvocableMethod
    public static void SendEmailBackwatch(List<NMO_Process__c> l){
                 
          map<Id,boolean> qualityonly = new map<Id,boolean>();
          //Initialization
          for (NMO_Process__c n:l){
              qualityonly.put(n.Merchant__c,false);
          }
          
          map<Id,List<Contact>> mcontact = new map<Id,List<Contact>>();    
          //Check related contact : Business and Quality
          for (contact c: [select Name,email,AccountId,roles__c  from contact where AccountId in :qualityonly.keyset() and roles__c includes ('Business','Quality') and email!= null]){
          if(!mcontact.containskey(c.AccountId))
              mcontact.put(c.accountId,new List<Contact>());
              
              if(c.roles__c.contains('Quality') && !qualityonly.get(c.AccountId))
                  qualityonly.put(c.AccountId,true);
               
              mcontact.get(c.accountId).add(c);   
          }
          //If at least one quality , put qualityonly = true
          
          List<Messaging.SingleEmailMessage> lmail = new list<Messaging.SingleEmailMessage>();
          List<String> ls = new List<String>();
          List<Id> target = new List<Id> ();    
          Messaging.SingleEmailMessage mail;
          
          //Copy
          
          List<String> copy = new List<String>();                       
          if(system.Label.BWMailCopy.indexOf('@')!=-1){
             for (String s: system.Label.BWMailCopy.split(';')){
                 copy.add(s);
                 }
             
          }
          
          //Sender
          List<OrgWideEmailAddress> sender = [select id, Address from OrgWideEmailAddress where displayname =:System.Label.BWSenderEmail];     
          List<EmailTemplate> template = [Select id from EmailTemplate where developerName = 'NMOMailTemplate'];
          for (NMO_Process__c n:l){
              mail = new Messaging.SingleEmailMessage();
              //put custom label
              if(template.size()>0)
                  mail.setTemplateId(template[0].Id);
              mail.setWhatId(n.Id);
              if(copy.size()>0)
                  mail.setCcAddresses(copy);
              if(sender.size()>0)
                  mail.setOrgWideEmailAddressId(sender[0].Id);
              
              //Check at least one contact
              if(mcontact.containskey(n.Merchant__c)){
              for (Contact c: mcontact.get(n.merchant__c)){
                  if(qualityonly.get(n.merchant__c)){
                      if(c.roles__c.contains('Quality')){
                          ls.add(c.email);
                          target.add(c.Id);
                      }
                  }else {
                      if(c.roles__c.contains('Business')){
                          ls.add(c.email);
                          target.add(c.Id);
                      }
                  }
              }
              mail.setTargetObjectId(target[0]);
             
              
              mail.setToAddresses(ls);
              
              
              
              lmail.add(mail);
              
          }
          }
          Messaging.sendEmail(lmail);
       }
}