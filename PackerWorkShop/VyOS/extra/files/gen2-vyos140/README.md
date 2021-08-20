after run the initialconfig script (or command), update pihole password
run `sudo podman ps`, mark down the container id
run `sudo podman exec -it <container id> /bin/bash`, get into the container cli
run `pihole -a -p`, set up password