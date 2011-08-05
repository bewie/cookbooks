#
# Cookbook Name:: munin
# Recipe:: client
#
# Copyright 2010, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package "munin-node"

service "munin-node" do
  supports :restart => true
  action [ :enable, :start ]
end

#munin_servers = search(:node, "role:#{node['munin']['server_role']} AND app_environment:#{node['app_environment']}")
#munin_servers = default[:munin][:servers][:addresses]
#variables :munin_servers => munin_servers
munin_servers_ip =  search(:node, 'recipes:munin\:\:server').map { |cfg| cfg["ipaddress"] }

template "/etc/munin/munin-node.conf" do
  source "munin-node.conf.erb"
  mode 0644
  variables :munin_servers => munin_servers_ip
  notifies :restart, resources(:service => "munin-node")
end

case node[:platform]
when "arch"
  execute "munin-node-configure --shell | sh" do
    not_if { Dir.entries("/etc/munin/plugins").length > 2 }
    notifies :restart, "service[munin-node]"
  end
end

if node.run_list.roles.include? "SplayceMySQL"
  %w(
    mysql_queries      
    mysql_slowqueries  
    mysql_threads 
    mysql_bytes
  ).each do |plugin_name|
    munin_plugin plugin_name do
      enable true
    end
  end
end

if node.run_list.roles.include? "Stootie"
  %w(
    mysql_queries      
    mysql_slowqueries  
    mysql_threads 
    mysql_bytes
  ).each do |plugin_name|
    munin_plugin plugin_name do
      enable true
    end
  end
end

#add/remove plugin 
%w(
  nfs_client_custom
  sendmail_mailqueue
  sendmail_mailstats
  sendmail_mailtraffic
  nfs4_client
  lpstat
  users
).each do |plugin_name|
  munin_plugin plugin_name do
    enable false
  end
end

