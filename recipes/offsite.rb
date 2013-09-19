# Author:: Paul Mooring <paul@opscode.com>
# Cookbook Name:: opscode-backup
# Recipe:: offsite
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

package 'rsync'

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

backup_targets = search(:node, 'tags:backupclient').collect do |node|
  node['opscode_backup']['targets']
end.flatten

backup_targets.each do |backup|
  directory "/backup/#{backup}" do
    owner 'rsync'
    group 'rsync'
    mode '0755'
  end
end
