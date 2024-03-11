ENV['PUPPET_INSTALL_TYPE'] ||= 'agent'
ENV['BEAKER_PUPPET_COLLECTION'] ||= 'puppet8'
ENV['BEAKER_debug'] ||= 'true'

require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'
install_module_on(hosts)
install_module_dependencies_on(hosts)
install_module_from_forge('puppet-prometheus', '>= 8.2.0')

RSpec.configure do |c|
  c.formatter = :documentation
end
