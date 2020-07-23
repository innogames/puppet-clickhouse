[![Build Status](https://travis-ci.org/innogames/puppet-clickhouse.svg?branch=master)](https://travis-ci.org/innogames/puppet-clickhouse)
# Description
This module provides an easy way to install and configure ClickHouse DBMS. The easiest way to do the magic is:
```puppet
class { 'clickhouse':
  server      => true,
  manage_repo => true,
}
```

# Setup
The module depends on `xml-simple` gem. It allows to use `clickhouse::server::config` and `clickhouse::client::config` to manage configuration with puppet Hash. To install it execute the next command on your puppet server:
```bash
sudo puppetserver gem install xml-simple
```

# Usage
See the [examples](./REFERENCE.md#examples)

# Reference

**Classes**

* [`clickhouse`](./REFERENCE.md#clickhouse): this class allows you to install ClickHouse DB's repo, client and server
* [`clickhouse::client`](./REFERENCE.md#clickhouseclient): ClickHouse client class
* [`clickhouse::repo`](./REFERENCE.md#clickhouserepo): installs repository with ClickHouse DBMS
* [`clickhouse::server`](./REFERENCE.md#clickhouseserver): ClickHouse server class
* [`clickhouse::server::config::memory`](./REFERENCE.md#clickhouseserverconfigmemory): Configure memory consumption
* [`clickhouse::server::config::zookeeper`](./REFERENCE.md#clickhouseserverconfigzookeeper): Set proper zookeeper config

**Defined types**

* [`clickhouse::client::config`](./REFERENCE.md#clickhouseclientconfig): generates xml config from hash via ruby xml-simple
* [`clickhouse::error`](./REFERENCE.md#clickhouseerror): Implements error logging with continue of manifests application
* [`clickhouse::server::config`](./REFERENCE.md#clickhouseserverconfig): generates xml config from hash via ruby xml-simple
* [`clickhouse::server::config::profile`](./REFERENCE.md#clickhouseserverconfigprofile): Define ClickHouse profile
* [`clickhouse::server::config::user`](./REFERENCE.md#clickhouseserverconfiguser): Define ClickHouse users

**Resource types**

* [`clickhouse_database`](./REFERENCE.md#clickhouse_database): Manages databases on ClickHouse server

# Limitations
ClickHouse does work only on UNIX-like OS. Theoretically possible to use this module on FreeBSD and Mac OS but should be checked additionally. Feel free to test and open an issue/PR.

The current state of module was tested with Centos 7, Ubuntu 18.04 and Debian 9.

# Development
Fork this project, develop, make pull request and wait for corresponding auto tests will be done.
