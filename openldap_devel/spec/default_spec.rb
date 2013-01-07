require 'chefspec'

describe 'openldap_devel::default' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'openldap_devel::default' }
  it 'should install openldap-devel' do
    chef_run.should install_package 'openldap-devel'
  end
end
