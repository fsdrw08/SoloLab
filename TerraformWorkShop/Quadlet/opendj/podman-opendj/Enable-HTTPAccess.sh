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

# https://github.com/OpenIdentityPlatform/OpenDJ/blob/4.9.1/opendj-doc-generated-ref/src/main/asciidoc/admin-guide/chap-connection-handlers.adoc#restful-client-access-over-http
/opt/opendj/bin/dsconfig \
    --hostname ${hostname} \
    --port 4444 \
    --bindDN '${bindDN}' \
    --bindPassword ${bindPassword} \
    --no-prompt \
    --trustAll \
    set-connection-handler-prop \
        --handler-name "HTTP Connection Handler" \
        --set listen-port:8443 \
        --set use-ssl:true \
        --set enabled:true
EOF
)"
