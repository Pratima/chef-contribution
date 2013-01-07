#
# Cookbook Name:: logrotate
# Recipe:: default
#
# Copyright 2012	
#
# All rights reserved - Do Not Redistribute

minute=(node['ipaddress'].split(".").last.to_i) * 2
hr = 12
while minute >= 60 do
  hr = hr + 1
  if (hr > 23) then
    hr = 0
  end
  minute = minute - 60
end

case node['platform']
when 'ubuntu'
  conf_file_source = "ubuntu/logrotate.conf"
when 'centos'
  conf_file_srouce = "logrotate.conf"
end

package "logrotate" do
	action :install
end

cookbook_file "/etc/logrotate.d/chef-client" do
  source "chef-client"
	owner "root"
	group "root"
	mode "0644"
end

cookbook_file "/etc/logrotate.d/chef-handler" do
  source "chef-handler"
	owner "root"
	group "root"
	mode "0644"
end

cookbook_file "/etc/logrotate.conf" do
  source conf_file_source
	owner "root"
	group "root"
	mode "0644"
end

cron "Rotating and compressing chef logs and reports" do
  hour hr.to_s
  minute minute.to_s
	command "/usr/sbin/logrotate -f /etc/logrotate.conf"
end
