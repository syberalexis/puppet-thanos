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

### Install Thanos

#### In Puppet Code
```puppet
    class { 'thanos':
      version => '0.10.0'
    }
```

#### In Hiera Data (yaml)
```puppet
    include thanos
```
```yaml
    thanos::version: '0.10.0'
```

#### Full installation services
```yaml
    thanos::version: '0.10.0'
    thanos::manage_sidecar: true
    thanos::manage_query: true
    thanos::manage_rule: true
    thanos::manage_store: true
    thanos::manage_compact: true
    thanos::manage_downsample: true
```

For more information see [REFERENCE.md](REFERENCE.md).

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
