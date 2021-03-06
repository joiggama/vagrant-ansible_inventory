require 'optparse'

module VagrantPlugins
  module AnsibleInventory
    module Commands
      class Inventory < Vagrant.plugin(2, :command)

        def self.synopsis
          'dynamic ansible inventory'
        end

        def initialize(args, env)
          super

          @sub_args, @env = args, env
        end

        def execute
          opts = OptionParser.new do |op|
            op.banner = 'Usage: vagrant ansible inventory [<options>]'
            op.separator ''
            op.separator 'Available options:'

            op.on('-l', '--list', 'List all hosts as json') do |target|
              @env.ui.info json, prefix: false
              exit
            end

            op.on('-h', '--help', 'Show this message') do
              @env.ui.info opts.help, prefix: false
              exit
            end
          end

          opts.parse!(ARGV[2..-1])

          @env.ui.info ini, prefix: false
        end

        private

        def build
          # Detect meta, explicit and implicit groups
          @meta_groups     = get_meta_groups
          @explicit_groups = get_explicit_groups
          @implicit_groups = get_implicit_groups

          @inventory = {}

          # Assign grouped nodes to inventory
          @implicit_groups.each do |group_name|
            @inventory[group_name] = nodes[group_name].merge id: group_name
          end

          @explicit_groups.each do |group_name, group_nodes|
            @inventory[group_name] = group_nodes.map{|node| nodes[node].merge id: node }
          end

          @meta_groups.each do |group_name, group_names|
            @inventory[group_name] = group_names
          end
        end

        def config
          @config ||= with_target_vms{}.first.config
        end

        def get_explicit_groups
          groups.reject{|group| @meta_groups.include?(group) } || []
        end

        def get_implicit_groups
          nodes.keys - @explicit_groups.values.flatten
        end

        def get_meta_groups
          groups.select{|group| group.include?(':children') }
        end


        def groups
          @groups ||= config.ansible.groups
        end

        def ini
          build

          output = "# Generated by vagrant-ansible_inventory\n\n"

          @inventory.each do |entries|
            group_name, children = *entries
            output <<  "[#{group_name}]\n"

            if children.kind_of? Hash
              output << "#{node_attributes(:id, children)}\n"
            else
              children.each do |child|
                output << "#{(child.kind_of?(Hash) ? node_attributes(:id, child) : child)}\n"
              end
            end

            output << "\n"
          end

          output
        end

        def json
          build

          groups   = {}
          hostvars = {}

          @implicit_groups.each do |group|
            host = @inventory[group][:ansible_ssh_host]
            groups[group] = [host]
            vars = @inventory[group].except(:id)
            hostvars[host] = vars
          end

          @explicit_groups.each do |group|
            name =  group.first
            groups[name] = []
            @inventory[name].each do |node|
              groups[name] << node[:ansible_ssh_host]
              host = node[:ansible_ssh_host]
              vars = node.except(:id)
              hostvars[host] = vars
            end
          end

          @meta_groups.each do |group|
            name = group.first.split(':').first
            groups[name] = group.last.map do |member|
              if @inventory[member].is_a? Hash
                @inventory[member][:ansible_ssh_host]
              else
                @inventory[member].map{|n| n[:ansible_ssh_host] }
              end if @inventory[member]
            end.compact.flatten
          end

          groups.merge({_meta: {hostvars: hostvars}}).to_json
        end

        def nodes
          @nodes ||= with_target_vms{}.each_with_object({}) do |machine, hash|
            raise Vagrant::Errors::SSHNotReady unless machine.ssh_info
            hash[machine.name.to_s] = {
              ansible_ssh_user:             'vagrant',
              ansible_ssh_host:             machine.provider.driver.read_guest_ip(1),
              ansible_ssh_port:             22,
              ansible_ssh_private_key_file: machine.ssh_info[:private_key_path].first
            }
          end
        end

        def node_attributes(id, node)
          "#{node.delete(id)} #{node.map{|k| "#{k[0]}=#{k[1]}"}.join(' ')}"
        end

      end
    end
  end
end
