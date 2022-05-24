1. run below command to create VM by vagrant, according to the process, it will boot up the alpine linux vm, then download and install k3s
```
vagrant up
```
2. run below command to login to the vm
```
vagrant ssh
```
3. watch the k3s init process
```
kubectl get events -A --watch
```