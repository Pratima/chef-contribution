#
# Cookbook Name:: mysql_configuration
# Recipe:: default
#
# Copyright 2011
#
# All rights reserved - Do Not Redistribute

node["mysql"]["users"].each do |k, v|
  node["mysql"]["databases"].each do |db|
    Chef::Log.info "Creating mysql databases"
    execute "Create database #{db}" do
      command "mysql -u root -ppassword -e 'create database #{db};'"
      action :run
      not_if "mysql -u root -ppassword -e 'show databases;' | grep #{db}"
    end

    Chef::Log.info "Create mysql users and granting database specific access"
    ["\"CREATE USER #{k} IDENTIFIED BY '#{v}';\"", "\"GRANT ALL PRIVILEGES ON #{db}.* TO #{k} WITH GRANT OPTION;\""].each do |cmd|
        execute "mysql -uroot -p#{node["mysql"]["root_password"]} -e #{cmd} 2>/dev/null" do
          returns [0, 1]
          ignore_failure true
        end
    end
  end
end
