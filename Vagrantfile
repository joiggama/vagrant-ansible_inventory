Vagrant.configure(2) do |config|
  define_vm = ->(name, box, memory) {
    config.vm.define name do |instance|
      instance.vm.box      = box
      instance.vm.hostname = name
      instance.vm.network 'private_network', type: 'dhcp'
      instance.vm.provider :virtualbox do |i|
        i.name   = name
        i.memory = memory
      end
    end
  }

  define_vm.call 'master',  'ubuntu/trusty32', 256
  define_vm.call 'slave-1', 'ubuntu/trusty32', 256
  define_vm.call 'slave-2', 'ubuntu/trusty32', 256

  config.ansible.groups = {
    'cluster:children' => ['master', 'slaves'],
    'slaves'           => ['slave-1', 'slave-2'],
  }
end
