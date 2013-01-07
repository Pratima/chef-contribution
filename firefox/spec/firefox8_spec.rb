require 'chefspec'

describe 'firefox::firefox8' do
  let (:chef_run) { ChefSpec::ChefRunner.new do |node|
		
	node.automatic_attrs[:languages]={ :ruby =>{ :bin_dir=>"/xxx"} , :gems_dir => '/fake/'}
	node['chef_packages']= { 'chef' => {'version'=>'1.0'}}
	node['cpu']={'total'=>'2'}
	node.automatic_attrs[:platform] = 'centos'	
	node.automatic_attrs[:platform_version] = '6.0'	
	end.converge 'firefox::firefox8' }

  it 'should remove firefox' do
    chef_run.should remove_package 'firefox'
  end


  %w{gtk2 dbus-x11 xulrunner xulrunner-devel}.each do |pkg|
    it "should install #{pkg}" do
      chef_run.should install_package pkg
    end
  end

  it 'Download firefox 8' do
    chef_run.should execute_command "wget http://vm101-052.sc01.thoughtworks.com/firefox/firefox-8.0.tar.bz2"
  end

  it 'Install Firefox 8' do
    chef_run.should execute_command "tar jxvf firefox-8.0.tar.bz2 -C /opt"
  end

end
