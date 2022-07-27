# Helm Chart for PowerDNS

Installs a PowerDNS authoritative nameserver inside a Kubernetes cluster

## TL;DR;

```bash
helm repo add puckpuck https://puckpuck.github.io/helm-charts
helm install powerdns puckpuck/powerdns
```

## Installing the chart

It's **strongly recommended** you create a values yaml file (ie: my-values.yaml) to configure this chart.

The chart can be configured on startup to work with a list of domains. This should be done as part of the `powerdns.initDomains` property.

```yaml
powerdns:
  initDomains:
    - k8s.my.sample.domain
```

You will also need to configure some means of accesibility from the outside world for the DNS server to be accesible. 
You can do it by setting your service type to LoadBalancer and using annotations to ensure both TCP/UDP can be accessed. 
Kubernetes has limitations about allowing the same port to be used for both TCP and UDP protocols. 
Some LoadBalancer providers can get around this (ie: MetalLB) using service annotations. 
A potential MetalLB setup would be:

```yaml
service:
  type: LoadBalancer
  annotations:
    metallb.universe.tf/allow-shared-ip: powerdns
  # force ip address
  # ip: 192.168.1.100
```

Once you have a values yaml file configured with all your [options](#parameters) you can install the chart

```bash
helm repo add puckpuck https://puckpuck.github.io/helm-charts
helm install powerdns puckpuck/powerdns --values my-values.yaml
```

## Configuration

The [values.yaml](values.yaml) file contains information about all configuration options for this chart.

## Parameters

| Parameter | Description | Default |
| --- | --- | --- |
| `powerdns.api.key` | PowerDNS API key | `PowerDNSAPI` |
| `powerdns.initDomains` | List of domains to configure on startup | `[]` | 
| `replicaCount` | Number of pdns nodes | `1` |
| `image.repository` | PowerDNS Image repository | `psitrax/powerdns` |
| `image.tag` | PowerDNS Image tag (leave blank to use app version) | `nil` |
| `image.pullPolicy` | PowerDNS Image pull policy | `IfNotPresent` |
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.annotations` | Annotations for PowerDNS service | `{}` | 
| `service.ip` | Specify IP address for PowerDNS service | `nil` |
| `resources` | CPU/Memory resource limits/requests | `{}` |
| `nodeSelector` | Node labels for pod assignment | `{}` |
| `tolerations` | Toleration labels for pod assignment | `[]` |
| `affinity` | Affinity settings for pod assignment | `{}` |
| `mariadb.enabled` | Deploy MariaDB container(s) | `true` |
| `mariadb.rootUser.password` | MariaDB admin password | `nil` |
| `mariadb.db.name` | Database name to create | `powerdns` |
| `mariadb.db.user` | Database user to create | `powerdns` |
| `mariadb.db.password` | Password for the database | `powerdns` |
