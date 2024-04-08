https://github.com/akme/cockroach-init-user/blob/70e00e023e3ee12e03b69d6a842e6ebf63869d50/start.sh#L10

```shell
sudo podman exec $(sudo podman ps --filter name=cockpit -a -q) /bin/sh -c whoami


```