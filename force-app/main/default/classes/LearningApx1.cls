public with sharing class LearningApx1 {
    public LearningApx1() {

    }
    // Account acct = new Account(name='Hello World');
    // insert acct;

    // List<Account> accounts = new List<Account>{new Account(name = 'Hello World')};
    // insert accounts;

    // List<Account> accounts = [select Id, Name from Account];
    // Set<Id> ids = (new Map<Id,Account>(accounts)).keySet().clone();

    public static void recipesToInitiate(){

        Account acct = new Account(name='Hello World');
        insert acct;

        List<Account> accList = new List<Account>{new Account(name = 'Hello World')};
        insert accList;

        /**
         * Conversion
         */
        //Convert List To Set
        List<String> lStrings1 = new List<String>{'a','b','c','d','e'};
        Set<String> sStrings1 = new Set<String>(lStrings1);

        //Convert Set To List
        Set<String> sStrings2 = new Set<String>{'a','b','c','d','e'};
        List<String> lStrings2 = new List<String>(sStrings2);

        //Convert List To Set Using For each approach
        List<Account> acctList = [select Id, Name from Account];
		Set<Id> ids = new Set<Id>();

        for (Account acc : acctList) {
            ids.add(acc.Id);
        }		

        //Convert with better ways by using Map
        List<Account> accounts = [select Id, Name from Account];
        Set<Id> ids2 = (new Map<Id,Account>(accounts)).keySet().clone();

    }



    public static void updateContactPhones(List<Account> priorAccounts, List<Account> updatedAccounts){
        Set<Id> modifiedAccounts_Ids = new Set<Id>();
        for ( Integer i=0;i<updatedAccounts.size();i++ ){
            if (updatedAccounts[i].Phone != priorAccounts[i].Phone ){
            modifiedAccounts_Ids.add(updatedAccounts[i].Id);
            }
        }
        if ( modifiedAccounts_Ids.size() > 0 ){
            List<Contact> contactQuery = [Select Id, Phone, AccountId, Account.Phone from Contact
            where AccountId in :modifiedAccounts_Ids 
            limit :( limits.getLimitQueryRows()-limits.getQueryRows() )];
        //The above query uses limits methods to calculate the number of records we can query, thus never exceeding the Limit.
            List<Contact> contactUpdates = new List<Contact>();
                for ( Contact c : contactQuery ){
                    //limit to just the records that need it
                    if ( c.Phone != c.Account.Phone &&
                    contactUpdates.size() < limits.getLimitDMLRows()
                    ){  
                        c.Phone = c.Account.Phone;
                    contactUpdates.add(c);
                    }
                }
            if ( contactUpdates.size() > 0 ){
            update contactUpdates;
            }
        }
    }


    @future
    public static void updateContactsLater(Set<Id> contactIds) {
        List<Contact> contactUpdates = new List<Contact>();
            for ( Contact c : [Select Id, Phone, Account.Phone from Contact 
            where   Id in :contactIds]){
                c.Phone = c.Account.Phone;
                contactUpdates.add(c);
            }
    }

/* 
    //Psuedo Code
    public static void updateContactPhones(){
    //...  //Code skipped for brevity
        List<Contact> contactUpdates = new List<Contact>();
        Set<Id> contactIds = new Set<Id>();
            for ( Contact c : contactQuery ){
                //limit to just the records that need it
                if ( c.Phone != c.Account.Phone && contactUpdates.size() < limits.getLimitDMLRows()){  
                    c.Phone = c.Account.Phone;
                    contactUpdates.add(c);
                } else
                if (c.Phone != c.Account.Phone ){
                    //we are above our limit!
                    contactIds.add(c.Id);
                }
            }
        if ( contactUpdates.size() > 0 ){
            update contactUpdates;
            }
        if ( contactIds.size() > 0 ){
            //Call our @future method
            updateContactsLater(contactIds);
            }
    } 
*/

    //This is very nice method  handling with the future method if limit is exceeded
    public static void updateContactPhonesV2(List<Account> priorAccounts, List<Account> updatedAccounts){
        Set<Id> modifiedAccounts_Ids = new Set<Id>();
        for ( Integer i=0;i<updatedAccounts.size();i++ ){
            if (updatedAccounts[i].Phone != priorAccounts[i].Phone ){
            modifiedAccounts_Ids.add(updatedAccounts[i].Id);
            }
        }

        if ( modifiedAccounts_Ids.size() > 0 ){
            List<Contact> contactQuery = [Select Id, Phone, AccountId, Account.Phone from Contact
            where AccountId in :modifiedAccounts_Ids limit :( limits.getLimitQueryRows()-limits.getQueryRows() )];

            List<Contact> contactUpdates = new List<Contact>();
            Set<Id> contactIds = new Set<Id>();

            for ( Integer i=0;i<contactQuery.size();i++ ){
                if ( contactQuery[i].Phone != contactQuery[i].Account.Phone && contactUpdates.size() < limits.getLimitDMLRows()){  
                    contactUpdates.add(contactQuery[i]);
                } else if (
                //Our limit has been exceeded
                contactQuery[i].Phone != contactQuery[i].Account.Phone){
                        contactIds.add(contactQuery[i].Id);
                        if ( contactIds.size() == limits.getLimitDMLRows() || i+1 == contactQuery.size()){
                        //Pass the Ids to our @future method
                        updateContactsLater(contactIds);
                        //Clear the Set so that we can keep going
                        contactIds.clear(); 
                    }

                }
                if ( contactUpdates.size() > 0 ){
                    update contactUpdates;
                }
            }
        }     
    }
}