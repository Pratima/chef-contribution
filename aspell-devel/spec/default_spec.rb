require 'chefspec'

describe 'aspell-devel::default' do
   let (:chef_run) { ChefSpec::ChefRunner.new do |node|
		
	node.automatic_attrs[:languages]={ :ruby =>{ :bin_dir=>"/xxx"} , :gems_dir => '/fake/'}
	node['chef_packages']= { 'chef' => {'version'=>'1.0'}}
	node['cpu']={'total'=>'2'}
	node.automatic_attrs[:platform] = 'centos'	
	end.converge 'aspell-devel::default' }

  it 'should install aspell-devel' do
    chef_run.should install_package 'aspell-devel'
  end
end
