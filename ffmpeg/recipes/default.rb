#
# Cookbook Name:: ffmpeg
# Recipe:: default
#
# Copyright 2011
#
# All rights reserved - Do Not Redistribute
#

remote_file "/opt/ffmpeg-0.10.1.tar.gz" do
    source "http://www.ffmpeg.org/releases/ffmpeg-0.10.1.tar.gz"
    not_if{ ::File.exists? "/opt/ffmpeg-0.10.1.tar.gz" }
    end

execute "Extract_ffmpeg" do
    cwd "/opt"
	command "tar -zxvf ffmpeg-0.10.1.tar.gz"
    not_if{ ::File.exists? "/opt/ffmpeg-0.10.1" }
    end

script "Install_ffmpeg" do
    interpreter "bash"
    user "root"
    cwd "/opt/ffmpeg-0.10.1"
    code <<-EOH
    ./configure
    make
    make install
    EOH
	creates "/usr/local/bin/ffmpeg"
	end
