# Author:: Paul Mooring <paul@opscode.com>
# Cookbook Name:: opscode-backup
# Recipe:: server
#
# Copyright 2013, Opscode, Inc
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

backup_targets = search(:node, 'tags:backupclient').collect do |node|
  node['opscode_backup']['targets']
end.flatten

secrets = data_bag_item('secrets', node.chef_environment)

%w{rsync libxml2-dev libxslt-dev logtail libdatetime-perl}.each do |pkg|
  package pkg do
    action :install
  end
end

# The backup-rotate script needs ruby, but I don't want to fight with potential
# source installations
package "ruby" do
  not_if "which ruby"
end

cookbook_file '/usr/local/bin/backup-rotate' do
  source 'backup-rotate'
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/default/rsync' do
  source 'rsync-default.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[rsync]'
end

# Set up the rsync user for ssh copies
user 'rsync' do
  comment 'Rsync User'
  home    '/backup'
  shell   '/bin/bash'
  system  true
end

directory '/backup' do
  owner 'rsync'
  group 'rsync'
  mode '0755'
end

directory '/backup/.ssh' do
  owner 'rsync'
  group 'rsync'
  mode '0700'
end

file '/backup/.ssh/id_rsa' do
  content secrets['rsync-backups-user.priv']
  owner 'rsync'
  group 'rsync'
  mode '0600'
end

backup_targets.each do |backup|
  directory "/backup/#{backup}" do
    owner 'rsync'
    group 'rsync'
    mode '0755'
  end
end

template node['opscode_backup']['rsyncd']['config_file'] do
  source 'rsyncd.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    :backups => backup_targets
  )
  notifies :restart, 'service[rsync]'
end

# secrets!
template node['opscode_backup']['rsyncd']['secrets_file'] do
  source 'rsync.secrets.erb'
  owner 'root'
  group 'root'
  mode "0600"
  variables(
    :rsyncd_password => data_bag_item('secrets', node.chef_environment)['rsyncd_password']
  )
  notifies :restart, 'service[rsync]'
end

cookbook_file '/usr/local/bin/rsync-backup-pre.sh' do
  source 'rsync-backup-pre.sh'
  owner 'root'
  group 'root'
  mode '0755'
end

template '/usr/local/bin/rsync-backup-post.sh' do
  source 'rsync-backup-post.sh.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/cron.d/offsite-backups-push' do
  source 'offsite-backups-push-cron.erb'
  owner 'root'
  group 'root'
  mode '0600'
end

service 'rsync' do
  action [:enable, :start]
  supports :restart => true, :reload => true
end
