lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant/ansible_inventory/version'

Gem::Specification.new do |spec|
  spec.name          = 'vagrant-ansible_inventory'
  spec.version       = VagrantPlugins::AnsibleInventory::VERSION
  spec.authors       = ['Ignacio Galindo']
  spec.email         = ['joiggama@gmail.com']
  spec.summary       = %q{Vagrant plugin for building ansible inventory files.}
  spec.description   = %q{Helps defining and building ansible inventory files programatically via configuration and command modules.}
  spec.homepage      = 'https://github.com/joiggama/vagrant-ansible_inventory'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake',    '~> 10.0'
end
