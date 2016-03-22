# Replication
[![Build Status](https://travis-ci.org/Adaptavist/puppet-replication.svg?branch=master)](https://travis-ci.org/Adaptavist/puppet-replication)

#### Table of Contents

1. [Overview - What is the replication module?](#overview)
1. [Module Description - What does the module do?](#module-description)
1. [Module Dependencies - What does the module rely on?](#module-dependencies)
1. [Usage - The classes and defined types available for configuration](#usage)
    * [Classes and Defined Types](#classes-and-defined-types)
        * [Class: replication](#class-replication)
    * [Examples - Demonstrations of some configuration options](#examples)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Classes](#classes)
        * [Public Classes](#public-classes)
        * [Private Classes](#private-classes)
    * [Defined Types](#defined-types)
        * [Public Defined Types](#public-defined-types)
        * [Private Defined Types](#private-defined-types)
    * [Templates](#templates)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)
    * [Contributing to the module](#contributing)
    * [Running tests - A quick guide](#running-tests)

## Overview

The **Replication** module

## Module Description

Module sets up replication server and clients for filesystem, svn and database replication.

## Prerequisites

### Database replication

IMPORTANT mysql setup that is prerequisite to replication:

1) Make sure you enable binary logging on the server and set server id. 
```
    mysqlconfig::custom_mysql_options:
          mysqld:
            log-bin: 'mysqld-bin'
            binlog-do-db: 'avst_prod_db'
            server-id: 2
            binlog_format: 'row'
```
2) Make sure the replication user exists on the server and has sufficient permissions:

```
#setup mysql grants
mysqlconfig::users:
    'avst_dr_repl@localhost':
        ensure: 'present'
        password_hash: '*encrypted password'
    'avst_dr_dump@localhost':
        ensure: 'present'
        password_hash: '*encrypted password'

mysqlconfig::grants:
    'avst_dr_repl@localhost/replication':
        options: ['GRANT']
        privileges: ['REPLICATION CLIENT']
        table: '*.*'
        user: 'avst_dr_repl@localhost'
    'avst_dr_dump@localhost/replication':
        options: ['GRANT']
        privileges: ['SELECT', 'LOCK TABLES', 'SHOW VIEW', 'EVENT', 'TRIGGER', 'REPLICATION CLIENT']
        table: '*.*'
        user: 'avst_dr_dump@localhost'
```
3) Stunnel can be configured via module

```
stunnel_config::tuns:
    'mysql':
        accept: '13306'
        connect: '3306'
        certificate: '/etc/stunnel/stunnel.pem'
        ca_file: '/etc/stunnel/stunnel.pem'
        verify: '2'
        chroot: '/var/lib/stunnel4/'
        user: 'stunnel4'
        group: 'stunnel4'
        pid_file: '/stunnel4.pid'
        ssl_options: 'NO_SSLv2'
        client: false
        foreground: false
```

#### Example usage

```
replication::database::client::replication_user: 'avst_dr_repl'
replication::database::client::replication_password: 'password' #put this into encrypted yaml file
replication::database::client::dump_user: 'avst_dr_dump'
replication::database::client::dump_password: 'password' #put this into encrypted yaml file
replication::database::client::to_server_user: 'avst_dr_restore'
replication::database::client::to_server_password: 'password' #put this into encrypted yaml file
replication::database::client::client_tunnels:
    'mysql':
        accept: '127.0.0.1:13306'
        connect: 'avst-temp1.vagrant:13306'
        certificate: '/etc/stunnel/stunnel.pem'
        ca_file: '/etc/stunnel/stunnel.pem'
        verify: '2'
        chroot: '/var/lib/stunnel4/'
        user: 'stunnel4'
        group: 'stunnel4'
        pid_file: '/stunnel4.pid'
        ssl_options: 'NO_SSLv2'
        client: true
        retry: true
        foreground: false

replication::database::server::server_tunnels:
    'mysql':
        accept: '13306'
        connect: '3306'
        certificate: '/etc/stunnel/stunnel.pem'
        ca_file: '/etc/stunnel/stunnel.pem'
        verify: '2'
        chroot: '/var/lib/stunnel4/'
        user: 'stunnel4'
        group: 'stunnel4'
        pid_file: '/stunnel4.pid'
        ssl_options: 'NO_SSLv2'
        client: false
        foreground: false
```

### Filesystem replication

By default make sure /etc/stunnel/stunnel.pem exists and user stunnel4 exists...

It is possible to create a cron on the Filesystem master that will touch a file in each replicated folder, the point of this is to provide a file thats mtime is updated in a controlled way, this allows a monitoring system to check this file and depending on the mtime determine if replication is working as expected or not. An example of this is to use the Nagios check_file_age plugin.

The following variables control the "monitor cron"

`create_monitor_cron` - Flag to determine if the file touch cron should be created for each replicated directory, defaults to **`true`**

`monitor_cron_schedule` - The cron schedule for the touch cron, defaults to **`*/10 * * * *`**

`monitor_cron_user`  - The user that the touch cron should run as , defaults to **`root`**

`monitor_cron_cronfile` - The location of the touch cron job file, deafults to **`'/etc/cron.d/fs_replication_monitor'`**

`monitor_cron_file` - The file to be touched by the touch cron, relative to the replicated directory, defaults to **`replication.lock`**

#### Example usage

```
    
replication::filesystem::client::use_xinetd: true
replication::filesystem::client::rsync_opts: '--address=127.0.0.1'
replication::filesystem::client::address: '127.0.0.1'
replication::filesystem::client::modules:
  'opt':
    path: '/opt'  
    comment: 'Opt DR sync'
    read_only: 'no'
    list: 'yes'
    uid: 'root'
    gid: 'root'
  'opt-slow':
    path: '/opt-slow'
    comment: 'Opt-slow DR sync'
    read_only: 'no'
    list: 'yes'
    uid: 'root'
    gid: 'root'
replication::filesystem::client::create_folders:
  '/opt-slow':
    ensure: directory
    owner: 'root'
    group: 'root'
replication::filesystem::client::client_tunnels:
  'rsync':
    accept: '8873'
    connect: '873'
    certificate: '/etc/stunnel/stunnel.pem'
    ca_file: '/etc/stunnel/stunnel.pem'
    verify: '2'
    chroot: '/var/lib/stunnel4/'
    user: 'stunnel4'
    group: 'stunnel4'
    pid_file: '/stunnel4-rsync.pid'
    ssl_options: 'NO_SSLv2'
    client: false
    foreground: false
replication::filesystem::server::use_upstart: true
replication::filesystem::server::lsync_flush_config: false
replication::filesystem::server::inotify_watches: 40000
replication::filesystem::server::rsync_modules:
  'opt':
    type: 'rsync'
    source: '/opt'
    target: 'localhost::opt/'
    init_sync: false
    rsync_verbose: true
    rsync_archive: true
    rsync_hard_links: true
  'opt-slow':
    type: 'rsync'
    source: '/opt-slow'
    target: 'localhost::opt-slow/'
    init_sync: false
    rsync_verbose: 'true'
    rsync_archive: 'true'
    rsync_hard_links: 'true'
    exclude_from: '/etc/lsyncd/rsync.exclusions'

replication::filesystem::server::lsync_create_files:
 '/etc/lsyncd/rsync.exclusions':
   ensure: present
   owner: 'root'
   group: 'root'
   content: |
     temp/
     work/
     log/
     logs/
     home/index/
 '/opt-slow':
   ensure: directory
   owner: 'root'
   group: 'root'

replication::filesystem::server::server_tunnels:
  'rsync':
    accept: 'localhost:873'
    connect: 'avst-dr1.vagrant:8873'
    certificate: '/etc/stunnel/stunnel.pem'
    ca_file: '/etc/stunnel/stunnel.pem'
    verify: '2'
    chroot: '/var/lib/stunnel4/'
    user: 'stunnel4'
    group: 'stunnel4'
    pid_file: '/stunnel4-rsync.pid'
    ssl_options: 'NO_SSLv2'
    client: true
    foreground: false
    debug_level: 7
    retry: true

```

### Svn replication

Configures server post commit hook to notify client that will synchronoze commits missing on it. 

#### Example usage

```
replication::svn::server::sync_username: 'martin'
replication::svn::server::sync_password: 'password' #encrypt this, maybe change as it may it not secure enough
replication::svn::server::source_username: 'martin'
replication::svn::server::source_password: 'password' #encrypt this, maybe change as it may it not secure enough
replication::svn::server::repo_location: '/tmp/repo'
replication::svn::server::target_url: 'file:///tmp/repo_backup'

replication::svn::client::server_url: 'file:///tmp/repo'
replication::svn::client::client_url: 'file:///tmp/repo_backup'
replication::svn::client::server_user: 'martin'
replication::svn::client::server_password: 'password' #encrypt this, maybe change as it may it not secure enough
replication::svn::client::local_user: 'martin'
replication::svn::client::local_password: 'password' #encrypt this, maybe change as it may it not secure enough
replication::svn::client::client_hooks_path: '/tmp/repo_backup/hooks'

```

## Module Dependencies

- 'duritong//subversion'
- 'adaptavist/stunnel_config'
- 'adaptavist/lsyncd'
- 'adaptavist/rsync_config'
- 'puppetlabs/rsync'

### Classes and defined types

#### Class: Replication::database::server

#### Class: Replication::database::client

#### Class: Replication::filesystem::server

#### Class: Replication::filesystem::client

#### Class: Replication::svn::server

#### Class: Replication::svn::client

### Examples

See above for usage per required replication type

## Reference

### Classes

#### Public classes

All above

#### Private classes

### Defined types

#### Public defined types

#### Private defined types

### Templates

- svn_client_replication.sh.erb  - sets properties on client to act as slave and replicate commits from server
- svn_post_commit_hook.erb - notifies client about the commit
- svn_pre-revprop-change.erb - enable changing of svn properties
- sync_db.sh.erb - creates initial db dump from server, apply it to client and sets up client as db slave and to continue replication from the last position in dump.

## Limitations

* Module is not specific to OS.

## Development

### Contributing

* Create branch, name it according to functionality you are developing. Prefix with feature or bug, so the branch name looks like feature/<name_of_feature>

* Make changes and commit functionality to branch. Do not forget to write/adjust tests

* Create pull request, add reviewers

* Once approved, merge with master

### Running tests

Tests are located in spec folder. Subfolders classes and defines separates types of objects tested. Make sure .fixtures.yml contains all dependent modules to run tests. Functionality in all classes and defines has to be tested for all supported OS and cases of use. 

To run tests:
```
gem install bundler
bundle install
bundle exec rake spec
```
