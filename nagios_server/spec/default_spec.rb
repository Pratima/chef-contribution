#require 'simplecov'
#SimpleCov.start do
# add_filter 'attributes'
#end
require 'chefspec'
#require 'test/unit'
#require 'mocha'
#require 'chef'

#class SearchTest < Test::Unit::TestCase

#  def test_should_run_search  
#    Chef::Recipe.stub(:search).with(kind_of(String)).and_return()
#  end

#end

describe 'nagios_server::default' do
  let (:chef_run) { ChefSpec::ChefRunner.new do |node|
		
	node.automatic_attrs[:languages]={ :ruby =>{ :bin_dir=>"/xxx"} , :gems_dir => '/fake/'}
	node.automatic_attrs[:platform]= 'centos'
	node['chef_packages']= { 'chef' => {'version'=>'1.0'}}
	node['cpu']={'total'=>'2'}	
	end.converge 'nagios_server::default' }

%w{nagios php nagios-plugins-all nagios-plugins-nrpe pnp4nagios}.each do |pkg|
  it 'Installs packages' do
      chef_run.should install_package pkg
    end
  end

  it 'Creates client.rb' do
    chef_run.should create_file '/etc/chef/client.rb'
  end

  it 'Creates cgi.cfg' do
    chef_run.should create_file '/etc/nagios/cgi.cfg'
  end

  it 'Creates passwd' do
    chef_run.should create_file '/etc/nagios/passwd'
  end

  it 'Creates cgi.cfg' do
    chef_run.should create_file '/etc/nagios/cgi.cfg'
  end

  %w{hosts services localhost commands contacts templates}.each do |object|
    it 'Creates '+object do
      chef_run.should create_file "/etc/nagios/objects/#{object}.cfg"
      chef_run.should start_service 'nagios'
      chef_run.should start_service 'graphios'
    end
  end

  it 'Creates nagios.cfg' do
    chef_run.should create_file '/etc/nagios/nagios.cfg'
  end

  it 'Creates index.html' do
    chef_run.should create_cookbook_file '/var/www/html/index.html'
  end

  it 'Creates graphios.cfg' do
    chef_run.should create_file '/etc/nagios/objects/graphios.cfg'
  end

  it 'Creates graphios.py' do
    chef_run.should create_cookbook_file '/opt/nagios/bin/graphios.py'
  end

  it 'Creates graphios' do
    chef_run.should create_cookbook_file '/etc/init.d/graphios'
  end

  it 'Starts and enables service nagios' do
    chef_run.should start_service 'nagios'
    chef_run.should set_service_to_start_on_boot 'nagios'
  end

  it 'Starts service graphios' do
    chef_run.should start_service 'graphios'
    chef_run.should set_service_to_start_on_boot 'graphios'
  end

end

#runner = ChefSpec::ChefRunner.new do |node|
#  cmd = node["nagios"]["admins"].collect do |user, passwd|
#    "/usr/bin/htpasswd -b /etc/nagios/passwd #{user} #{passwd}"
#  end.join(" && ")
#  describe 'check execute' do
#    it 'should push passwords' do
#      runner.should execute_command cmd
#    end
#  end
  

#    it "Creates #{node[:nagios][:plugins_dir]}/check_convergence" do
#      runner.should create_cookbook_file "#{node["nagios"]["plugins_dir"]}/check_convergence"
#    end
#end

