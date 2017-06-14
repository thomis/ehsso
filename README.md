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
  config.base_uri   = "http://{host}:{port}"
end
```

## Usage

to do....
