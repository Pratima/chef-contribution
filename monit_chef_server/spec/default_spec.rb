require 'chefspec'

describe 'monit::default' do
  let (:chef_run) { ChefSpec::ChefRunner.new do |node|
  node.automatic_attrs[:platform] = 'centos'
#  node['monit_conf_file'] = '/etc/monit.conf'
  end.converge 'monit::default' }

#  it 'should include monit recipe' do
#    chef_run.should include_recipe 'monit'
#  end

  ["chef-solr", "couchdb", "chef-server"].each do |conf_file|
    it "should create #{conf_file}" do
      chef_run.should create_cookbook_file "/etc/monit.d/#{conf_file}"
      chef_run.cookbook_file("/etc/monit.d/#{conf_file}").should be_owned_by('root', 'root')
      chef_run.cookbook_file("/etc/monit.d/#{conf_file}").mode.should == "0644"

    end
  end
end
