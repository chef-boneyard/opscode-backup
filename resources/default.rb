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
#

actions :create, :delete
default_action :create

attribute :target, :kind_of => String, :name_attribute => true
attribute :server, :kind_of => String, :required => true
attribute :directory, :kind_of => String, :required => true
attribute :cron_schedule, :kind_of => String, :default => "0 * * * *"
attribute :pre_cmd, :kind_of => [String, NilClass], :default => nil
attribute :post_cmd, :kind_of => [String, NilClass], :default => nil
attribute :password_file, :kind_of => [String, NilClass], :default => nil
attribute :excludes_file, :kind_of => [String, NilClass], :default => nil
attribute :user, :kind_of => String, :default => 'root'
