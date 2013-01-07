#
# Cookbook Name:: monit_chef_server
# Recipe:: default
#
# Copyright 2012
# All rights reserved - Do Not Redistribute

include_recipe "monit"

["chef-solr", "couchdb", "chef-server"].each do |conf_file|
  cookbook_file "/etc/monit.d/#{conf_file}" do
    source conf_file
    mode "0644"
    owner "root"
    group "root"
    notifies :restart, "service[monit]"
    notifies :run, "execute[monit start #{conf_file}]"
  end

  execute "monit start #{conf_file}" do
    action :nothing
  end
end
