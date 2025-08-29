#!/bin/bash
# podman exec etcd-etcd etcdctl endpoint status --endpoints=${ENDPOINTS}

# https://github.com/SUNET/puppet-sunet/blob/be81ef89c724859eac49fbcf55217ecb72991e0a/templates/knubbis/fleetlock_standalone/etcd-bootstrap/bootstrap.sh.erb#L26
base_cmd="podman exec ${CONTAINER_NAME} etcdctl --endpoints=${ENDPOINTS} "

# wait for etcd container to be alive
while true; do
    if $base_cmd endpoint status; then
        break
    fi
    sleep 1
done

# If auth is not enabled this is our hint to set things up
if $base_cmd auth status | grep -q '^Authentication Status: false$'; then

    # Add 'root' user, required for enabling auth
    if ! $base_cmd user list | grep -q '^root$'; then
        $base_cmd user add root:${ROOT_PASSWORD}
        $base_cmd user grant-role root root
    fi

    # Add 'monitor' user, used by the service when talking to the backend
    if ! $base_cmd user list | grep -q '^monitor$'; then
        $base_cmd user add monitor:monitor
    fi

    # Add role with permissions and assign it to monitor user
    # https://github.com/SNL-GMS/GMS-PI13-OPEN/blob/2575fd3e7f25fe1c9a24074c23189b87d3e4ff52/docker/etcd/etcd-setup.sh#L28
    if ! $base_cmd role list | grep -q '^role_monitor$'; then
        $base_cmd role add role_monitor
        $base_cmd role grant-permission --prefix=true role_monitor read ''
        $base_cmd user grant-role monitor role_monitor
    fi

    # Finally, actually enable the authentication
    $base_cmd auth enable
fi