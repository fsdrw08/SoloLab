dockerfile:
https://build.opensuse.org/package/view_file/home:firstyear/389-ds-container/Dockerfile?expand=1

docker image:
https://hub.docker.com/r/389ds/dirsrv

docker cmd cli (entrypoint):
https://github.com/389ds/389-ds-base/blob/main/src/lib389/cli/dscontainer

additional ref:
according to below info, need to manually init/create backend (dsconf localhost backend create)
https://fy.blackhats.net.au/blog/html/2019/07/05/using_389ds_with_docker.html
https://www.reddit.com/r/kubernetes/comments/jqymmu/anyone_deployed_a_389ds_ldap_server_on_k8s/
https://github.com/gabibbo97/k8s-misc/tree/master/389ds