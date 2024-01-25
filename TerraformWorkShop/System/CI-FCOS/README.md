to config a jenkins swarm agent connect to jenkins-server:
```shell
# download swarm client
curl -O -k https://jenkins.service.consul/swarm/swarm-client.jar

# get the cert
openssl s_client -showcerts -connect jenkins.service.consul:443 < /dev/null 2> /dev/null | openssl x509 -outform PEM > ~/root_ca.pem

# find the original cacert file
sudo find / -name cacerts
# copy to home dir
cp /etc/pki/ca-trust/extracted/java/cacerts ~/cacerts-consul

# add self sign cert to the backup cacerts
sudo keytool -import -alias consul -keystore ~/cacerts-consul -file ~/root_ca.pem

# run jenkins swarm
java -Djavax.net.ssl.trustStore=/home/vagrant/cacerts-consul \
    -jar /home/vagrant/swarm-client.jar \
    -fsroot /home/vagrant/workspace \
    -url https://jenkins.service.consul/ \
	-name Dev-Fedora \
    -username admin \
    -password P@ssw0rd \
	-sslFingerprints "$(openssl s_client -connect jenkins.service.consul:443 < /dev/null 2> /dev/null | openssl x509 -noout -sha256 -fingerprint | tr -d ':' | cut -d'=' -f2)" \
    -webSocket
```

```desktop
[Unit]
Description=Jenkins swarm client
After=network.target
AssertPathExists=/home/vagrant/cacerts-consul
AssertPathExists=/home/vagrant/swarm-client.jar

[Service]
# EnvironmentFile=/etc/default/jenkins-swarm-client
Type=simple
User=vagrant
# Group=wheel
LimitNOFILE=65536
Environment=LANG=en_US.UTF-8
Environment=LC_ALL=en_US.UTF-8
Environment=LANGUAGE=en_US.UTF-8
# StandardOutput=file:/var/log/jenkins/swarm-client.log
# StandardError=file:/var/log/jenkins/swarm-client.err.log
ExecStart=/usr/bin/java -Djavax.net.ssl.trustStore=/home/vagrant/cacerts-consul \
    -jar /home/vagrant/swarm-client.jar \
    -fsroot /home/vagrant/workspace \
    -url https://jenkins.service.consul/ \
    -name Dev-Fedora \
    -username admin \
    -password P@ssw0rd \
    -webSocket
[Install]
WantedBy=multi-user.target
```

```desktop
[Unit]
Description=Jenkins swarm client
After=network.target

[Service]
EnvironmentFile=/etc/default/jenkins-swarm-client
Type=simple
User=podmgr
Group=wheel
LimitNOFILE=65536
Environment=LANG=en_US.UTF-8
Environment=LC_ALL=en_US.UTF-8
Environment=LANGUAGE=en_US.UTF-8
StandardOutput=file:/var/log/jenkins/swarm-client.log
StandardError=file:/var/log/jenkins/swarm-client.err.log
ExecStart=/usr/bin/java -jar /usr/share/jenkins/swarm-client.jar \
          -master "https://jenkins.marvee9.com:443" \
          -name "workloadvm" \
          -fsroot "/home/podmgr/workspace" \
          -executors "10" \
          -labels "Frontend Backend" \
          -username "admin" \
          -password "P@ssw0rd" \
          -description "$(hostname -a)" \
          -retry 5 \
          -webSocket
          -disableClientUniqueId

[Install]
WantedBy=multi-user.target
```