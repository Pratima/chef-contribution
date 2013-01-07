case node['platform']
when "centos"
	mysql_packages = ["mysql", "mysql-devel"]
	mysql_service_name =  "mysqld"
when "ubuntu"
  mysql_packages = ["libmysqlclient-dev"]
	mysql_service_name =  "mysql"
end

mysql_packages.each do |pkg|
  package pkg
end

package "mysql-server" do 
  action :install
  notifies :start, "service[#{mysql_service_name}]", :immediately
  notifies :run, "execute[change-root-password]", :immediately
end

service mysql_service_name do
  action [:enable, :start]
end

#root_password = "password" #TODO: databag
execute "change-root-password" do
  command "mysqladmin -u root password #{node['mysql']['root_password']}"
  notifies :restart, "service[#{mysql_service_name}]", :immediately
  action :nothing
end
