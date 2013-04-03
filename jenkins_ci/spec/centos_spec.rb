require 'chefspec'

describe 'jenkins_ci::centos' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'jenkins_ci::centos' }

  it 'should place jenkins repo file in /etc/yum.repos.d' do
    chef_run.should create_cookbook_file("/etc/yum.repos.d/jenkins.repo")
    chef_run.cookbook_file("/etc/yum.repos.d/jenkins.repo").source.should == "jenkins.repo"
    chef_run.cookbook_file("/etc/yum.repos.d/jenkins.repo").should be_owned_by("root", "root")
    chef_run.cookbook_file("/etc/yum.repos.d/jenkins.repo").mode.should == "0644"
  end

  it "should install jenkins" do
    chef_run.should install_package "jenkins"
  end

  it "should enable and start jenkins" do
    chef_run.should set_service_to_start_on_boot "jenkins"
    chef_run.should start_service "jenkins"
    chef_run.service("jenkins").supports.should == {:start => true, :stop => true, :restart => true}
  end
end
