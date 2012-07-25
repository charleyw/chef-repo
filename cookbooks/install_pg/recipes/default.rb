#
# Cookbook Name:: install_pg
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

cookbook_file "/var/log/iso/#{node["pg_iso"]}.iso" do
  source "#{node["pg_iso"]}.iso"
  action :create
  notifies :mount, "mount[/mnt]", :immediately
end

mount "/mnt" do
  device "/var/log/iso/#{node["pg_iso"]}.iso"
  options "loop"
  action :nothing
end

execute "install_P" do
  cwd "/mnt"
  command "./install.sh -P"
  action :run
  notifies :create, "template[/home/dveinstaller/ma70/installparameters.properties]", :immediately
end

template "/home/dveinstaller/ma70/installparameters.properties" do
  source "installparameters.properties.erb"
  action :nothing
end

execute "install_I" do
  cwd "/mnt"
  command "./install.sh -I config/#{node["pg_layout"]}_node.conf"
  action :run
  notifies :umount, "mount[/mnt]", :immediately
end
