- To create a helm chart, cd to this folder, then run 
  ```powershell
  $chartName="xxx"
  cd "$(git rev-parse --show-toplevel)/HelmWorkShop/charts/"
  helm create $chartName
  ```

- to install local helm chart
  ```powershell
  $chartName="xxx"
  $chartDir="/path/to/helm/chart/dir"
  $nameSpace="xxx"
  $customValue="/path/to/customValue/values.yaml"
  # if there are some dependencies in the chart, build those dependencies first
  helm dependency build
  # then install the local helm chart
  helm install $chartName $chartDir --namespace $nameSpace --create-namespace -f $customValue
  # to upgrade local helm chart
  helm upgrade $chartName $chartDir --namespace $nameSpace -f $customValue
  ```

# PowerDNS
There are 4 most popular powerdns (auth) docker image, 
- psitrax/powerdns  
  - related dockerfile: https://github.com/psi-4ward/docker-powerdns/blob/master/Dockerfile
  - docker hub: https://hub.docker.com/r/psitrax/powerdns  
  - related helm chart: https://github.com/puckpuck/helm-charts/tree/main/charts/powerdns

- interlegis/powerdns
  - related dockerfile: https://github.com/interlegis/docker-powerdns/blob/master/pdns/Dockerfile
  - docker hub: https://hub.docker.com/r/interlegis/powerdns
  - related helm chart: null

- pschiffe/pdns-mysql
  - related dockerfile: https://github.com/pschiffe/docker-pdns/blob/master/pdns/Dockerfile
  - docker hub: https://hub.docker.com/r/pschiffe/pdns-mysql
  - related helm chart: 
    - https://github.com/elauriault/helm-charts/tree/main/charts/powerdns
    - https://github.com/aescanero/helm-charts
  - related operation:
    - https://github.com/sharingio/pair/blob/master/org/explorations/cert-manager-research/cert-manager-research.org

- powerdns/pdns-auth-<version>
  - related dockerfile: https://github.com/PowerDNS/pdns/blob/master/Dockerfile-auth
  - docker hub: https://hub.docker.com/r/powerdns/pdns-auth-46
  - related helm chart: null

currently we are using pschiffe/pdns-mysql as our powerdns helm chart deployment image, will consider to change to offical one in some days.
# 389ds
There are 3 offical docker image for 389ds
- 389ds/dirsrv - based on opensuse
  - related dockerfile: https://build.opensuse.org/package/view_file/home:firstyear/389-ds-container/Dockerfile?expand=1
  - docker hub: https://hub.docker.com/r/389ds/dirsrv#!
  - related helm chart: https://github.com/johanneskastl/389server-helm-chart/tree/main/charts/389server

- quay.io/389ds/dirsrv:latest - based on latest version of Fedora
   - related dockerfile: https://github.com/389ds/389-ds-base/blob/main/docker/389-ds-fedora/Dockerfile
   - image web site: https://quay.io/repository/389ds/dirsrv?tab=tags&tag=latest
   - related helm chart: null

- quay.io/389ds/dirsrv:c9s - based on latest version of CentOS 9 Stream
   - related dockerfile: null
   - image web site: https://quay.io/repository/389ds/dirsrv?tab=tags&tag=c9s
   - related helm chart: null

According to 389's suggestion, should use statefulset for pods instead of deployment