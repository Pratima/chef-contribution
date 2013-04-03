# Cookbook Name:: postgres
# Recipe:: default
#
# Copyright 2012
#
# All rights reserved - Do Not Redistribute

case node["platform"]
when "centos"
  include_recipe "postgres::centos"
end
