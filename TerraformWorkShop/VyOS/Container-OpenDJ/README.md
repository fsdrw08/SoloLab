#### ldap - Privilege Subsystem - Proxied Authorization
ref: 
 - https://stackoverflow.com/questions/36571781/error-123-open-ldap-ldappasswd/36603195#36603195
 - [Privilege Subsystem](https://docs.oracle.com/cd/E19450-01/820-6172/privilege-subsystem.html)
 - [ACI: Disable Anonymous Access](https://backstage.forgerock.com/docs/opendj/3.5/admin-guide/#access-control-disable-anonymous)

There are typically to ways of updating a user's password in ldap:

- Users can update their own password.
- An admin user can update the user's password (your case). In this scenario the admin should assume the identity of the user before updating the password. This is called Proxied Authorization.
