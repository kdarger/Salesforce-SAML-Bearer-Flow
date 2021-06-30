/**
 * Copyright (c) 2014, salesforce.com, inc. All rights reserved.
 * Redistribution and use of this software in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 * 
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission of salesforce.com, inc.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * https://github.com/salesforceidentity/apex-saml-bearer-flow
 * 
 * MODIFICATIONS: 
 * 
 */
public class SAMLBearerAssertion {

    private String subject;
    //Consumer key from the connected app
    private String issuer = '3MVG9nthuDc9owbdvLYaK1aek0FHYVlMalynnzKY23ZiOcfde5GL2QQxEGpZiWLpZzWRs3phSUKNXwSsJaVts'; 

    //Community URL (for non-community users, use https://login.salesforce.com or https://test.salesforce.com)
    private String audience = 'https://purple-developer-edition.na72.force.com/purple'; 
    
    //URL of the community followed by /services/oauth2/token - needs to be added to remote sites
    private String action = 'https://purple-developer-edition.na72.force.com/purple/services/oauth2/token'; 

    private string notBefore;
    private String notOnOrAfter;
    private String assertionId; 
    
	//DON'T TOUCH THESE STRINGS
    private String prefix = '<?xml version="1.0" encoding="UTF-8"?>'; 
    private String preCannonicalizedResponse = '<saml:Assertion xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="ASSERTION_ID" IssueInstant="NOT_BEFORE" Version="2.0"><saml:Issuer Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">ISSUER</saml:Issuer><saml:Subject><saml:NameID Format="urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">SUBJECT</saml:NameID><saml:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"><saml:SubjectConfirmationData NotOnOrAfter="NOT_ON_OR_AFTER" Recipient="RECIPIENT"></saml:SubjectConfirmationData></saml:SubjectConfirmation></saml:Subject><saml:Conditions NotBefore="NOT_BEFORE" NotOnOrAfter="NOT_ON_OR_AFTER" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"><saml:AudienceRestriction xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"><saml:Audience>AUDIENCE</saml:Audience></saml:AudienceRestriction></saml:Conditions><saml:AuthnStatement AuthnInstant="NOT_BEFORE" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"><saml:AuthnContext><saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:unspecified</saml:AuthnContextClassRef></saml:AuthnContext></saml:AuthnStatement></saml:Assertion>';
    private String preCannonicalizedSignedInfo = '<ds:Reference URI="#ASSERTION_ID"><ds:Transforms><ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/><ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"><ec:InclusiveNamespaces xmlns:ec="http://www.w3.org/2001/10/xml-exc-c14n#" PrefixList="ds saml"/></ds:Transform></ds:Transforms><ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></ds:DigestMethod><ds:DigestValue>DIGEST</ds:DigestValue></ds:Reference>';

    public SAMLBearerAssertion() {
        //The username of the user __in the org they are trying to access__
        //(i.e. UserInfo.getUsername() may not be correct)
        subject = 'abc35534@def.com'; 
        
        datetime nowDt = datetime.now();
        Long nowLong = nowDt.getTime();
        datetime notBeforeDt = datetime.newInstance(nowLong - 120000);
        
        notBefore = notBeforeDt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss') + 'Z';
        datetime notOnOrAfterDt = nowDt.addMinutes(5);
        notOnOrAfter = notOnOrAfterDt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss') + 'Z';
        
        Double random = Math.random();
        assertionId = EncodingUtil.convertToHex(Crypto.generateDigest('SHA1',  Blob.valueOf('assertion' + random)));
    }

    private String getResult(){   
        preCannonicalizedResponse = preCannonicalizedResponse.replaceAll('ASSERTION_ID',assertionId);
        preCannonicalizedResponse = preCannonicalizedResponse.replaceAll('ISSUER',issuer);
        preCannonicalizedResponse = preCannonicalizedResponse.replaceAll('AUDIENCE',audience);
        preCannonicalizedResponse = preCannonicalizedResponse.replaceAll('RECIPIENT',action);
        preCannonicalizedResponse = preCannonicalizedResponse.replaceAll('SUBJECT',subject);
        preCannonicalizedResponse = preCannonicalizedResponse.replaceAll('NOT_BEFORE',notBefore);
        preCannonicalizedResponse = preCannonicalizedResponse.replaceAll('NOT_ON_OR_AFTER',notOnOrAfter);
        
        //Prepare the Digest
        Blob digest = Crypto.generateDigest('SHA1',  Blob.valueOf(preCannonicalizedResponse));
        String digestString = EncodingUtil.base64Encode(digest);

        //Prepare the SignedInfo
        preCannonicalizedSignedInfo = preCannonicalizedSignedInfo.replaceAll('ASSERTION_ID',assertionId);
        preCannonicalizedSignedInfo = preCannonicalizedSignedInfo.replaceAll('DIGEST',digestString);
        
        //sign
        Dom.Document doc = new Dom.Document();
        doc.load(preCannonicalizedResponse);
        Crypto.signXML('RSA-SHA1', doc.getRootElement(), null,  'PurpleSenseSandbox'); 
        return doc.toXmlString();  
    }
    
    //Base64url encoding is different from base64 encoding" + url encoding.
    //See https://help.salesforce.com/articleView?id=000334987&type=1&mode=1
    private String base64URLencode(Blob input){ 
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
    }
   
    public String postSAML(){
        String saml = getResult();
        //System.debug('\n===============SAML==============\n' + saml);
        
        http h = new http();
        httpRequest req = new httpRequest();
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setMethod('POST');
        String param = 'grant_type=' + encodingUtil.urlEncode('urn:ietf:params:oauth:grant-type:saml2-bearer','UTF-8')
            +'&assertion=' + base64URLencode(blob.valueOf(saml)); 
        req.setBody(param);
        req.setEndpoint(action);
        httpResponse res = h.send(req);

        //System.debug('\n\nRESPONSE: ' + res.getBody());
        //System.debug('\n\nRESPONSE: ' + res.getStatusCode() + '  ' + res.getStatus()); 
        return res.getBody(); 
    }
   
    @AuraEnabled
    public static string getToken(){
        try {
            SAMLBearerAssertion sba = new SAMLBearerAssertion(); 
            return sba.postSAML(); 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}