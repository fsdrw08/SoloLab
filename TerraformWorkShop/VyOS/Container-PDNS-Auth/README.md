1. EntryPoint command
According to below commands in [Dockerfile-auth](https://github.com/PowerDNS/pdns/blob/master/Dockerfile-auth):
```dockerfile
COPY dockerdata/startup.py /usr/local/sbin/pdns_server-startup

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/sbin/pdns_server-startup"]
```
and [startup.py](https://github.com/PowerDNS/pdns/blob/master/dockerdata/startup.py)
```python
program = sys.argv[0].split('-')[0]
product = os.path.basename(program)
```
the powerdns container will run command
```bash
pdns_server startup
```
in start up

2. Root config file location  
Regarding to [config-dir](https://doc.powerdns.com/authoritative/settings.html#config-dir), 
```
Location of configuration directory (the directory containing pdns.conf). Usually /etc/powerdns, but this depends on SYSCONFDIR during compile-time.
```

and according to below commands in [Dockerfile-auth](https://github.com/PowerDNS/pdns/blob/master/Dockerfile-auth):
```dockerfile
COPY dockerdata/pdns.conf /etc/powerdns/
RUN mkdir -p /etc/powerdns/pdns.d /var/run/pdns /var/lib/powerdns /etc/powerdns/templates.d
```

[For boolean settings, specifying the name of the setting without a value means yes.](https://doc.powerdns.com/authoritative/settings.html#:~:text=For%20boolean%20settings%2C%20specifying%20the%20name%20of%20the%20setting%20without%20a%20value%20means%20yes.)  
powerdns will load config file [/etc/powerdns/pdns.conf](https://github.com/PowerDNS/pdns/blob/master/dockerdata/pdns.conf) in start up, root config content:
```
local-address=0.0.0.0,::
launch=gsqlite3
gsqlite3-dnssec
gsqlite3-database=/var/lib/powerdns/pdns.sqlite3
include-dir=/etc/powerdns/pdns.d
```

And also, regarding to the api config in [startup.py](https://github.com/PowerDNS/pdns/blob/master/dockerdata/startup.py#L28-L34), below api config  also will be load  
```
webserver
api
api-key={{ apikey }}
webserver-address=0.0.0.0
webserver-allow-from=0.0.0.0/0
webserver-password={{ apikey }}
```
For DNS auth server, the `api-key` content will load from env var `PDNS_AUTH_API_KEY`

3. Additional config files  
According to below commands in [Dockerfile-auth](https://github.com/PowerDNS/pdns/blob/master/Dockerfile-auth):
```dockerfile
RUN mkdir -p /etc/powerdns/pdns.d /var/run/pdns /var/lib/powerdns /etc/powerdns/templates.d
```
and [startup.py](https://github.com/PowerDNS/pdns/blob/master/dockerdata/startup.py):
```python
templateroot = '/etc/powerdns/templates.d'
...
templates = os.getenv('TEMPLATE_FILES')
if templates is not None:
    for templateFile in templates.split(','):
        template = None
        with open(os.path.join(templateroot, templateFile + '.j2')) as f:
            template = jinja2.Template(f.read())
        rendered = template.render(os.environ)
        target = os.path.join(templatedestination, templateFile + '.conf')
        with open(target, 'w') as f:
            f.write(rendered)
        if debug:
            print("Created {} with content:\n{}\n".format(target, rendered))
```
The start up script will load jinja2 template file name base one env var `TEMPLATE_FILES`, then append with `/etc/powerdns/templates.d` for the full template files path, then render each file with all env vars, then output the rendered file to `/etc/powerdns/pdns.d`

ref: https://github.com/cloudnative-nz/infra/blob/main/infrastructure/apps/powerdns/powerdns-auth.yaml