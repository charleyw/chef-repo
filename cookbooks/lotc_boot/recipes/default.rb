#
# Cookbook Name:: lotc_first_boot
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

ip = node["ipaddress"]
ips = ip.split "."
id = ips[2]+ips[3]
host_name = "node"+id

#used for register mac and ip to remote server
ruby_block "register_mac_ip" do
  block do
    mac_ip = {
      "id" => id,
      "ip" => node["ipaddress"],
      "mac" => node["macaddress"]
    }
    databag_item = Chef::DataBagItem.new
    databag_item.data_bag("pg_mac_data")
    databag_item.raw_data = mac_ip
    databag_item.save
  end
  action :create
  only_if do
    ip = node["ipaddress"]
    id = ip.delete "."
    databag_item = search(:pg_mac_data, "id:#{id}")
    databag_item.empty?
  end
end

execute "reload_config" do
  command "cluster config -r"
  action :nothing
end

execute "reboot" do
  command "reboot"
  action :nothing
end

#reload cluster config
template "/cluster/etc/cluster.conf" do
  source "cluster.conf.erb"
  variables({
    :name => host_name
  })
  action :create
  notifies :run, "execute[reload_config]", :immediately
  notifies :delete, "file[/etc/chef/client.pem]", :immediately
  notifies :run, "execute[reboot]", :immediately
end

#when the host name changed, the old client.pem need to be delete to register to server again when boot.
file "/etc/chef/client.pem" do
  action :nothing
end
