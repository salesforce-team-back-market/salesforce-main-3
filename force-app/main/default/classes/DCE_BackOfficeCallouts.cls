/********************************************************************************
    * Création : Rémy VULTAGGIO - 03/05/2019
    * Modif :
    * Tests : DCE_TriggersTest
    *
    * Allows to make every RESP API callouts to the Back-Office.
    *
    *   Purpose : Group together in the same class all the REST API calls that can
    * be made to the Back-Office.
********************************************************************************/

public class DCE_BackOfficeCallouts {
    private static final String CLASS_NAME = 'DCE_BackOfficeCallouts'; //should be updated if the class name is changed

    /**
        * Private variable
        **/
    private static Map<String, String> MAP_COUNTRIES_CODES = new Map<String, String>{
        'France' => 'fr_fr',
        'Belgium' => 'fr_be',
        'Spain' => 'es_es',
        'Italy' => 'it_it',
        'Germany' => 'de_de',
        'United States' => 'en_us',
        'United Kingdom' => 'en_gb',
        'Austria' => 'de_at',
        'Netherlands' => 'nl_nl',
        'Finland' => 'fi_fi',
        'Portugal' => 'pt_pt',
        'Ireland' => 'en_ie',
        'Greece' => 'el_gr',
        'Slovakia' => 'sk_sk',
        'Sweden' => 'sv_se'
    };

    private static Map<String, String> MAP_FIELDS_SF_BO = new Map<String, String>{
        'trading_name__c' => 'pseudo',
        'vat_number__c' => 'vat_number',
        'company_id_num__c' => 'siret_number',
        'story__c' => 'business_level',
        'split_payment_stage__c' => 'accepts_payment_in_installments',
        'klarna__c' => 'accepts_payment_with_klarna',
        'bizdev__c' => 'account_manager_email',
        'commission__c' => 'fee',
        'back_office_configuration__c' => 'is_configured',
        'iban__c' => 'iban',
        'bic__c' => 'bic',
        'branch_code_number__c' => 'branch_code',
        'account_number__c' => 'account_number', 
        'monthly_fees__c' => 'monthly_fee',
        'back_care__c' => 'backcare',
        'online_status__c' => 'online',
        'billingstreet' => 'street',
        'billingcity' => 'city',
        'billingpostalcode' => 'postal_code',
        'billingcountrycode' => 'country',
        'billingstatecode' => 'state_or_province',
        'mobilephone' => 'phone',
        'buyback__c' => 'sourcing',
        'buyback_limitation__c' => 'sourcing_threshold',
        'buyback_bo_status__c' => 'buyback_enabled',
        'tech_bo_international_onboarding__c' => 'can_open_more_markets',
        'country__c' => 'country_of_origin',
        'shipping_from__c' => 'expedition_country',
        'sales_limitation__c' => 'sales_threshold',
        'reason_for_last_sales_limitation__c' => 'reason'
    };

    /**
        * Public Callouts Methods
        **/
    @future(callout = true)
    public static void makeCallout(String jsonRequestBody, String marketplace) {
        makeImmediateCallout(jsonRequestBody, marketplace);
    }

    /**
        * Private Methods
        **/
    private static void makeImmediateCallout (String jsonRequestBody, String marketplace) {
        String url, username, password;

        if ( marketplace == 'EU' ){
            EU_Back_Office_Settings__c settings = EU_Back_Office_Settings__c.getInstance();
            url = settings.backoffice_url__c;
            username = settings.username__c;
            password = settings.password__c;

        } else if (marketplace == 'US') {
            US_Back_Office_Settings__c settings = US_Back_Office_Settings__c.getInstance();
            url = settings.backoffice_url__c;
            username = settings.username__c;
            password = settings.password__c;

        } else {
            return;
        }

        String token = EncodingUtil.base64Encode(Blob.valueof(username + ':' + password));

        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Authorization', 'Basic ' + token);

        request.setEndpoint(url);
        request.setMethod('PUT');
        request.setBody(jsonRequestBody);

        Http http = new Http();
        HttpResponse response;
        API_Log__e logEvent;
        try {
            response = http.send(request);
        
            LogService.log(response.getStatusCode() != 200 ? LogService.LOG_TYPE.ERROR : LogService.LOG_TYPE.SUCCESS, LogService.PROCESS.BACK_OFFICE_CALLOUT, request, response, 'Callout response', CLASS_NAME);
        } catch (CalloutException e) {
            LogService.log(LogService.LOG_TYPE.ERROR, LogService.PROCESS.BACK_OFFICE_CALLOUT, request, response, e.getMessage(), CLASS_NAME);
        } catch (Exception e) {
            LogService.log(LogService.LOG_TYPE.ERROR, LogService.PROCESS.BACK_OFFICE_CALLOUT, request, response, e.getMessage(), CLASS_NAME);
        }
    }

    /**
        * This method is meant to sync every creation or modification with the Back-Office.
        **/
    public static void doBackOfficeSync( String sObjectAPIName, String operationType, Map < ID, SObject > oldSObjectsMap, List < SObject > newSObjectsList ) {
        Boolean isUpdate = ( 'Update'.equals( operationType ) );

        Map < String, Schema.SObjectField > sObjectFieldsMap = Schema.getGlobalDescribe().get( sObjectAPIName ).getDescribe().fields.getMap();

        List < Map < String, Object > > merchantsToUpdateEU = new List < Map < String, Object > >();
        List < Map < String, Object > > merchantsToUpdateUS = new List < Map < String, Object > >();

        Set<Id> recordIds = new Set<Id>();

        for ( SObjectWrapper wrapper : retreiveBackOfficeInfo(newSObjectsList) ) {
            SObject newSObjectTmp = wrapper.obj;
            recordIds.add(newSObjectTmp.Id);
            SObject oldSObjectTmp = ( isUpdate
                                        ? oldSObjectsMap.get( newSObjectTmp.Id )
                                        : null );

            if ( doPreChecks( oldSObjectTmp, newSObjectTmp ) ) {
                Map < String, Object > merchantInfo = new Map < String, Object >();

                for ( String fieldAPIName : sObjectFieldsMap.keySet() ) {
                    if ( ( isUpdate
                            && newSObjectTmp.get( fieldAPIName ) != oldSObjectTmp.get( fieldAPIName ) )
                            || ( !isUpdate
                                && newSObjectTmp.get( fieldAPIName ) != null ) ) {
                                    doCompleteMerchantInfo(merchantInfo, sObjectAPIName, wrapper, fieldAPIName);
                    }
                }

                if (!merchantInfo.isEmpty() ){
                    merchantInfo.put('salesforce_id', wrapper.accountId);
                    merchantInfo.put('id', wrapper.backOfficeId);
                    
                    if (wrapper.marketplace == MARKET_PLACE.EU){
                        merchantsToUpdateEU.add(merchantInfo);
                    } else if (wrapper.marketplace == MARKET_PLACE.US) {
                        merchantsToUpdateUS.add(merchantInfo);
                    }
                    
                }

            }
        }

        if(merchantsToUpdateEU.isEmpty() == false || merchantsToUpdateUS.isEmpty() == false){
            // replacing bizdev id by its email
            Map<String, List<Decimal>> backOfficeIdsByBizDevId = new Map<String, List<Decimal>>();
            for(Map < String, Object > merchantInfo : merchantsToUpdateEU){
                if(merchantInfo.containsKey('account_manager_email')){
                    String bizdevId = (String)merchantInfo.get('account_manager_email');
                    if(backOfficeIdsByBizDevId.containsKey(bizdevId) == false){
                        backOfficeIdsByBizDevId.put(bizdevId, new List<Decimal>());
                    }

                    backOfficeIdsByBizDevId.get(bizdevId).add((Decimal)merchantInfo.get('id'));
                }
            }
            for(Map < String, Object > merchantInfo : merchantsToUpdateUS){
                if(merchantInfo.containsKey('account_manager_email')){
                    String bizdevId = (String)merchantInfo.get('account_manager_email');
                    if(backOfficeIdsByBizDevId.containsKey(bizdevId) == false){
                        backOfficeIdsByBizDevId.put(bizdevId, new List<Decimal>());
                    }

                    backOfficeIdsByBizDevId.get(bizdevId).add((Decimal)merchantInfo.get('id'));
                }
            }
            Map<Id, User> userBydId = new Map<Id, User>([SELECT Email FROM User WHERE Id IN :backOfficeIdsByBizDevId.keySet()]);
            for(Map < String, Object > merchantInfo : merchantsToUpdateEU){
                if(merchantInfo.containsKey('account_manager_email')){
                    String currentUserId = (String)merchantInfo.get('account_manager_email');
                    merchantInfo.put('account_manager_email', userBydId.get(currentUserId).Email);
                }
            }
            for(Map < String, Object > merchantInfo : merchantsToUpdateUS){
                if(merchantInfo.containsKey('account_manager_email')){
                    String currentUserId = (String)merchantInfo.get('account_manager_email');
                    merchantInfo.put('account_manager_email', userBydId.get(currentUserId).Email);
                }
            }

            LogService.log(LogService.LOG_TYPE.INFO, LogService.PROCESS.BACK_OFFICE_CALLOUT, recordIds, 'Starting callout', CLASS_NAME);
            
            try{
                if (! merchantsToUpdateEU.isEmpty()) {
                    DCE_BackOfficeCallouts.makeCallout ( JSON.serialize(merchantsToUpdateEU), 'EU');
                }
                if (! merchantsToUpdateUS.isEmpty()) {
                    DCE_BackOfficeCallouts.makeCallout ( JSON.serialize(merchantsToUpdateUS), 'US');
                }
            }
            catch(JSONException e){
                LogService.log(LogService.LOG_TYPE.ERROR, LogService.PROCESS.BACK_OFFICE_CALLOUT, recordIds, e.getMessage(), CLASS_NAME);
            }
        }
    }

    /**
        * This method is meant to determine whether a Record must be processed or not.
        **/
    private static Boolean doPreChecks ( SObject oldSObject, SObject newSObject ) {
        Boolean result = false;

        switch on newSObject {
            when Contact c {
                result = ( c.Merchant_ID__c != NULL  );
            }
            when Account a {
                result = true;
            }
            when Targeted_Country__c tc {
                result = true;
            }
            when else {
                // NOTHING TO DO
            }
        }

        return result;
    }

    /**
        * This method is meant to help complete the REST HTTP query body in JSON format.
        **/
    private static void doCompleteMerchantInfo( Map < String, Object > merchantInfo, String sObjectAPIName, SObjectWrapper wrapper, String fieldAPIName) {
        Object newValue = wrapper.obj.get( fieldAPIName );

        switch on sObjectAPIName {
            when 'Account' {
                switch on fieldAPIName {
                    when 'trading_name__c', 'vat_number__c', 'company_id_num__c', 'story__c', 'country__c'  {
                        newValue = (newValue != null) ? (String) newValue : '';
                        merchantInfo.put(MAP_FIELDS_SF_BO.get(fieldAPIName), newValue);
                    }

                    when 'commission__c' {
                        newValue = (Decimal) newValue;
                        if (newValue != null)
                            merchantInfo.put(MAP_FIELDS_SF_BO.get(fieldAPIName), newValue);
                    }

                    when 'monthly_fees__c' {
                        newValue = (newValue != null) ? (Decimal) newValue : 0;
                        merchantInfo.put(MAP_FIELDS_SF_BO.get(fieldAPIName), newValue);
                    }

                    when 'split_payment_stage__c', 'klarna__c' {
                        String fieldName = MAP_FIELDS_SF_BO.get(fieldAPIName);
                        newValue = ((String) newValue) == 'Live' ? true : false ;
                        merchantInfo.put(fieldName, newValue);

                    }

                    when 'bizdev__c' {
                        Id user_id = (Id) newValue;
                        if (user_id != null){
                            merchantInfo.put(MAP_FIELDS_SF_BO.get(fieldAPIName), user_id);
                        }
                    }

                    when 'billingstreet', 'billingcity', 'billingpostalcode', 'billingcountrycode', 'billingstatecode' {
                        String fieldBoName = MAP_FIELDS_SF_BO.get(fieldAPIName);
                        newValue = (newValue != null) ? (String) newValue : '';

                        if (fieldAPIName == 'billingcountrycode' && newValue == '') // backoffice does not accept null value
                            return;

                        if (!merchantInfo.containsKey('address'))
                            merchantInfo.put('address', new Map < String, Object >());

                        ((Map < String, Object >) merchantInfo.get('address')).put(fieldBoName, newValue);
                    }

                    when 'iban__c', 'bic__c', 'branch_code_number__c', 'account_number__c' {
                        String fieldBoName = MAP_FIELDS_SF_BO.get(fieldAPIName);
                        newValue = (newValue != null) ? (String) newValue : '';

                        if (!merchantInfo.containsKey('wallet'))
                                merchantInfo.put('wallet', new Map < String, Object >());

                        ((Map < String, Object >) merchantInfo.get('wallet')).put(fieldBoName, newValue);
                    }

                    when 'back_office_configuration__c', 'buyback__c', 'tech_bo_international_onboarding__c' {
                        newValue = (Boolean) newValue;
                        merchantInfo.put(MAP_FIELDS_SF_BO.get(fieldAPIName), newValue);
                    }
                    
                    when 'buyback_limitation__c' {
                        newValue = (newValue != null) ? ((Decimal) newValue).intValue() : 0;
                        merchantInfo.put(MAP_FIELDS_SF_BO.get(fieldAPIName), newValue);
                    }
                    
                    when 'sales_limitation__c', 'reason_for_last_sales_limitation__c' {
                        if (!merchantInfo.containsKey('sales_limitation'))
                            merchantInfo.put('sales_limitation', new Map < String, Object >());
                        
                        String fieldBoName = MAP_FIELDS_SF_BO.get(fieldAPIName);
                        ((Map < String, Object >) merchantInfo.get('sales_limitation')).put(fieldBoName, newValue);
                    }
                    
                    
                }
            }
            when 'Contact' {
                switch on fieldAPIName {
                    when 'mobilephone'{
                        String fieldBoName = MAP_FIELDS_SF_BO.get(fieldAPIName);
                        newValue = (newValue != null) ? (String) newValue : '';

                        if (!merchantInfo.containsKey('address'))
                            merchantInfo.put('address', new Map < String, Object >());

                        ((Map < String, Object >) merchantInfo.get('address')).put(fieldBoName, newValue);
                    }
                }
            }
            when 'Targeted_Country__c' {
                if (wrapper.countryCode == null)
                    return;

                String fieldBoName = MAP_FIELDS_SF_BO.get(fieldAPIName) + '_' + wrapper.countryCode;
                switch on fieldAPIName {
                    when 'online_status__c' {
                        newValue = ((String) newValue) == 'Live' ? true : false ;
                        merchantInfo.put(fieldBoName, newValue);
                    }

                    when 'back_care__c', 'buyback_bo_status__c' {
                        newValue = (Boolean) newValue;
                        merchantInfo.put(fieldBoName, newValue);
                    }
                    
                    when 'shipping_from__c' {
                        newValue = (String) newValue;
                        merchantInfo.put(fieldBoName, newValue);
                    }
                }
            }
        }
    }

    private static List<SObjectWrapper> retreiveBackOfficeInfo( List<SObject> newSObjectList ){
        // matching each record to its merchant account
        Map<Id, List<SObject>> sobjectsByAccountId = new Map<Id, List<SObject>>();
        for(SObject obj : newSObjectList){
            switch on obj {
                when Contact contact {
                    if(sobjectsByAccountId.containsKey(contact.AccountId) == false){
                        sobjectsByAccountId.put(contact.AccountId, new List<SObject>());
                    }
                    sobjectsByAccountId.get(contact.AccountId).add(contact);
                }

                when Account account {
                    if(sobjectsByAccountId.containsKey(account.Id) == false){
                        sobjectsByAccountId.put(account.Id, new List<SObject>());
                    }
                    sobjectsByAccountId.get(account.Id).add(account);
                }

                when Targeted_Country__c targetCountry {
                    if(sobjectsByAccountId.containsKey(targetCountry.Merchant__c) == false){
                        sobjectsByAccountId.put(targetCountry.Merchant__c, new List<SObject>());
                    }
                    sobjectsByAccountId.get(targetCountry.Merchant__c).add(targetCountry);
                }
            }
        }

        List<SObjectWrapper> wrappers = new List<SObjectWrapper>();
        for(Account acc : [SELECT Back_Office_PK__c, RecordType.DeveloperName FROM Account WHERE Id IN :sobjectsByAccountId.keySet() AND Back_Office_PK__c != null]){
            for(SObject obj : sobjectsByAccountId.get(acc.Id)){
                SObjectWrapper wrapper = new SObjectWrapper(obj);

                wrapper.accountId = acc.Id;
                wrapper.backofficeId = acc.Back_Office_PK__c;
                if(obj.getSObjectType() == Targeted_Country__c.sObjectType){
                    wrapper.countryCode = MAP_COUNTRIES_CODES.get(((Targeted_Country__c)obj).Country__c);
                }
                wrapper.marketPlace = (acc.RecordType.DeveloperName == 'E_U' ? MARKET_PLACE.EU: MARKET_PLACE.US);

                wrappers.add(wrapper);
            }
        }

        return wrappers;
    }

    private Enum MARKET_PLACE{
        EU,
        US
    }

    private class SObjectWrapper{
        public Decimal backofficeId;
        public Id accountId;
        public MARKET_PLACE marketPlace;
        public String countryCode;
        public SObject obj;

        public SObjectWrapper(Sobject obj){
            this.obj = obj;
        }
    }
}