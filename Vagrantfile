# -*- mode: ruby -*-
# vim: set ft=ruby :


MACHINES = {
  :sysd => {
        :box_name => "jammy",
        :box_version => "0",
  :provision => "setup.sh"
    }        
}


Vagrant.configure("2") do |config|


  MACHINES.each do |boxname, boxconfig|


      config.vm.define boxname do |box|


        box.vm.box = boxconfig[:box_name]
        box.vm.box_version = boxconfig[:box_version]


        box.vm.host_name = "sysd"
	box.vm.network "private_network", ip: "192.168.56.15"


        box.vm.provider :virtualbox do |vb|
              vb.customize ["modifyvm", :id, "--memory", "2048"]
       # end
      end
        box.vm.provision "shell", inline: <<-SHELL
           apt update
	   apt install spawn-fcgi php php-cgi php-cli apache2 libapache2-mod-fcgid nginx -y
      SHELL
      box.vm.provision "shell", path: boxconfig[:provision]
    end
  end
end
