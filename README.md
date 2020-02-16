# maeq-thanos

[![Build Status Travis](https://img.shields.io/travis/com/syberalexis/puppet-thanos/master?label=build%20travis)](https://travis-ci.com/syberalexis/puppet-thanos)
[![Build Status AppVeyor](https://img.shields.io/appveyor/ci/syberalexis/puppet-thanos/master?label=build%20appveyor)](https://ci.appveyor.com/project/syberalexis/puppet-thanos)
[![Puppet Forge](https://img.shields.io/puppetforge/v/maeq/thanos.svg)](https://forge.puppetlabs.com/maeq/thanos)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/maeq/thanos.svg)](https://forge.puppetlabs.com/maeq/thanos)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/maeq/thanos.svg)](https://forge.puppetlabs.com/maeq/thanos)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/maeq/thanos.svg)](https://forge.puppetlabs.com/maeq/thanos)
[![Apache-2 License](https://img.shields.io/github/license/syberalexis/puppet-thanos.svg)](LICENSE)


#### Table of Contents

1. [Description](#description)
2. [Usage](#usage)
3. [Limitations](#limitations)
4. [Development](#development)

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

#### Puppet
```puppet
    class { 'thanos':
      version        => '0.10.1',
      manage_sidecar => true,
    }
```
OR
```puppet
    class { 'thanos':
      version => '0.10.1'
    }
    class { 'thanos-sidecar':
      bin_path => '/usr/local/bin/thanos',
    }
```

#### Hiera Data
```puppet
    include thanos
```
```yaml
    thanos::manage_sidecar: true
```
OR
```puppet
    include thanos
    include thanos::sidecar
```
```yaml
    thanos::version: '0.10.1'
    thanos::bin_path: '/usr/local/bin/thanos'
```

### Thanos Query

#### Puppet
```puppet
    class { 'thanos-query':
      bin_path => '/usr/local/bin/thanos',
      stores   => [
        'sidecar:10901',
        'store:10901',
      ]
    }
```

#### Hiera Data
```puppet
    include thanos
```
```yaml
    thanos::manage_query: true
    thanos::query::stores:
      - 'sidecar:10901'
      - 'store:10901'
```

### Thanos Rule

#### Puppet
```puppet
    class { 'thanos-rule':
      bin_path => '/usr/local/bin/thanos',
      queries  => [
        'query:10901',
      ]
    }
```

#### Hiera Data
```puppet
    include thanos
```
```yaml
    thanos::manage_rule: true
    thanos::rule::queries:
      - 'query:10901'
```

### Thanos Store

#### Puppet
```puppet
    class { 'thanos-store':
      bin_path             => '/usr/local/bin/thanos',
      objstore_config_file => '/etc/thanos/storage.yaml',
    }
```

#### Hiera Data
```puppet
    include thanos
```
```yaml
    thanos::manage_store: true
```

### Thanos Compact

#### Puppet
```puppet
    class { 'thanos-compact':
      bin_path             => '/usr/local/bin/thanos',
      objstore_config_file => '/etc/thanos/storage.yaml',
    }
```

#### Hiera Data
```puppet
    include thanos
```
```yaml
    thanos::manage_compact: true
```

### Thanos Downsample

#### Puppet
```puppet
    class { 'thanos-downsample':
      bin_path             => '/usr/local/bin/thanos',
      objstore_config_file => '/etc/thanos/storage.yaml',
    }
```

#### Hiera Data
```puppet
    include thanos
```
```yaml
    thanos::manage_downsample: true
```

### Manage Storage config

For more configuration information see [Thasos Storage configuration page](https://thanos.io/storage.md/#configuration).

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

For more configuration information see [Thasos Tracing configuration page](https://thanos.io/tracing.md/#configuration).

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
