# Contributing

## Report an issue or a feature proposal
To submit an issue or a feature, please fill as possible the template.

## Contribute
To contribute to a Puppet module project, please read the [Contributing to Puppet modules guide](https://puppet.com/docs/puppet/latest/contributing.html).  

## Tests
This project contains tests for [rspec-puppet](http://rspec-puppet.com/).

Quickstart to run all linter and unit tests:
```bash
bundle install --path .vendor/
bundle exec rake test
```
Or
```bash
pdk validate
pdk test unit
```

## Pull Request
It is very much appreciated to check your Puppet manifest with [puppet-lint](http://puppet-lint.com/) to follow the recommended Puppet style guidelines from the [Puppet Labs style guide](https://puppet.com/docs/puppet/latest/style_guide.html).  
Please run [tests](#tests) before, to don't break the CI.
