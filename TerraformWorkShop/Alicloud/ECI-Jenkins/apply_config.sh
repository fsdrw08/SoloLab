set -e
id
# Prevent Setup Wizard when JCasC is enabled
echo "disable Setup Wizard"
ls -al /var/jenkins_home/
echo $JENKINS_VERSION > /var/jenkins_home/jenkins.install.UpgradeWizard.state
echo $JENKINS_VERSION > /var/jenkins_home/jenkins.install.InstallUtil.lastExecVersion  

# remove all plugins from shared volume
echo "remove all plugins from shared volume"
rm -rf /var/jenkins_home/plugins/*

# Install missing plugins
echo "download plugins"
echo "cp"
cp /var/jenkins_config/plugins.txt /var/jenkins_home;
echo "rm"
rm -rf /usr/share/jenkins/ref/plugins/*.lock
echo "version"
version () { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }     
echo "plugin-cli"
if [ -f "/usr/share/jenkins/jenkins.war" ] && [ -n "$(command -v jenkins-plugin-cli)" 2>/dev/null ] && [ $(version $(jenkins-plugin-cli --version)) -ge $(version "2.1.1") ]; then
  jenkins-plugin-cli --verbose \
    --war "/usr/share/jenkins/jenkins.war" \
    --plugin-file "/var/jenkins_home/plugins.txt" \
    --latest true \
    --latest-specified;
else
  /usr/local/bin/install-plugins.sh `echo $(cat /var/jenkins_home/plugins.txt)`;       
fi

# Copy plugins to shared volume
echo "copy plugins to shared volume"
yes n | cp -i /usr/share/jenkins/ref/plugins/* /var/jenkins_plugins/;

# finished initialization
echo "finished initialization"