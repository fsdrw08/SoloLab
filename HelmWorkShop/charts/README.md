to create a helm chart, cd to this folder, then run 
```
cd "$(git rev-parse --show-toplevel)/HelmWorkShop/charts/"
helm create <chart name>
```

about powerdns, there are 3 most popular powerdns docker image:
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