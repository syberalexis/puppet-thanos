# maeq-thanos

[![Build Status Travis](https://img.shields.io/travis/com/syberalexis/puppet-thanos/master?label=build%20travis)](https://travis-ci.com/syberalexis/puppet-thanos)
[![Build Status AppVeyor](https://img.shields.io/appveyor/ci/syberalexis/puppet-thanos/master?label=build%20appveyor)](https://ci.appveyor.com/project/syberalexis/puppet-thanos)
[![Puppet Forge](https://img.shields.io/puppetforge/v/maeq/thanos.svg)](https://forge.puppetlabs.com/maeq/thanos)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/maeq/thanos.svg)](https://forge.puppetlabs.com/maeq/thanos)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/maeq/thanos.svg)](https://forge.puppetlabs.com/maeq/thanos)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/maeq/thanos.svg)](https://forge.puppetlabs.com/maeq/thanos)
[![Apache-2 License](https://img.shields.io/github/license/syberalexis/puppet-thanos.svg)](LICENSE)


#### Table of Contents

- [Description](#description)
- [Usage](#usage)
- [Examples](#examples)
- [Limitations](#limitations)
- [Development](#development)

## Description

This module automates the install of [Thanos](https://github.com/thanos-io/thanos) and it's components into a service.  

## Usage

For more information see [REFERENCE.md](REFERENCE.md).

### Install Thanos

#### Puppet
```puppet
class { 'thanos':
  version => '0.10.1'
}
```

#### Hiera Data
```puppet
include thanos
```
```yaml
thanos::version: '0.10.1'
```

### Thanos Sidecar

```yaml
thanos::manage_sidecar: true
```

### Thanos Query
```yaml
thanos::manage_query: true
thanos::query::stores:
  - 'sidecar:10901'
  - 'store:10901'
```

### Thanos Rule
```yaml
thanos::manage_rule: true
thanos::rule::queries:
  - 'query:10901'
```

### Thanos Store
```yaml
thanos::manage_store: true
```

### Thanos Compact
```yaml
thanos::manage_compact: true
```

### Thanos Downsample
```yaml
thanos::manage_downsample: true
```

### Thanos Bucket Web
```yaml
thanos::manage_bucket_web: true
```

### Manage Storage config

For more configuration information see [Thanos Storage configuration page](https://thanos.io/storage.md/#configuration).

#### Puppet
```puppet
thanos::storage { '/etc/thanos/storage.yaml':
  ensure => 'present',
  type   => 'FILESYSTEM',
  config => {
    directory => '/data'
  }
}
```

### Yaml
```puppet
include thanos
```
```yaml
thanos::manage_storage_config: true
thanos::storage_config_file: '/etc/thanos/storage.yaml'
thanos::storage_config:
  ensure: 'present'
  type: 'FILESYSTEM'
  config:
    directory: '/data'
```

### Manage Tracing config

For more configuration information see [Thanos Tracing configuration page](https://thanos.io/tracing.md/#configuration).

#### Puppet
```puppet
thanos::tracing { '/etc/thanos/tracing.yaml':
  ensure => 'present',
  type   => 'JAEGER',
  config => {
    service_name              => '',
    disabled                  => false,
    rpc_metrics               => false,
    tags                      => '',
    sampler_type              => '',
    sampler_param             => 0,
    sampler_manager_host_port => '',
    sampler_max_operations    => 0,
    sampler_refresh_interval  => '0s',
    reporter_max_queue_size   => 0,
    reporter_flush_interval   => '0s',
    reporter_log_spans        => false,
    endpoint                  => '',
    user                      => '',
    password                  => '',
    agent_host                => '',
    agent_port                => 0,
  }
}
```

### Yaml
```puppet
include thanos
```
```yaml
thanos::manage_tracing_config: true
thanos::tracing_config_file: '/etc/thanos/tracing.yaml'
thanos::tracing_config:
  ensure: 'present'
  type: 'JAEGER'
  config:
    service_name: ''
    disabled: false
    rpc_metrics: false
    tags: ''
    sampler_type: ''
    sampler_param: 0
    sampler_manager_host_port: ''
    sampler_max_operations: 0
    sampler_refresh_interval: '0s'
    reporter_max_queue_size: 0
    reporter_flush_interval: '0s'
    reporter_log_spans: false
    endpoint: ''
    user: ''
    password: ''
    agent_host: ''
    agent_port: 0
```

## Examples

### Install from other source

```yaml
thanos::base_url: 'http://my_private_dropbox/thanos'
```
Or
```yaml
thanos::download_url: 'http://my_private_dropbox/thanos/thanos-0.10.1.tar.gz'
```

### Install all in one

It's not a very good idea to deploy like this in Production. But it's possible to test it on the same machine.

```yaml
thanos:manage_sidecar: true
thanos:manage_query: true
thanos:manage_rule: true
thanos:manage_store: true
thanos:manage_compact: true

thanos::sidecar::http_address: '0.0.0.0:10902'
thanos::sidecar::grpc_address: '0.0.0.0:10901'
thanos::sidecar::objstore_config_file: '/etc/thanos/storage.yaml'
thanos::query::http_address: '0.0.0.0:10904'
thanos::query::grpc_address: '0.0.0.0:10903'
thanos::query::stores:
  - 'localhost:10901'
  - 'localhost:10907'
thanos::rule::http_address: '0.0.0.0:10906'
thanos::rule::grpc_address: '0.0.0.0:10905'
thanos::rule::queries:
  - 'localhost:10903'
thanos::store::http_address: '0.0.0.0:10908'
thanos::store::grpc_address: '0.0.0.0:10907'
thanos::compact::http_address: '0.0.0.0:10910'
thanos::compact::grpc_address: '0.0.0.0:10909'

thanos::manage_storage_config: true
thanos::storage_config_file: '/etc/thanos/storage.yaml'
thanos::storage_config:
  ensure: 'present'
  type: 'FILESYSTEM'
  config:
    directory: '/data'
```

### Sidecar with Prometheus

I recommend to use the module [puppet-prometheus](https://forge.puppet.com/puppet/prometheus), it is very easy to use.
```puppet
include prometheus
include thanos
```
```yaml
prometheus::manage_prometheus_server: true
prometheus::config_dir: '/etc/prometheus'
prometheus::configname: 'prometheus.yaml'
prometheus::localstorage: '/data/prometheus'
prometheus::extra_options: '--web.enable-lifecycle --storage.tsdb.min-block-duration=2h --storage.tsdb.max-block-duration=2h'

thanos::manage_sidecar: true
thanos::tsdb_path: '/data/prometheus'
thanos::reloader_config_file: '/etc/prometheus/prometheus.yaml'
```

## Limitations

Don't manage Thanos experimental features, like :
- `thanos receive` command

Only support, Thanos supported OS. See [Thanos releases page](https://github.com/thanos-io/thanos/releases)

## Development

This project contains tests for [rspec-puppet](http://rspec-puppet.com/).

Quickstart to run all linter and unit tests:
```bash
bundle install --path .vendor/
bundle exec rake test
```
