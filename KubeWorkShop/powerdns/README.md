
### Deploy powerdns
ref: 
    - [pdns/Dockerfile-auth](https://github.com/PowerDNS/pdns/blob/master/Dockerfile-auth)
    - [pdns/dockerdata/startup.py](https://github.com/PowerDNS/pdns/blob/master/dockerdata/startup.py)
    - [powerdns-helm/backend/pdns.j2](https://github.com/hwaastad/powerdns-helm/blob/308eec60b80e50dc5f27f0562e566c6fa9ad3354/backend/pdns.j2)
how does the container work:
startup.py -> pdns_server-startup  

apiconftemplate -> jinja2.Template(apiconftemplate).render(apikey=apikey) -> open(conffile, 'w').write(webserver_conf) -> conffile.content
```conf
api
api-key={{ apikey }}
webserver
webserver-address=0.0.0.0
webserver-allow-from=0.0.0.0/0
webserver-password={{ apikey }}
```
templatedestination (/etc/`<role, "powerdns" for auth>`/pdns.d) + _api.conf -> conffile.path

templateroot (/etc/`<role>`/templates.d) + templateFile (the filename assign from ENV VAR `TEMPLATE_FILES`) + .j2 -> jinja2.Template.render(os.environ) ->  target.content
```conf

```
templatedestination (/etc/`<role>`/pdns.d) + templateFile (the filename assign from ENV VAR `TEMPLATE_FILES`) + .conf -> target.path

```shell
APP_DIR="powerdns powerdns-admin"
for APP in $APP_DIR; do \
mkdir -p $HOME/infra/$APP/data; chmod -R 777 $HOME/infra/$APP/data; \
done

podman kube play /var/vagrant/KubeWorkShop/powerdns/pod-powerdns.yaml \
    --configmap /var/vagrant/KubeWorkShop/powerdns/cm-powerdns.yaml

podman kube down /var/vagrant/KubeWorkShop/powerdns/pod-powerdns.yaml  
```
