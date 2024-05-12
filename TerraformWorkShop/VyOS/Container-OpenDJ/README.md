create dummy opendj.jks in /mnt/data/offline/others first

#### ldap - Privilege Subsystem - Proxied Authorization
ref: 
 - https://stackoverflow.com/questions/36571781/error-123-open-ldap-ldappasswd/36603195#36603195
 - [Privilege Subsystem](https://docs.oracle.com/cd/E19450-01/820-6172/privilege-subsystem.html)
 - [ACI: Disable Anonymous Access](https://backstage.forgerock.com/docs/opendj/3.5/admin-guide/#access-control-disable-anonymous)

There are typically ways of updating a user's password in ldap:

- Users can update their own password.
- An admin user can update the user's password (your case). In this scenario the admin should assume the identity of the user before updating the password. This is called Proxied Authorization.

#### commands
```shell
/opt/opendj/bin/status \
    --bindDN "cn=Directory Manager" \
    --bindPassword P@ssw0rd \
    --no-prompt
```
[reject-unauthenticated-requests](https://github.com/OpenIdentityPlatform/OpenDJ/wiki/Administration-Connection-Handlers#:~:text=32768%20%5C%0A%20%2D%2Dno%2Dprompt-,reject%2Dunauthenticated%2Drequests,-Rejects%20any%20request)
```shell
/opt/opendj/bin/dsconfig \
    --hostname ${hostname} \
    --port 4444 \
    --bindDN '${bindDN}' \
    --bindPassword ${bindPassword} \
    --trustAll \
    --no-prompt \
    set-global-configuration-prop \
        --set reject-unauthenticated-requests:true
```

[check server-based password policies](https://github.com/OpenIdentityPlatform/OpenDJ/wiki/Administration-Password-Policy#1011-server-based-password-policies)
```shell
/opt/opendj/bin/dsconfig \
    --hostname localhost \
    --port 4444 \
    --bindDN "cn=Directory Manager" \
    --bindPassword P@ssw0rd \
    --trustAll \
    --no-prompt \
    get-password-policy-prop \
        --policy-name "Default Password Policy" \
        --advanced
```

[configuring-password-storage](https://github.com/OpenIdentityPlatform/OpenDJ/wiki/Administration-Password-Policy#105-configuring-password-storage)
```shell
/opt/opendj/bin/dsconfig \
    --hostname ${hostname} \
    --port 4444 \
    --bindDN '${bindDN}' \
    --bindPassword ${bindPassword} \
    --trustAll \
    --no-prompt \
    set-password-policy-prop \
        --policy-name "Default Password Policy" \
        --set default-password-storage-scheme:"Bcrypt"
```

[Allow passwords to enter in pre-encoded form](https://forums.oracle.com/ords/apexds/post/allow-passwords-to-enter-in-pre-encoded-form-9340)
```shell
/opt/opendj/bin/dsconfig \
    --hostname ${hostname} \
    -p 4444 \
    --bindDN '${bindDN}' \
    --bindPassword ${bindPassword} \
    --trustAll \
    --no-prompt \
    set-password-policy-prop \
        --policy-name "Default Password Policy" \
        --set allow-pre-encoded-passwords:true
```
[ldapsearch](https://docs.ldap.com/ldap-sdk/docs/tool-usages/ldapsearch.html)
```shell
/opt/opendj/bin/ldapsearch \
    --hostname localhost \
    --port 1636 \
    --bindDN "cn=Directory Manager" \
    --bindPassword P@ssw0rd \
    --useSSL \
    --trustAll \
    --baseDN ou=People,dc=root,dc=sololab \
    uid=admin \
    isMemberOf
```