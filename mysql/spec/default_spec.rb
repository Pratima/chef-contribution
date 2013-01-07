require 'chefspec'

describe 'mysql::default' do
  let (:chef_run) { ChefSpec::ChefRunner.new do |node|
  node['cpu']= {'total' => 2}
  node.automatic_attrs[:platform] = 'centos'
  end.converge 'mysql::default' }

  %w{ mysql mysql-devel}.each do |pkg|
  it "should install #{pkg}" do
    chef_run.should install_package pkg
  end
 end


  it 'should install mysql-server' do
    chef_run.should install_package 'mysql-server'
  end

  it 'should start mysqld' do
    chef_run.should start_service 'mysqld'
  end

  it 'should change root password' do
    chef_run.should execute_command "mysqladmin -u root password #{chef_run.node['mysql']['root_password']}"
  end
end
