#
# Cookbook Name:: munin
# Recipe:: server
#
# Copyright 2010-2011, Opscode, Inc.
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

#include_recipe "apache2"
#include_recipe "apache2::mod_auth_openid"
#include_recipe "apache2::mod_rewrite"
#include_recipe "munin::client"

#package "munin"

service "apache2" do
  supports :status => true, :restart => true
  action :enable
end


munin_clients = search(:node, 'recipes:munin\:\:client')


template "#{node['munin']['home']}/conf/munin.conf" do
  source "munin.conf.erb"
  mode 0644
  variables(:munin_nodes => munin_clients)
end

#authorized_ips = node[:iptables][:ssh][:addresses]

#template "/etc/apache2/conf.d/munin" do
#  source "apache2.confd.erb"
#  mode 0644
#  variables(:ips => authorized_ips)
#  notifies :restart, "service[apache2]", :delayed
#end

