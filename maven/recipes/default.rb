#
# Cookbook Name:: maven
# Recipe:: default
#
# Copyright 2012
#
# All rights reserved - Do Not Redistribute
#

bash "Setting up Maven" do
  code <<-EOF
    cd /opt
    wget http://apache.techartifact.com/mirror/maven/maven-3/3.0.4/binaries/apache-maven-3.0.4-bin.tar.gz
    tar -xvzf /opt/apache-maven-3.0.4-bin.tar.gz
    ln -s /opt/apache-maven-3.0.4 /usr/maven
    echo 'export PATH=/usr/maven/bin:$PATH' >> /root/.bashrc
  EOF
  user "root"
  group "root"
  action :run
  not_if "mvn -v | grep 3.0.4"
end

execute "echo 'export PATH=/usr/maven/bin:$PATH' >> /var/go/.bash_profile" do
        user         'go'
        not_if "grep 'export PATH=/usr/maven/bin:$PATH' /var/go/.bash_profile"
end
