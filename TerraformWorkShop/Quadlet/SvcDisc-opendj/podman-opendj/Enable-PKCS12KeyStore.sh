#!/bin/bash
# https://doc.openidentityplatform.org/opendj/admin-guide/chap-change-certs
# https://doc.openidentityplatform.org/opendj/reference/admin-tools-ref#dsconfig-1
# https://github.com/szaydel/Rigel-Major/blob/0ee9901f82726eac988443a4601bcac72ff8f7e1/shell-snippets/repository-of-kerberos-one-liners#L18
sleep 5s
podman exec ${CONTAINER_NAME} /bin/bash -c "$(cat <<'EOF'
while [ $(/opt/opendj/bin/status --connectTimeout 0 --bindDN "${bindDN}" --bindPassword "${bindPassword}" -X -s | grep "Server Run Status: Started" | wc -l) -ne 1 ];
    do 
      echo "  Waiting for OpenDJ to start..." ; sleep 1;
    done;

# https://github.com/OpenIdentityPlatform/OpenDJ/blob/4.9.1/opendj-server-legacy/resource/config/config.ldif#L665-L674
/opt/opendj/bin/dsconfig \
    --port 4444 \
    --hostname ${hostname} \
    --bindDN '${bindDN}' \
    --bindPassword ${bindPassword} \
    --trustAll \
    --no-prompt \
    set-key-manager-provider-prop \
        --provider-name JKS \
        --set enabled:false

# https://github.com/OpenIdentityPlatform/OpenDJ/blob/4.9.1/opendj-server-legacy/resource/config/config.ldif#L676-L685
/opt/opendj/bin/dsconfig \
    --port 4444 \
    --hostname ${hostname} \
    --bindDN '${bindDN}' \
    --bindPassword ${bindPassword} \
    --trustAll \
    --no-prompt \
    set-key-manager-provider-prop \
        --provider-name PKCS12 \
        --set enabled:true

# https://github.com/aciborowska/jingo/blob/c1a21f041501d5e6653f2e09046a5524af7274ea/datasets/hcc/opendj-sdk/queries/long/3700.txt#L5
/opt/opendj/bin/dsconfig \
    --port 4444 \
    --hostname ${hostname} \
    --bindDN '${bindDN}' \
    --bindPassword ${bindPassword} \
    --trustAll \
    --no-prompt \
    set-connection-handler-prop \
        --handler-name "LDAPS Connection Handler" \
        --set key-manager-provider:"PKCS12" 
EOF
)"
