#!/bin/bash
# https://marginnotes2.wordpress.com/2011/07/25/opendj-turn-off-anonymous-access/
sleep 5s
podman exec ${CONTAINER_NAME} /bin/bash -c "$(cat <<'EOF'
while [ $(/opt/opendj/bin/status --connectTimeout 0 --bindDN "${bindDN}" --bindPassword "${bindPassword}" -X -s | grep "Server Run Status: Started" | wc -l) -ne 1 ];
    do 
      echo "  Waiting for OpenDJ to start..." ; sleep 1;
    done;

# take a fine-grained approach to limit anonymous access
# https://doc.openidentityplatform.org/opendj/admin-guide/chap-privileges-acis#configure-acis
/opt/opendj/bin/dsconfig \
--port=4444 \
--hostname ${hostname} \
--bindDN '${bindDN}' \
--bindPassword ${bindPassword} \
--trustAll \
--no-prompt \
set-access-control-handler-prop \
  --remove=global-aci:'(targetattr!="userPassword||authPassword||changes||
  changeNumber||changeType||changeTime||targetDN||newRDN||
  newSuperior||deleteOldRDN||targetEntryUUID||changeInitiatorsName||
  changeLogCookie||includedAttributes")(version 3.0; acl "Anonymous
   read access"; allow (read,search,compare) userdn="ldap:///anyone";)'

# enable anonymous access
/opt/opendj/bin/dsconfig \
--port 4444 \
--hostname ${hostname} \
--bindDN '${bindDN}' \
--bindPassword ${bindPassword} \
--trustAll \
--no-prompt \
set-global-configuration-prop \
--set reject-unauthenticated-requests:false

# enable use LDAP Client to update end users password manually
# https://forums.oracle.com/ords/apexds/post/allow-passwords-to-enter-in-pre-encoded-form-9340
/opt/opendj/bin/dsconfig \
 --port 4444 \
 --hostname ${hostname} \
 --bindDN '${bindDN}' \
 --bindPassword ${bindPassword} \
 --trustAll \
 --no-prompt \
 set-password-policy-prop \
  --policy-name "Default Password Policy" \
  --set allow-pre-encoded-passwords:true
EOF
)"