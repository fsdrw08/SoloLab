# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.6.2"

Vagrant.configure("2") do |config|
    config.vm.define "vagrant-debian-11.5.0"
    config.vm.box = "debian-11.5.0"
    config.vm.communicator = "ssh"
    config.vm.synced_folder ".", "/var/vagrant", type: "rsync", disabled: "true"

    # Admin user name and password
     config.ssh.username = "vagrant"
    # config.ssh.password = "vagrant"
     config.vm.guest = :debian

#    config.vm.provider "hyperv" do |h|
#        h.vm_integration_services = {
#            guest_service_interface: true,
#            heartbeat: true,
#            key_value_pair_exchange: true,
#            shutdown: true,
#            time_synchronization: true,
#            vss: boolean
#        }
#    end
  end
