# Author:: Paul Mooring <paul@opscode.com>
# Cookbook Name:: opscode-backup
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

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  package 'rsync'

  cookbook_file '/usr/local/bin/rsync-backups.sh' do
    cookbook 'opscode-backup'
    source 'rsync-backups.sh'
    backup false
    owner 'root'
    group 'root'
    mode '0755'
  end

  directory new_resource.directory

  cron new_resource.name do
    minute get_time(new_resource.cron_schedule)[:minute]
    hour get_time(new_resource.cron_schedule)[:hour]
    day get_time(new_resource.cron_schedule)[:day]
    month get_time(new_resource.cron_schedule)[:month]
    weekday get_time(new_resource.cron_schedule)[:weekday]

    user new_resource.user

    command get_command(new_resource)

    action :create
  end

  Chef::Log.debug "#{new_resource.name} tagging node"
  if node['tags'].length > 0
    node.normal['tags'] << 'backupclient' unless node['tags'].include?('backupclient')
  else
    node.normal['tags'] = ['backupclient']
  end

  node.normal['opscode_backup']['targets'] = Array(node['opscode_backup']['targets']).dup.push(new_resource.target)

  Chef::Log.debug "#{new_resource.name} rsync backup job createed"

  new_resource.updated_by_last_action(true)
end

action :delete do
  cron new_resource.name do
    minute get_time(new_resource.cron_schedule)[:minute]
    hour get_time(new_resource.cron_schedule)[:hour]
    day get_time(new_resource.cron_schedule)[:day]
    month get_time(new_resource.cron_schedule)[:month]
    weekday get_time(new_resource.cron_schedule)[:weekday]

    user new_resource.user

    command get_command(new_resource)

    action :delete
  end
  Chef::Log.debug "#{new_resource.name} rsync backup job deleted"
end

def get_time(schedule)
  @schedule ||= begin
    s = schedule.split(' ')
    { :minute => s[0], :hour => s[1], :day => s[2], :month => s[3], :weekday => s[4] }
  end
end

def get_command(res)
  cmd = "/usr/local/bin/rsync-backups.sh -d #{res.directory} -H #{res.server} -t #{res.target} "
  cmd += "-f #{res.password_file} " if res.password_file
  cmd += "-E #{res.excludes_file} " if res.excludes_file
  cmd += "-p '#{res.pre_cmd}' " if res.pre_cmd
  cmd += "-P '#{res.post_cmd}' " if res.post_cmd

  cmd
end
