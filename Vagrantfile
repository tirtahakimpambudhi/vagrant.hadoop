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
            :name => ".provision/config-master.sh"
          }
        ]
    },
]


Vagrant.configure(2) do |config|
  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = machine[:box]
      node.vm.box_version = machine[:box_version]
      node.vm.hostname = machine[:hostname]
      node.vm.network "private_network", ip: machine[:ip]
      node.vm.synced_folder "shared/", "/home/hadoop/shared"
      node.vm.synced_folder "shared/", "/home/vagrant/shared"
      node.vm.synced_folder "workspace/", "/home/hadoop/workspace"
      # Corrected provider configuration
      # node.vm.provider "vmware_desktop" do |v| # if use vmware
      node.vm.provider "virtualbox" do |v|
        v.name = "vms-thp-#{machine[:hostname]}" # only in virtualbox
        v.memory = machine[:memory]
        v.cpus = machine[:cpu]
        # v.force_vmware_license = "workstation" # only vmware
        v.gui = true  # Uncomment if you want the VM to show the GUI
      end

      machine[:scripts].each do |script|
           node.vm.provision "shell", :path => "#{script[:name]}"
      end
         node.vm.provision "shell", inline: <<-SHELL
            dos2unix /home/hadoop/shared/script/*.sh
            dos2unix /home/hadoop/workspace/*/*.sh
         SHELL
    end
  end
end