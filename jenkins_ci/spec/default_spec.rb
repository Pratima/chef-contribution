require 'chefspec'

describe 'jenkins_ci::default' do
  chef_run = ChefSpec::ChefRunner.new do |node| 
    node.automatic_attrs['platform'] = 'centos'
  end
  chef_run.converge 'jenkins_ci::default'

  it 'should call jenkins_ci::centos recipe' do
    chef_run.should include_recipe 'jenkins_ci::centos'
  end
end

describe 'jenkins_ci::default' do
  chef_run = ChefSpec::ChefRunner.new do |node| 
    node.automatic_attrs['platform'] = 'ubuntu'
  end
  chef_run.converge 'jenkins_ci::default'

  it 'should call jenkins_ci::centos recipe' do
    chef_run.should_not include_recipe 'jenkins_ci::centos'
  end
end
