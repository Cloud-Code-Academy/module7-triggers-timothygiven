trigger OpportunityTrigger on Opportunity (before update, after update, before delete) {

    // Scenario 1: Validate that the amount is greater than 5000 when updated
    if (Trigger.isUpdate) {
        for (Opportunity opp : Trigger.new) {
            if (opp.Amount <= 5000) {
                opp.addError('Opportunity amount must be greater than 5000');
            }
        }
    }

    // Scenario 2: Prevent deletion of closed-won opportunities for banking accounts
    if (Trigger.isDelete) {
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : Trigger.old) {
            if (opp.StageName == 'Closed Won' && opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }

        if (!accountIds.isEmpty()) {
            // Query accounts to check the industry
            Map<Id, Account> accountMap = new Map<Id, Account>(
                [SELECT Id, Industry FROM Account WHERE Id IN :accountIds]
            );

            for (Opportunity opp : Trigger.old) {
                if (opp.StageName == 'Closed Won' && opp.AccountId != null) {
                    Account relatedAccount = accountMap.get(opp.AccountId);
                    if (relatedAccount != null && relatedAccount.Industry == 'Banking') {
                        opp.addError('Cannot delete closed opportunity for a banking account that is won');
                    }
                }
            }
        }
    }

    // Scenario 3: Set the Primary Contact (CEO) on the Opportunity
    if (Trigger.isUpdate) {
        // Collect Account IDs to query related Contacts with 'CEO' title
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : Trigger.new) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }

        // Query the Contacts with 'CEO' title
        Map<Id, Contact> accountToCeoContactMap = new Map<Id, Contact>();
        if (!accountIds.isEmpty()) {
            for (Contact con : [SELECT Id, AccountId, Title FROM Contact WHERE AccountId IN :accountIds AND Title = 'CEO']) {
                accountToCeoContactMap.put(con.AccountId, con);
            }
        }

        // Before Update: Set the Primary Contact to the CEO for each opportunity
        for (Opportunity opp : Trigger.new) {
            // Only update if Primary_Contact__c is not set already
            if (opp.Primary_Contact__c == null && accountToCeoContactMap.containsKey(opp.AccountId)) {
                opp.Primary_Contact__c = accountToCeoContactMap.get(opp.AccountId).Id;
            }
        }
    }
}