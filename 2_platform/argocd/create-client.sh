# uses curl to invoke the keycloak REST api
# gets a token for the master realm
mastertoken=$(curl -k -g -d "client_id=admin-cli" -d "username=ds" -d "password=UsrmxwawnVTgEjRqm3H0" -d "grant_type=password" -d "client_secret=" "http://keycloak.platform:80/realms/master/protocol/openid-connect/token" | sed 's/.*access_token":"//g' | sed 's/".*//g');
# echo $mastertoken;

id="9d0a21a2-8a08-4202-b2cb-c590e23c90c2";
url="http://keycloak.platform:80/admin/realms/master";
clienturl="$url/clients/$id";

# creates a new client scope named "groups" with a Token Mapper which will add the groups claim to the token when the client requests the groups scope.

curl -X POST -k -g "http://keycloak.platform:80/admin/realms/master/client-scopes" \
-H "Authorization: Bearer $mastertoken" \
-H "Content-Type: application/json" \
--data-raw '
{
    "name": "groups",
    "protocol": "openid-connect",
    "attributes": {
        "include.in.token.scope": "true",
        "display.on.consent.screen": "true",
        "consent.screen.text": "Access to group membership",
        "gui.order": "0",
        "gui.clientId": "argocd",
        "gui.enabled": "true",
        "display.on.token": "true",
        "token.claim.name": "groups",
        "multivalued": "true",
        "claim.name": "groups",
        "jsonType.label": "String"
    },
    "protocolMappers": [
        {
            "name": "groups",
            "protocol": "openid-connect",
            "protocolMapper": "oidc-group-membership-mapper",
            "consentRequired": false,
            "config": {
                "full.path" : "false",
                "id.token.claim" : "true",
                "access.token.claim" : "true",
                "claim.name" : "groups",
                "userinfo.token.claim" : "true"
            }
        }
    ]
}
'

# creates a new client named "argocd"
# using a clientreprentation according to the documetation: https://www.keycloak.org/docs-api/23.0.1/rest-api/#ClientRepresentation
# curl -X DELETE -k -g  "$url/clients/$id" -H "Authorization: Bearer $mastertoken" 


curl -X POST -k -g "http://keycloak.platform:80/admin/realms/master/clients" \
-H "Authorization: Bearer $mastertoken" \
-H "Content-Type: application/json" \
--data-raw '
{
    "id": "'$id'",
    "protocol": "openid-connect",
    "clientId": "argocd",
    "name": "argocd",
    "secret":"hbeT0fKekzgT0fGPMYV6On9cRcSHiU8b",
    "description": "",
    "publicClient": false,
    "authorizationServicesEnabled": true,
    "serviceAccountsEnabled": true,
    "implicitFlowEnabled": false,
    "directAccessGrantsEnabled": false,
    "standardFlowEnabled": true,
    "frontchannelLogout": true,
    "attributes": {
        "saml_idp_initiated_sso_url_name": "",
        "oauth2.device.authorization.grant.enabled": false,
        "oidc.ciba.grant.enabled": false,
        "post.logout.redirect.uris": "+"
    },
    "alwaysDisplayInConsole": false,
    "rootUrl": "",
    "baseUrl": "",
    "redirectUris": [
        "http://localhost:8085/auth/callback",
        "https://argocd.platform.local/*"
    ],
    "defaultClientScopes": ["openid", "profile", "email", "groups"]
}
';

# creates a new group called argocd-admin and adds the user ds to it

# curl -X POST -k -g "http://keycloak.platform:80/admin/realms/master/groups" \
# -H "Authorization: Bearer $mastertoken" \
# -H "Content-Type: application/json" \
# --data-raw '
# {
#     "name": "argocd-admin",
#     "path": "/argocd-admin",
#     "attributes": {},
#     "realmRoles": [],
#     "clientRoles": [],
#     "subGroups": [],
# }