//Apex Class that implements the Batchable interface
global class LearningApex2 implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext ctx){
      return Database.getQueryLocator(
      'Select Id, Phone, Account.Phone from Contact where Update_Phone__c = TRUE'
      );
    }
    
    global void execute( Database.BatchableContext ctx, List<SObject> sobjects ){
      List<Contact> contacts = (List<Contact>)sobjects;
      for ( Contact c : contacts ){
        c.Phone = c.Account.Phone;
      }
      update contacts;
    }
    
    global void finish(Database.BatchableContext ctx){
        //Log an activity, send an email or do something when done
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTargetObjectId(userInfo.getUserId());
        email.setReplyTo('noreply@thisbook.com');
        email.setSenderDisplayName('Apex Code');
        email.setSubject('Too many emails!');
        email.setPlainTextBody('This will not work, nice try!');
        email.setUseSignature(false);
        email.setSaveAsActivity(false);
        messaging.sendEmail(
        new List<Messaging.SingleEmailMessage>{email}
        );
    }

    //Call the below line to queue your batch process
    //Id batchProcessId = Database.ExecuteBatch(contactBatch);


    //Same method as before but calling the Batchable interface instead of @future
    public static void updateContactPhones(List<Account> priorVersions, List<Account> updatedVersions){
        Set<Id> modifiedAccounts_Ids = new Set<Id>();
        for ( Integer i=0;i<updatedVersions.size();i++ ){
        if ( updatedVersions[i].Phone != priorVersions[i].Phone ){
            modifiedAccounts_Ids.add(updatedVersions[i].Id);
        }
        }
        if ( modifiedAccounts_Ids.size() > 0 ){
        List<Contact> contactQuery = [Select Id, Phone, AccountId, Account.Phone from Contact
        where AccountId in :modifiedAccounts_Ids limit :( limits.getLimitQueryRows()-limits.getQueryRows() )];
        List<Contact> contactUpdates = new List<Contact>();
            for ( Integer i=0;i<contactQuery.size();i++ ){
                if (contactQuery[i].Phone != contactQuery[i].Account.Phone && contactUpdates.size() < limits.getLimitDMLRows()){  
                contactUpdates.add(contactQuery[i]);
                } else if (contactQuery[i].Phone != contactQuery[i].Account.Phone){
                    //     if ( contactJob.size() == 0 ){
                    //     Id batchProcessId = Database.ExecuteBatch(new contactBatch());
                    // }   
                }   
            }
        }
    }
}

/**
 * 
    //Apex Class that implements the Batchable interface and stateful
    global class contactBatch implements Database.Batchable<SObject>, Database.Stateful {
    
        global Integer counter; //the counter variable will be set to the total number of records queried by our batch process

        global Database.QueryLocator start(Database.BatchableContext ctx){
            counter = 0;    
            return Database.getQueryLocator(
            'Select Id, Account.Phone from Contact where Update_Phone__c = TRUE'
            );
        }

        global void execute(
        Database.BatchableContext ctx, 
        List<SObject> sobjects
        ){
            for ( sObject s : sobjects ){
            counter++;  //the counter variable will be set to the total number of records queried by our batch process
            }
        }

        global void finish(Database.BatchableContext BC){
            system.debug(counter);
            //now send an email with this number
        }
    }


    global void execute( Database.BatchableContext ctx, List<sObject> sobjects ){
        for ( sObject s : sobjects){
            if ( 
            s instanceof Contact ||
            s instanceof User ||
            s instanceof Lead
            ){
                //access a field value using the get() method
                System.debug( s.get('firstname') );
            }
        }

        //operate on the entire list of sobjects based on its type
        if ( sobjects instanceof List<Contact> ){
                fixContactsMethod((List<Contact>)sobjects);
            } else if ( sobjects instanceof List<Lead> ){
                fixLeadsMethod((List<Lead>)sobjects);
            } else
            if ( sobjects instanceof List<User> ){
                fixUsersMethod((List<User>)sobjects
            );
        }
    }
 */


 //  system.scheduleBatch( dynaBatch, 'My dynamic batch process', 60, 10);


 /**
 global void finish(Database.BatchableContext BC){
    Integer badLeads = [
    Select Count()
    From Lead
    Where State = null and PostalCode != null
    ];

    Integer badContacts = [
    Select Count() 
    from Contact
    where Update_Phone__c = TRUE
    ];

    String jobName;
    String queryString;

    dateTime nextMidnight = dateTime.newInstance(system.today().addDays(1), time.newInstance(0,0,0,0));
    //Figure out how many minutes until midnight
    Integer runLaterMinutes = (  nextMidnight.getTime() - system.now().getTime()).intValue()/60000;
    
    if ( badLeads > 0 ){
      jobName = 'Update Lead States';
  
      //Set our query string for the leads batch process
      queryString = 'Select Id, State, PostalCode from Lead where State = null and PostalCode != null';
  
      //There are records to fix, so run right away
      runLaterMinutes = 1;
    } else {
      jobName = 'Update Contact Phone';
  
      queryString = 'Select Id, Phone, Account.Phone from Contact where Update_Phone__c = TRUE';
  
      //Run now if there's anything to fix, otherwise try again at midnight
      if ( badContacts > 0 ){
        runLaterMinutes = 1;
      }
    }
    //Dynamically schedule our dynamic batch process
    system.scheduleBatch(dynaBatch(queryString),jobName, runLaterMinutes;  );
  }
 */

 /**
  //Scheduling a Schedulable Apex Class
    myScheduler cls = new myScheduler();
    String cronExpression = '0 59 11 * * ?';  //Nightly at 11:59pm
    String jobId = System.schedule('Job Name', cronExpression, cls);
  */