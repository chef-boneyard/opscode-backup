#
# Author:: Paul Mooring <paul@opscode.com>
# Cookbook Name:: opscode-backup
# Attributes:: server
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

default['opscode_backup']['rsyncd']['config_file'] = '/etc/rsyncd.conf'
default['opscode_backup']['rsyncd']['opts'] = ''
default['opscode_backup']['rsyncd']['nice'] = 10
default['opscode_backup']['rsyncd']['max_conn'] = 0
default['opscode_backup']['rsyncd']['timeout'] = 900  # 0 to disable
default['opscode_backup']['rsyncd']['strict'] = 'true'
default['opscode_backup']['rsyncd']['secrets_file'] = '/etc/rsyncd.secrets' # change secrets_file to "" if you don't need it written or used in config_file
default['opscode_backup']['rsyncd']['enable'] = 'true'

default['opscode_backup']['retention']['hours']  = 24
default['opscode_backup']['retention']['days']   = 8
default['opscode_backup']['retention']['weeks']  = 8
default['opscode_backup']['retention']['months'] = 7

default['opscode_backup']['offsite']['rotation_schedule'] = "30 2 * * *",

default['opscode_backup']['mailto_addr'] = ''
default['opscode_backup']['offsite_excludes'] = ['*/hourly-*']
default['opscode_backup']['offsite_servers'] = [
  # {
    # 'host' => 'offsite-backups.example.com',
    # 'cron_schedule' => "0 0 * * *",
    # 'rsync_opts' => '--timeout 600 --exclude hourly* --exclude CURRENT --exclude IN-PROGRESS*'
  # }
]
