#
# Cookbook Name:: munin
# Recipe:: server-source
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


package "liblog-log4perl-perl"
service "apache2" do
  supports :status => true, :restart => true
  action :enable
end

group "munin"
user "munin" do
  comment "munin Administrator"
  gid "munin"
  system true
  shell "/bin/false"
  home "/home/munin"
end

directory "#{node[:munin][:home]}" do
  owner "munin"
  group "munin"
  mode 0755
  recursive true
end


unless ::File.exists?("#{node[:munin][:dir]}")
  # ensuring we have this directory
  directory "/usr/src"
  remote_file "/usr/src/munin-#{node[:munin][:version]}.tar.gz" do
    source node[:munin][:source]
    action :create_if_missing
  end
  bash "Setting up Munin #{node[:munin][:version]}" do
    cwd "/usr/src"
    code <<-EOH
      tar -zxf "munin-#{node[:munin][:version]}.tar.gz" -C /usr/src/
    EOH
  end
  template "/usr/src/munin-#{node[:munin][:version]}/Makefile.config" do
    source "Makefile.config.erb"
    mode 0644
  end
  bash "Compile Munin" do
    cwd "/usr/src/munin-#{node[:munin][:version]}"
    code <<-EOH
      make && make install
    EOH
  end
  bash "Install Munin" do
    code <<-EOH
      chown -R munin:munin #{node[:munin][:home]}/
    EOH
  end
end

link "#{node[:munin][:current]}" do
  to "#{node[:munin][:dir]}"
  owner "munin"
  group "munin"
end


link "/usr/local/share/perl/5.10.0/Munin" do
  to "#{node[:munin][:home]}/usr/local/share/perl/5.10.0/Munin"
  owner "root"
  group "root"
end

munin_servers = search(:node, 'munin:[* TO *]')


template "/etc/cron.d/munin" do
  source "munin.cron.erb"
  mode 0644
end

template "#{node[:munin][:home]}/conf/munin.conf" do
  source "munin.global.erb"
  mode 0644
end

template "#{node[:munin][:home]}/conf/munin-conf.d/cloud.inc.cfg" do
  source "muninconf.cloud.inc.erb"
  mode 0644
  variables(:munin_nodes => munin_servers)
end

authorized_ips = node[:iptables][:ssh][:addresses]

template "/etc/apache2/conf.d/munin" do
  source "apache2-sources.confd.erb"
  mode 0644
  variables(:ips => authorized_ips)
  notifies :restart, "service[apache2]", :delayed
end

template "/etc/logrotate.d/munin" do
  source "munin.logrotate.erb"
  owner "munin"
  group "munin"
  mode "0644"
  backup false
  variables(:logdir => node[:munin][:logdir])
end


