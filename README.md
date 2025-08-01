[![Gem Version](https://badge.fury.io/rb/ehsso.svg)](https://badge.fury.io/rb/ehsso)
[![ci](https://github.com/thomis/ehsso/actions/workflows/ci.yml/badge.svg)](https://github.com/thomis/ehsso/actions/workflows/ci.yml)

# ehsso

Company specific Single Sign On for Rails applications.

## Supported Ruby Versions

Currently supported and tested ruby versions are:

- 3.4 (EOL 31 Mar 2028)
- 3.3 (EOL 31 Mar 2027)
- 3.2 (EOL 31 Mar 2026)

Ruby versions not tested anymore:

- 3.1 (EOL 31 Mar 2025)

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
