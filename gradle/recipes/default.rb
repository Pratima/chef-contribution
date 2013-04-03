# Cookbook Name:: gradle
# Recipe:: default
#
# Copyright 2012
#
# All rights reserved - Do Not Redistribute


remote_file "#{node["webapp"]["home"]}/gradle-1.3-all.zip" do
  source "http://services.gradle.org/distributions/gradle-1.3-all.zip"
  owner "openlmis"
  group "openlmis"
  mode "0755"
end

script "Gradle Installation" do
  interpreter "bash"
  user "openlmis"
  cwd node["webapp"]["home"]
  code <<-EOH
  cd #{node["webapp"]["home"]} 
  unzip -o #{node["webapp"]["home"]}/gradle-1.3-all.zip
  EOH
  not_if "gradle -v | grep 'Gradle 1.3'"
  notifies :run, "execute[Set gradle home]", :immediately
end

execute "Set gradle home" do
  command "echo 'export PATH=#{node["webapp"]["home"]}/gradle-1.3/bin:$PATH' >> /etc/bashrc"
  not_if "grep gradle-1.3 /etc/bashrc"
  action :nothing
end
