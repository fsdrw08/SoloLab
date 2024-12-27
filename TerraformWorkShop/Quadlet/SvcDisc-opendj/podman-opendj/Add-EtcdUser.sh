#!/bin/bash
# podman exec etcd-etcd etcdctl endpoint status --endpoints=${ENDPOINTS}

# https://github.com/SUNET/puppet-sunet/blob/be81ef89c724859eac49fbcf55217ecb72991e0a/templates/knubbis/fleetlock_standalone/etcd-bootstrap/bootstrap.sh.erb#L26
base_cmd="podman exec etcd-etcd etcdctl --endpoints=${ENDPOINTS} "

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

    # # Add 'guest' user, used by the service when talking to the backend
    # if ! $base_cmd user list | grep -q '^guest$'; then
    #     $base_cmd user add guest --no-password
    # fi

    # # Add role with permissions and assign it to guest user
    # if ! $base_cmd role list | grep -q '^guest-role$'; then
    #     $base_cmd role add role_guest
    #     $base_cmd role grant-permission role_guest --prefix=true  read /
    #     $base_cmd user grant-role guest role_guest
    # fi

    # Finally, actually enable the authentication
    $base_cmd auth enable
fi