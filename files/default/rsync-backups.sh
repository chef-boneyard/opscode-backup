#!/usr/bin/env bash

# Author:: Paul Mooring <paul@opscode.com>
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

########## Default arguments ##########
verb=0
continue_on_error="false"
dir='/tmp'
host='127.0.0.1'
password_file='/etc/rsyncd.secrets'
target='backups'
#######################################
########## Syslog priorities ##########
CRIT="user.crit"
ERROR="user.err"
WARN="user.warn"
NOTICE="user.notice"
INFO="user.info"
DEBUG="user.debug"
#######################################

debug(){
  if [ -z $2 ] ; then
    lvl=0
  else
    lvl=$2
  fi
 
  if [[ $verb -gt $lvl ]] ; then
    echo $1
  fi
}

log(){
  tag=$0
  PRIORITY=$1
  shift
  msg=${@}

  if [ -z $log ] ; then
    hash logger 2>/dev/null	
  	if [ $? -eq 0 ] ; then
  		log="true"
    else
    	log="false"
    fi
  fi

  if [[ $log == "true" ]] ; then
  	logger -t $tag -p $PRIORITY "${msg}"
  	debug "${msg[@]}"
  else
  	debug "${msg[@]}"
  fi
}

help_msg(){
    cat << EOF
Usage: ${0} [options]
Options:
    -q                  Quiet
    -v                  Verbose
    -h                  Help
    -e                  Continue on pre/post script error
    -d <dir>            Backup directory
    -H <host>	        Remote host to backup too
    -f <password file>  Rsync passwords file
    -E <excludes file>  Rsync excludes file
    -p <cmd>	        Pre-backup cmd/script to run
    -P <cmd>            Post-backup cmd/script to run
    -t <target>         Rsync target name


Example: ${0} -e -d /srv/postges/backups -H backups.example.com -t pgsql -P /usr/local/bin/postgres-backup.sh -s postgres
EOF
}

rsync_backup(){
  bkup_src=$1
  bkup_host=$2
  bkup_target=$3
  password_file="--password-file=${4}"
  if ! [ -z $5 ] ; then
    excludes="--exclude-from=${5}"
  fi

  rsync_location="rsync@${bkup_host}::${bkup_target}/IN-PROGRESS"
  retries=4

  while [ $retries -gt 0 ] ; do

    # rsnc command (broken up onto several lines for readability)
    rsync $password_file $excludes --delete --timeout=900 -vap ${bkup_src}/ $rsync_location 2>&1 >> /var/log/rsync.log

    if [[ $? -eq 0 ]] ; then
      break
    else
      retries=$(($retries-1))
      log INFO "rsync failed retries left: ${retries}"
    fi
  done
}

while getopts ":vhed:f:E:H:P:p:n:t:" opt; do
  case $opt in
    h)
      help_msg
      exit 0
      ;;
    v)
      verb=$(expr $verb + 1)
      ;;
    q)
      verb=$(expr $verb - 1)
      ;;
    e)
      continue_on_error="true"
      ;;
    d)
      dir=${OPTARG}
      if [[ ! -d $dir ]] ; then
      	echo "${dir} is not a directory" >&2
        exit 1
      fi
      ;;
    H)
      host=${OPTARG}
      ;;
    f)
      password_file=${OPTARG}
      if [[ ! -f $password_file ]] ; then
      	echo "${password_file} is not a file" >&2
        exit 1
      fi
      ;;
    E)
      excludes_file=${OPTARG}
      if [[ ! -f $excludes_file ]] ; then
      	echo "${excludes_file} is not a file" >&2
        exit 1
      fi
      ;;
    p)
      pre_backup_cmd=${OPTARG}
      ;;
    P)
      post_backup_cmd=${OPTARG}
      ;;
    n)
      name=${OPTARG}
      ;;
    t)
      target=${OPTARG}
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      help_msg
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      help_msg
      exit 1
    ;;
  esac
done

if ! [[ -z $pre_backup_cmd ]] ; then
  log INFO "Running pre-backup command: ${pre_backup_cmd}"
  cmd_stdout=$($pre_backup_cmd 2>&1)
  pre_cmd_stat=$?
  if [[ $pre_cmd_stat -ne 0 ]] ; then
    log ERROR "pre-backup command failed: ${pre_backup_cmd}"
    log ERROR "  $cmd_stdout"
    if [[ $continue_on_error = "true" ]] ; then
      exit $pre_cmd_stat
    fi
  fi
fi

rsync_backup $dir $host $target $password_file $excludes_file

if ! [[ -z $post_backup_cmd ]] ; then
  log INFO "Running post-backup command: ${post_backup_cmd}"
  cmd_stdout=$($post_backup_cmd 2>&1)
  post_cmd_stat=$?
  if [[ $post_cmd_stat -ne 0 ]] ; then
    log ERROR "post-backup command failed: ${post_backup_cmd}"
    log ERROR "  $cmd_stdout"
    if [[ $continue_on_error = "true" ]] ; then
      exit $post_cmd_stat
    fi
  fi
fi
