# -*- mode: ruby -*-
# vi: set ft=ruby :
# ENV['VAGRANT_EXPERIMENTAL'] = 'typed_triggers'

Vagrant.require_version ">= 1.6.2"

Vagrant.configure("2") do |config|
  config.vm.define "vagrant-vyos15x"
  config.vm.box = "vyos15x"
  config.vm.communicator = "ssh"

  # Admin user name and password
  config.ssh.username = "vagrant"
  # config.ssh.password = "vagrant"
  config.vm.guest = :debian

  config.vm.provider "hyperv" do |hv|
    hv.vm_integration_services = {
        guest_service_interface: true,
        heartbeat: true,
        key_value_pair_exchange: true,
        shutdown: true,
        time_synchronization: true,
        vss: true
    }
  end

  # config.vm.network "private_network", bridge: "Internal Switch"
  # 
  # config.vm.provider "hyperv" do |hv, config|
  #   hv.vmname = "VyOS130-G2"
  #   hv.auto_start_action = "StartIfRunning"
  #   hv.auto_stop_action  = "Save"
  #   hv.maxmemory = 2048
  #   hv.memory = 1024
  #   config.trigger.before :'VagrantPlugins::HyperV::Action::StartInstance', type: :action do |trigger|
  #     trigger.info = "Add new network addapter"
  #     trigger.run = {inline: "./Add-VMNetworkAdapter.ps1"}
  #   end
  # end
  # config.vm.provision "shell", path: "./provisionConfig.sh"
  # config.vm.provision "file", source: "./sources.list", destination: "/tmp/sources.list"
  # config.vm.provision "shell", inline: "sudo cp /tmp/sources.list /etc/apt/sources.list"
  # config.vm.provision "file", source: "./install.sh", destination: "/tmp/install.sh"
end