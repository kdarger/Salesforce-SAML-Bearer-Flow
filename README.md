# Salesforce DX Project: Next Steps

The apex class SAMLBearerAssertion.cls specifically deals with getting a token with which a user can access data stored in a different salesforce org via a community user. 

##References
[OAuth 2.0 SAML Bearer Assertion Flow for Previously Authorized Apps](https://help.salesforce.com/articleView?id=sf.remoteaccess_oauth_SAML_bearer_flow.htm&type=5) - Salesforce Documentation. 
[Integrating Multiple Orgs using the OAuth 2.0 SAML Bearer Assertion Flow](https://developer.salesforce.com/blogs/isv/2015/04/integrating-multi-orgs-using-oauth.html) - Salesforce blog post outlining the basics of how to accomplish this. 
[Crypto Class](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_classes_restful_crypto.htm) - Salesforce Documentation on the class used for signing the XML. 