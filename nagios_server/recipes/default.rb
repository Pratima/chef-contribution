include_recipe "httpd"

case node['platform']
when "centos"
  nrpe_service_name = "nrpe"
	nrpe_user = "nrpe"
when "ubuntu"
  nrpe_service_name = "nagios-nrpe-server"
	nrpe_user = "nagios"
end


%w{nagios php nagios-plugins-all nagios-plugins-nrpe pnp4nagios}.each do |pkg|
  package pkg 
end

template "/etc/chef/client.rb" do
  source "client.erb"
  mode "0644"
end


template "#{node["apache"]["dir"]}/conf.d/nagios.conf" do
  source "nagios.conf.erb"
  owner "root"
  group "root"
  mode "644"
end

template "/etc/nagios/cgi.cfg" do
  source "cgi.cfg.erb"
  owner "root"
  group "root"
  mode "644"

  variables({ :nagiosadmins => node["nagios"]["admins"].keys.join(','),
              :nagiosguests => node["nagios"]["guests"].keys.join(',')})
  notifies :restart, "service[nagios]"
end

file "/etc/nagios/passwd" do
  owner "nagios"
  group "nagios"
  action :create_if_missing
end

directory "/opt/nagios/bin" do
	owner "root"
	group "root"
	mode "0777"
  recursive true
	action :create
	end

directory "/var/spool/nagios/graphios" do
        owner "nagios"
        group "nagios"
        mode "0777"
        action :create
end

template "/etc/nagios/objects/graphios.cfg" do
  source "graphios.cfg.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, "service[graphios]"
	end

cookbook_file "/opt/nagios/bin/graphios.py" do
	source "graphios.py"
	owner "nagios"
	group "nagios"
	mode "0755"
	end

cookbook_file "/etc/init.d/graphios" do
	source "graphios"
	owner "root"
	group "root"
	mode "0750"
	end

cookbook_file "/opt/nagios/bin/clean_spooler.sh" do
	source "clean_spooler.sh"
	owner "root"
	group "root"
	mode "0755"
end


if Chef::Config[:solo]
  Chef::Log.error("This Nagios cookbook cannot run with Chef Solo as it depends on Search.")
  nodes_from_solr = []
else
  nodes_from_solr = search(:node, "*:*")
  go_agents = search(:node, "recipes:*go_agent*")
  go_servers = search(:node, "recipes:*go_server*")
  web_servers = search(:node, "recipes:*passenger*")
  centos_servers = search(:node, "platform:centos")
  ubuntu_servers = search(:node, "platform:ubuntu")
end

%w{hosts services localhost commands contacts templates}.each do |object|
  template "/etc/nagios/objects/#{object}.cfg" do
    source object + ".cfg.erb"
    owner "root"
    group "root"
    mode "644"
    variables(:nodes_from_solr => nodes_from_solr, :go_agents => go_agents, :go_servers => go_servers, :web_servers => web_servers, :centos_servers => centos_servers, :ubuntu_servers => ubuntu_servers)
    notifies :restart, "service[nagios]"
    notifies :restart, "service[#{nrpe_service_name}]"
    notifies :restart, "service[graphios]"
  end
end

template "/etc/nagios/nagios.cfg" do
  source "nagios.cfg.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, "service[graphios]"
end

cookbook_file "/var/www/html/index.html" do
  source "index.html"
  mode "0755"
end


#TODO: although the htpasswd util is idempotent, this resource isn't, push all this into an idempotent resource

execute "update the passwords file for admins" do
  cmd = node["nagios"]["admins"].collect do |user, passwd|
    "/usr/bin/htpasswd -b /etc/nagios/passwd #{user} #{passwd}"
  end.join(" && ")

  command cmd
  notifies :restart, resources(:service => 'httpd') 
end

execute "update the passwords file for guests" do
  cmd = node["nagios"]["guests"].collect do |user, passwd|
    "/usr/bin/htpasswd -b /etc/nagios/passwd #{user} #{passwd}"
  end.join(" && ")

  command cmd
  notifies :restart, resources(:service => 'httpd') 
end

execute "Changing permissions for client.pem in /etc/chef/ for nagios access" do
  command "chmod 644 /etc/chef/client.pem"
end

execute "nagios-config-check" do
  command "nagios -v /etc/nagios/nagios.cfg"
end

##### Event Handler #######

directory "/usr/lib64/nagios/plugins/eventhandlers" do
	owner "nagios"
	group "nagios"
	mode "0755"
end

%w{restart-chef-client restart-go-agent}.each do |handler|
cookbook_file "/usr/lib64/nagios/plugins/eventhandlers/#{handler}" do
        source handler
        owner "nagios"
        group "nagios"
        mode "0755"
        end
end

##### Include Graphios #####

service "graphios" do
  supports :restart => true
  action [ :enable, :start ]
end

service nrpe_service_name do
  supports :restart => true
  action [ :enable, :start ]
end

service "nagios" do
  supports :restart => true
  action [ :enable, :start ]
end

cron "delete graphios spooler" do
  hour "0"
  minute "0"
  command "sh /opt/nagios/bin/clean_spooler.sh"
end
