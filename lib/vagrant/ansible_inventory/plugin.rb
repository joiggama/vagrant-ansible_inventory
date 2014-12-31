module VagrantPlugins
  module AnsibleInventory
    class Plugin < Vagrant.plugin(2)

      name 'ansible inventory'

      config  'ansible' do
        require_relative 'configs/ansible'
        Configs::Ansible
      end

      command 'ansible' do
        require_relative 'commands/root'
        Commands::Root
      end

    end
  end
end
