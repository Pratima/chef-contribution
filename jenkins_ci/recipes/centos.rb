#
# Cookbook Name:: jenkins_ci
# Recipe:: centos
#
# Copyright 2013
# All rights reserved - Do Not Redistribute
#

cookbook_file "/etc/yum.repos.d/jenkins.repo" do
  source "jenkins.repo"
  owner "root"
  group "root"
  mode "0644"
end

package "jenkins"

service "jenkins" do
  supports :start => true, :stop => true, :restart => true
  action [:enable, :start]
end 
