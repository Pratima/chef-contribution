#
# Cookbook Name:: mongo
# Recipe:: default
#
# Copyright 2013
#
# All rights reserved - Do Not Redistribute

cookbook_file "/etc/yum.repos.d/10gen.repo" do
  source "10gen.repo"
  owner "root"
  group "root"
  mode "0644"
end

["mongo-10gen","mongo-10gen-server"].each do |pkg|
  package pkg do
    version "2.4.1-mongodb_1"
  end
end

service "mongod" do
  action :stop
end

{ "/data" => "0755", "/data/hcah" => "0775", "/var/log/mongo" => "0775"}.each do |dir, mode|
  directory dir do
    owner "mongod"
    group "mongod"
    mode mode
    recursive true
  end
end

is_replica_set = !node[:database][:replica].nil?
auth_enabled = node[:database][:auth]

if is_replica_set
  include_recipe "mongo::replica"
end

if auth_enabled == true
  include_recipe "mongo::auth"
end

service "mongod" do
  supports :restart => true
  action [:enable, :start]
end
