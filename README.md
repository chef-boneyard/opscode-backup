Description
===========

Installs and configures rsync based backup solution and provides an lwrp for using the client.

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

* `node['nagios']['user']` - nagios user, default 'nagios'.
* `node['nagios']['group']` - nagios group, default 'nagios'.
* `node['nagios']['plugin_dir']` - location where nagios plugins go,
* default '/usr/lib/nagios/plugins'.

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
