[![Gem Version](https://badge.fury.io/rb/ehsso.svg)](https://badge.fury.io/rb/ehsso)
[![Maintainability](https://api.codeclimate.com/v1/badges/baea493e227c446ffe49/maintainability)](https://codeclimate.com/github/thomis/ehsso/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/baea493e227c446ffe49/test_coverage)](https://codeclimate.com/github/thomis/ehsso/test_coverage)
[![ci](https://github.com/thomis/ehsso/actions/workflows/ci.yml/badge.svg)](https://github.com/thomis/ehsso/actions/workflows/ci.yml)

# ehsso

Company specific Single Sign On for Rails applications.

## Supported Ruby Versions

Currently supported and tested ruby versions are:

- 3.2
- 3.1
- 3.0
- 2.7
- 2.6

## Installation

Simply add ehsso to your Gemfile and bundle it up.

```Ruby
gem 'ehsso'
```

## Configuration

Configure ehsso with an initializer.

```Ruby
Ehsso.configure do |config|
  # Application reference
  config.module_key = 'my_module_key'

  # Service Endpoint
  config.base_url   = 'http://{host}:{port}'
  config.username_and_password = 'username:password'
end
```

## Usage

to do....

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/thomis/ehsso.
