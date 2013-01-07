# Cookbook Name:: firefox
# Recipe:: firefox8
# Copyright 2011, YOUR_COMPANY_NAME
# All rights reserved - Do Not Redistribute

package "firefox" do
  action :remove
end

["gtk2", "dbus-x11", "xulrunner", "xulrunner-devel"].each do |pkg|
  package pkg do
    action :install
  end
end

execute "Downloading firefox 8" do
  command "wget 'http://download.mozilla.org/?product=firefox-8.0&os=linux&lang=en-US' -O firefox-8.0.tar.bz2"
  cwd "/tmp"
  action :run
	not_if {File.exists?('/opt/firefox/firefox')}
end

execute "Installing firefox 8" do
  command "tar jxvf firefox-8.0.tar.bz2 -C /opt"
  cwd "/tmp"
	action :run
  not_if {File.exists?('/opt/firefox/firefox')}
end

link "/usr/bin/firefox" do
  to "/opt/firefox/firefox" 
end
