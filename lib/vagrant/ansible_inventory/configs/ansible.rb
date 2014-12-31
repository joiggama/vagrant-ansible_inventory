module VagrantPlugins
  module AnsibleInventory
    module Configs
      class Ansible < Vagrant.plugin(2, :config)

        attr_accessor :groups

        def initialize
          @groups = UNSET_VALUE
        end

        def finalize!
          @groups = 0 if @groups == UNSET_VALUE
        end

      end
    end
  end
end
