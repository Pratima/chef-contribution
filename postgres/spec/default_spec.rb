require 'chefspec'

describe 'postgres::default' do
  chef_run = ChefSpec::ChefRunner.new do |node|
    node.automatic_attrs['platform'] = 'centos'
  end
  chef_run.converge 'postgres::default'
  it 'should include postgres::centos recipe' do
    chef_run.should include_recipe "postgres::centos"
  end
end

describe 'postgres::default' do
  chef_run = ChefSpec::ChefRunner.new do |node|
    node.automatic_attrs['platform'] = 'ubuntu'
  end
  chef_run.converge 'postgres::default'
  it 'should include postgres::centos recipe' do
    chef_run.should_not include_recipe "postgres::centos"
  end
end
