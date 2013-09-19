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

# Including the client recipe will ensure rsync is installed
include_recipe 'opscode-backup::client'

# A search will dynamically find my backup server, if no backup server is found the recipe should stop here
rsyncd_server = search(:node, "role:backup-server AND chef_environment:#{node.chef_environment}").first
unless rsyncd_server
  Chef::Log.info 'No rsync servers found, skipping opscode-backups::client'
  return
end

# Frequently it's easier to put any preperations for the backup into a script. This would include
# steps like taking an lvm snapshot or using mysqldump to generate a consistent backup.
cookbook_file '/usr/local/bin/database_backup.sh' do
  source 'database_backup.sh.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

# The LWRP requires whatever directory I choose to backup to already exists.
directory node['db']['backup_dir']
directory "#{node['db']['backup_dir']}/current"
directory "#{node['db']['backup_dir']}/archive"

# This is where the LWRP is actually used:
#   server - This is a string of where to backup to, this example uses the fqdn from the search above
#   directory - This is the directory that is actually backed up to the remote server
#   cron_schedule - Standard cron syntax for when to run the backups (hourly in this case)
#   target - The name of the rsync target (this will get added as a node attribute so the server recipe can create it)
#   password_file - The file where the rsyncd shared secret is stored (see client recipe for it's creation)
#   pre_cmd/post_cmd - Shell commands to run before and after the rsync
opscode_backup 'db' do
  server rsyncd_server['fqdn']
  directory "#{node['db']['backup_dir']}/current"
  cron_schedule '0 * * * *'
  target 'db'
  password_file node['opscode_backup']['rsyncd']['secrets_file']
  pre_cmd '/usr/local/bin/database_backup.sh'
  post_cmd "find #{node['db']['backup_dir']}/archive -type f -cmin +180 -exec rm -rf {} \;"
end
