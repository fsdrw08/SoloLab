#!/bin/bash
# https://www.cockroachlabs.com/docs/stable/cockroach-sql
# https://www.cockroachlabs.com/docs/v23.2/grant#required-privileges
sudo podman exec -it ${container_name} /cockroach/cockroach sql --certs-dir=${certs_dir} --host=${listen_addr} --execute "$(cat << EOF
CREATE DATABASE IF NOT EXISTS tfstate;
CREATE USER IF NOT EXISTS terraform WITH PASSWORD 'terraform';
GRANT ALL ON database tfstate TO terraform;
CREATE USER IF NOT EXISTS roach WITH PASSWORD 'P@ssw0rd';
GRANT ADMIN TO roach WITH ADMIN OPTION;
EOF
)"