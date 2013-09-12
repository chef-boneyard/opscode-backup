#
# Cookbook Name:: example
# Recipe:: backup
#
# Copyright 2013, Opscode, Inc.
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

# This is an example recipe that uses the opscode_backup lwrp

include_recipe "opscode-backup::client"

rsyncd_server = search(:node, "role:backup-server AND chef_environment:#{node.chef_environment}").first
unless rsyncd_server
  Chef::Log.info "No rsync servers found, skipping opscode-backups::client"
  return
end

cookbook_file "/usr/local/bin/database_backup.sh" do
  source "database_backup.sh.erb"
  owner "root"
  group "root"
  mode "0755"
end

directory node['db']['backup_dir']
directory "#{node['db']['backup_dir']}/current"
directory "#{node['db']['backup_dir']}/archive"

opscode_backup "db" do
  server rsyncd_server['fqdn']
  directory "#{node['db']['backup_dir']}/current"
  cron_schedule "0 * * * *"
  target "db"
  password_file node[:opscode_backup][:rsyncd][:secrets_file]
  pre_cmd "/usr/local/bin/database_backup.sh"
  post_cmd "find #{node['db']['backup_dir']}/archive -type f -cmin +180 -exec rm -rf {} \;"
end
