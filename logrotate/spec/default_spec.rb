require 'chefspec'

describe 'logrotate::default' do
   let (:chef_run) { ChefSpec::ChefRunner.new do |node|
		
	node.automatic_attrs[:languages]={ :ruby =>{ :bin_dir=>"/xxx"} , :gems_dir => '/fake/'}
	node['chef_packages']= { 'chef' => {'version'=>'1.0'}}
	node['cpu']={'total'=>'2'}	
	end.converge 'logrotate::default' }

 it 'should install logrotate' do
    chef_run.should install_package 'logrotate'
  end

  it 'should create logrotate for chef_client' do
    chef_run.should create_cookbook_file '/etc/logrotate.d/chef-client'
    chef_run.cookbook_file('/etc/logrotate.d/chef-client').should be_owned_by('root', 'root')
    chef_run.cookbook_file('/etc/logrotate.d/chef-client').mode.should =="0644"
  end

  it 'should create logrotate for chef-handler' do
    chef_run.should create_cookbook_file '/etc/logrotate.d/chef-handler'
    chef_run.cookbook_file('/etc/logrotate.d/chef-handler').should be_owned_by('root', 'root')
    chef_run.cookbook_file('/etc/logrotate.d/chef-handler').mode.should == "0644"    
  end

  it 'should create logrotate.conf' do
    chef_run.should create_cookbook_file '/etc/logrotate.conf'
    chef_run.cookbook_file('/etc/logrotate.conf').should be_owned_by('root', 'root')
    chef_run.cookbook_file('/etc/logrotate.conf').mode.should == "0644"    
  end


end
