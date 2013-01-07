require 'chefspec'

describe 'xvfb::default' do
  let (:chef_run) { ChefSpec::ChefRunner.new do |node|
		
	node.automatic_attrs[:languages]={ :ruby =>{ :bin_dir=>"/xxx"} , :gems_dir => '/fake/'}
	node['chef_packages']= { 'chef' => {'version'=>'1.0'}}
	node['cpu']={'total'=>'2'}	
	end.converge 'xvfb::default' }


  %w{ xorg-x11-server-Xvfb xorg-x11-server-Xorg xorg-x11-xauth xorg-x11-xinit firstboot glx-utils hal wacomexpresskeys xorg-x11-server-utils xorg-x11-utils xvattr x11vnc dbus-x11}.each do |pkg|
    it "should install #{pkg}" do
      chef_run.should install_package pkg
    end
  end

end
