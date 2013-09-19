Description
===========

Installs and configures rsync based backup solution and provides an lwrp for using the client.

Overview
========

This cookbooks has recipes to set up a local and offsite backup server as well as a client to ship files to those servers.  It also provides an LWRP for using the server which will create a job in crontab to rsync a specified directory to the server optionally running pre/post commands.

Examples are provide for a client recipe and a role in the examples directory.

Requirements
============

Chef
----

Chef version 11.0.0+

Platform
--------

* Ubuntu 10.04, 12.04

Attributes
==========

default
-------

The following attributes are used by both client and server recipes.

* `node['opscode_backup']['rsyncd']['config_file']` - The servers config file path. Default is "/etc/rsyncd.conf"
* `node['opscode_backup']['rsyncd']['opts']` - Extra options for rsyncd. Default is ""
* `node['opscode_backup']['rsyncd']['nice']` - Nice value for rsynd process. Default is 10
* `node['opscode_backup']['rsyncd']['max_conn']` - Max connections to rsyncd. Default is 0
* `node['opscode_backup']['rsyncd']['timeout']` - Timeout value for rsyncd. Default is 900
* `node['opscode_backup']['rsyncd']['strict']` - Enable strict option for rsyncd. Default is "true"
* `node['opscode_backup']['rsyncd']['secrets_file']` - Path to secrets file for rsyncd. Default is "/etc/rsyncd.secrets"
* `node['opscode_backup']['rsyncd']['enable']` - Enable the rsyncd service. Default is "true"
* `node['opscode_backup']['retention']['hours']` - Number of hourly copies to keep. Default is 24
* `node['opscode_backup']['retention']['days']` - Number of daily copies to keep. Default is 7
* `node['opscode_backup']['retention']['weeks']` - Number of weekly copies to keep. Default is 8
* `node['opscode_backup']['retention']['months']` - Number of montly copies to keep. Default is 6
* `node['opscode_backup']['mailto_addr']` - MAILTO address for cron entry. No Default
* `node['opscode_backup']['offsite_servers']` - An array containing offsite servers to copy to (see examples). No Default

Recipes
=======

default
-------

Includes the `opscode-backup::client` recipe.

client
------

Installs the rsync package and sets up the rsync secrets file.

server
------

Searches for all the nodes tagged with `backupclient` and creates rsync targets for them.  Installs and configures rsyncd along with a shared secret and pre/post scripts.

offsite
-------

Sets up directories to backup to an offsite server

Resources/Providers
===================

The opscode_backup LWRP is the primary way to use this cookbook

# Actions

- :create: Sets up a cron job to run the backup. Default action.
- :delete: Deletes an existing crontab entry.

# Attribute Parameters

- :target: The name of the rsync target to back up to.
- :server: The rsyncd server.
- :directory: The directory to back up.
- :cron_schedule: Cron style schedule of when to run the backup example: `0 * * * *`
- :pre_cmd: A command to run prior to the backup.
- :post_cmd: A command to run after the backup.
- :password_file: The rsyncd password file.
- :excludes_file: An rsync excludes file.
- :user: The user to run the cron job as.


# Examples

    opscode_backup "db" do
      server rsyncd_server['fqdn']
      directory "#{node['db']['backup_dir']}/current"
      cron_schedule "0 * * * *"
      target "db"
      password_file node[:opscode_backup][:rsyncd][:secrets_file]
      pre_cmd "/usr/local/bin/database_backup.sh"
      post_cmd "find #{node['db']['backup_dir']}/archive -type f -cmin +180 -exec rm -rf {} \;"
    end

Usage
=====

A data bag named 'secrets' with an item named after the current environment is assumed for distributing the shared rsync key.  Creating that item and adding a 'rsyncd_password' key is needed to make this work.

See the included `example/recipe/backup.rb` file for a complete example of using the client and `examples/roles/backup-server.json` for the server.

License and Author
==================

Author:: Paul Mooring <paul@opscode.com>

Copyright 2013, Opscode, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
