#
# Cookbook Name:: passenger_webapp_monitoring
# Recipe:: default
#
# Copyright 2012
#
# All rights reserved - Do Not Redistribute

template "nagios nrpe plugin" do
  nrpe_plugin = node["nagios"]["plugins_dir"] + "/check_passenger"
  node["nrpe"]["check_passenger"] = nrpe_plugin
  path node["nagios"]["plugins_dir"] + "/check_passenger"
  source "check_passenger.erb"
  mode "0755"
  owner "root"
  group "root"
end

