[![Gem Version](https://badge.fury.io/rb/ehsso.svg)](https://badge.fury.io/rb/ehsso)
[![Code Climate](https://codeclimate.com/github/thomis/ehsso/badges/gpa.svg)](https://codeclimate.com/github/thomis/ehsso)
[![Dependency Status](https://gemnasium.com/badges/github.com/thomis/ehsso.svg)](https://gemnasium.com/github.com/thomis/ehsso)

# ehsso

Company specific Single Sign On for Rails applications.

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
