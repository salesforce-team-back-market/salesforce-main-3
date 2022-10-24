/********************************************************************************
 * Création : Rémy VULTAGGIO - 07/05/2019
 * Modif :
 *
 * Class allowing to simulate API REST callouts.
 *
 * Purpose : Help to unit tests.
 ********************************************************************************/
@IsTest
global without sharing class DCE_CalloutsMock implements HttpCalloutMock {

    public enum DCE_CalloutType {
        BACKOFFICE_MERCHANT_UPDATE,
        BACKOFFICE_TARGETEDCOUNTRY_UPDATE,
        BACKOFFICE_CONTACT_UPDATE,
        BACKOFFICE_MERCHANT_INSERT,
        BACKOFFICE_ERROR,
        BACKOFFICE_EXCEPTION
    }

    public DCE_CalloutType calloutType;
    public Boolean needTest = true;

    /**
     * Method that simulate a callout response
     **/
    global HTTPResponse respond ( HTTPRequest request ) {
        System.debug(LoggingLevel.DEBUG, 'DCE_LOG :: DCE_CalloutsMock :: respond :: calloutType = ' + calloutType);
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);

        if (needTest)
            switch on calloutType {
                when BACKOFFICE_MERCHANT_UPDATE {
                    EU_Back_Office_Settings__c settings = EU_Back_Office_Settings__c.getInstance();
                    String token = EncodingUtil.base64Encode(Blob.valueof(settings.username__c + ':' + settings.password__c));

                    System.assertEquals(request.getMethod(), 'PUT');
                    System.assertEquals(request.getHeader('Content-Type'), 'application/json');
                    System.assertEquals(request.getHeader('Accept'), 'application/json');
                    System.assertEquals(request.getHeader('Authorization'), 'Basic ' + token);
                    System.assertEquals(request.getEndpoint(), settings.backoffice_url__c);

                    List <Object> merchantsToUpdate = (List <Object>) JSON.deserializeUntyped(request.getBody());
					Map<String, Object> merchantInfo = (Map<String, Object>) merchantsToUpdate.get(0);
                    
                    System.assertEquals(merchantInfo.get('pseudo'), 'recommerce');
                    System.assertEquals(merchantInfo.get('siret_number'), 'company');
                    System.assertEquals(merchantInfo.get('business_level'), '2');
                    System.assertEquals(merchantInfo.get('fee'), 8);
                    System.assertEquals(merchantInfo.get('monthly_fee'), 11);
                    System.assertEquals(merchantInfo.get('accepts_payment_with_klarna'), false);
                    System.assertEquals(merchantInfo.get('sourcing_threshold'), 10);
                    System.assertEquals(((Map<String, Object>) merchantInfo.get('sales_limitation')).get('sales_threshold'), 10);
                    System.assertEquals(((Map<String, Object>) merchantInfo.get('wallet')).get('iban'), 'iban-xxxx');
                    System.assertEquals(((Map<String, Object>) merchantInfo.get('wallet')).get('bic'), 'bic-xxxx');
                    System.assertEquals(((Map<String, Object>) merchantInfo.get('address')).get('street'), 'rue street');
                }

                when BACKOFFICE_MERCHANT_INSERT {
                    US_Back_Office_Settings__c settings = US_Back_Office_Settings__c.getInstance();
                    String token = EncodingUtil.base64Encode(Blob.valueof(settings.username__c + ':' + settings.password__c));

                    System.assertEquals(request.getMethod(), 'PUT');
                    System.assertEquals(request.getHeader('Content-Type'), 'application/json');
                    System.assertEquals(request.getHeader('Accept'), 'application/json');
                    System.assertEquals(request.getHeader('Authorization'), 'Basic ' + token);
                    System.assertEquals(request.getEndpoint(), settings.backoffice_url__c);

                    List <Object> merchantsToUpdate = (List <Object>) JSON.deserializeUntyped(request.getBody());
					Map<String, Object> merchantInfo = (Map<String, Object>) merchantsToUpdate.get(0);
                    
                    System.assertEquals(merchantInfo.get('pseudo'), null);
                    System.assertEquals(merchantInfo.get('siret_number'), null);
                    System.assertEquals(merchantInfo.get('business_level'), null);
                    System.assertEquals(merchantInfo.get('accepts_payment_with_klarna'), null);
                    System.assertEquals(true, ((String)merchantInfo.get('account_manager_email')).contains('@'));
                    System.assertEquals(((Map<String, Object>) merchantInfo.get('address')).get('country'), 'US');
                }

                when BACKOFFICE_TARGETEDCOUNTRY_UPDATE {
                    EU_Back_Office_Settings__c settings = EU_Back_Office_Settings__c.getInstance();
                    String token = EncodingUtil.base64Encode(Blob.valueof(settings.username__c + ':' + settings.password__c));

                    System.assertEquals(request.getMethod(), 'PUT');
                    System.assertEquals(request.getHeader('Content-Type'), 'application/json');
                    System.assertEquals(request.getHeader('Accept'), 'application/json');
                    System.assertEquals(request.getHeader('Authorization'), 'Basic ' + token);
                    System.assertEquals(request.getEndpoint(), settings.backoffice_url__c);

                    List <Object> merchantsToUpdate = (List <Object>) JSON.deserializeUntyped(request.getBody());
					Map<String, Object> merchantInfo = (Map<String, Object>) merchantsToUpdate.get(0);

                    System.assertEquals(merchantInfo.get('backcare_fr_fr'), false);
                    System.assertEquals(merchantInfo.get('online_fr_fr'), true);
                    System.assertEquals(merchantInfo.get('expedition_country_fr_fr'), 'France');
                }

                when BACKOFFICE_CONTACT_UPDATE {
                    EU_Back_Office_Settings__c settings = EU_Back_Office_Settings__c.getInstance();
                    String token = EncodingUtil.base64Encode(Blob.valueof(settings.username__c + ':' + settings.password__c));

                    System.assertEquals(request.getMethod(), 'PUT');
                    System.assertEquals(request.getHeader('Content-Type'), 'application/json');
                    System.assertEquals(request.getHeader('Accept'), 'application/json');
                    System.assertEquals(request.getHeader('Authorization'), 'Basic ' + token);
                    System.assertEquals(request.getEndpoint(), settings.backoffice_url__c);

                    List <Object> merchantsToUpdate = (List <Object>) JSON.deserializeUntyped(request.getBody());
					Map<String, Object> merchantInfo = (Map<String, Object>) merchantsToUpdate.get(0);

                    System.assertEquals('Test', ((Map<String, Object>)merchantInfo.get('address')).get('phone'), 'The contact mobile phone sent doesn\'t match the one set on the contact updated');
                }

                when BACKOFFICE_ERROR {
                    US_Back_Office_Settings__c settings = US_Back_Office_Settings__c.getInstance();
                    String token = EncodingUtil.base64Encode(Blob.valueof(settings.username__c + ':' + settings.password__c));

                    System.assertEquals(request.getMethod(), 'PUT');
                    System.assertEquals(request.getHeader('Content-Type'), 'application/json');
                    System.assertEquals(request.getHeader('Accept'), 'application/json');
                    System.assertEquals(request.getHeader('Authorization'), 'Basic ' + token);
                    System.assertEquals(request.getEndpoint(), settings.backoffice_url__c);

                    response.setStatusCode(500);
                }

                when BACKOFFICE_EXCEPTION {
                    US_Back_Office_Settings__c settings = US_Back_Office_Settings__c.getInstance();
                    String token = EncodingUtil.base64Encode(Blob.valueof(settings.username__c + ':' + settings.password__c));

                    System.assertEquals(request.getMethod(), 'PUT');
                    System.assertEquals(request.getHeader('Content-Type'), 'application/json');
                    System.assertEquals(request.getHeader('Accept'), 'application/json');
                    System.assertEquals(request.getHeader('Authorization'), 'Basic ' + token);
                    System.assertEquals(request.getEndpoint(), settings.backoffice_url__c);

                    throw new CalloutException();
                }
            }

        return response;
    }
}