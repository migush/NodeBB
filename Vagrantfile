# -*- mode: ruby -*-
# vi: set ft=ruby :

# Stripped-down Vagrantfile for development



# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/trusty64"

  config.vm.provider :virtualbox do |vbox, override|
    vbox.memory = 1024
    vbox.cpus = 2
  end

  config.ssh.forward_agent = true

  config.vm.network "private_network", ip: "192.168.10.200"
  config.vm.provision :shell, path: "setup.sh"
  config.vm.provision :shell, inline: "cd /vagrant/NodeBB; ln -s ../../nodebb-plugin-jotter node_modules/nodebb-plugin-jotter", run: "always"
  config.vm.provision :shell, inline: "cd /vagrant/NodeBB; ln -s ../../nodebb-theme-jotter node_modules/nodebb-theme-jotter", run: "always"

  # RabbitMQ
  config.vm.network "forwarded_port", guest: 15672, host: 15672, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 5672, host: 5672, host_ip: "127.0.0.1"

  # NodeBB
  config.vm.network "forwarded_port", guest: 4567, host: 4567, host_ip: "127.0.0.1"

  # mongodb
  config.vm.network "forwarded_port", guest: 27017, host: 27017, host_ip: "127.0.0.1"

  #excludes = [".git/", "node_modules"]
  #config.vm.synced_folder ".", "/vagrant", type: "rsync" , rsync__exclude: excludes, :rsync_excludes => excludes
  config.vm.synced_folder "..", "/vagrant", type: "nfs"
end