#
# Cookbook Name:: lotc_first_boot
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
ruby_block "register_mac_ip" do
  block do
    mac = node.default["macaddress"]
    id = mac.delete ":"
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
    mac = node.default["macaddress"]
    id = mac.delete ":"
    databag_item = search(:pg_mac_data, "id:#{id}")
    databag_item.empty?
  end
end
