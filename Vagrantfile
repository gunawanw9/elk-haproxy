VAGRANTFILE_API_VERSION = '2'
hosts = [
          { name: 'haproxy', box: 'centos/7', mem: 1024, ip: '172.16.24.33', provision: 'haproxy.sh'},
          { name: 'backend', box: 'centos/7', mem: 1024, ip: '172.16.24.34', provision: 'backend.sh'},
		  { name: 'elk', box: 'centos/7', mem: 4096, ip: '172.16.24.3', provision: 'elkprov.sh'}
        ]
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  hosts.each do |host|
    config.vm.define host[:name] do |node|
      node.vm.hostname = host[:name]
      node.vm.box = host[:box]
      node.vm.network :private_network,
        virtualbox__intnet: "net",
        ip: host[:ip],
        netmask: '255.255.255.0'
	  node.vm.network :public_network, :bridge => 'Broadcom NetXtreme 57xx Gigabit Controller'
      node.vm.provider :virtualbox do |vb|
        vb.name = host[:name]
        vb.memory = host[:mem]
      node.vm.provision 'shell', :path => host[:provision]
      end
    config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
    end
  end
end
