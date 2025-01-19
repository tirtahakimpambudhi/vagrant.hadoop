# -*- mode: ruby -*-
# vi: set ft=ruby :
#  Only Virtual Box Support
servers = [
    {
        :hostname => "hadoop-master",
        :box => "ubuntu/jammy64",
        :box_version => "20241002.0.0",
        :ip => "192.168.1.11",
        :memory => 2048,
        :size => "8GB",
        :cpu => 1,
        :scripts => [
          {
            :name => ".provision/setup.sh"
          },
          {
            :name => ".provision/install_dependencies.sh"
          },
          {
            :name => ".provision/configuration.sh"
          }
        ]
    },
]

# VMWARE AND VIRTUALBOX Support
# servers = [
#     {
#         :hostname => "mysql",
#         :box => "bento/ubuntu-22.04",
#         :box_version => "202401.31.0",
#         :ip => "192.168.10.1",
#         :memory => 2048,
#         :size => "8GB",
#         :cpu => 1,
#         :scripts => [
#         ]
#     },
#     {
#         :hostname => "moodle-app",
#         :box => "bento/ubuntu-22.04",
#         :box_version => "202401.31.0",
#         :ip => "192.168.10.2",
#         :memory => 2048,
#         :size => "8GB",
#         :cpu => 1,
#         :scripts => [
#         ]
#     }
# ]


Vagrant.configure(2) do |config|
  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = machine[:box]
      node.vm.box_version = machine[:box_version]
      node.vm.hostname = machine[:hostname]
      node.vm.network "private_network", ip: machine[:ip]
      # Corrected provider configuration
      # node.vm.provider "vmware_desktop" do |v| # if use vmware
      node.vm.provider "virtualbox" do |v|
        v.name = "vmthp-#{machine[:hostname]}" # only in virtualbox
        v.memory = machine[:memory]
        v.cpus = machine[:cpu]
        # v.force_vmware_license = "workstation" # only vmware
        v.gui = true  # Uncomment if you want the VM to show the GUI
      end

      machine[:scripts].each do |script|
           node.vm.provision "shell", :path => "#{script[:name]}"
      end
    end
  end
end