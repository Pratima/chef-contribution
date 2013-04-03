#
# Cookbook Name:: jenkins_ci
# Recipe:: default
#
# Copyright 2013
# All rights reserved - Do Not Redistribute
#
case node["platform"]
when "centos"
  include_recipe "jenkins_ci::centos"
end
