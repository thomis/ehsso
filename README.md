[![Gem Version](https://badge.fury.io/rb/ehsso.svg)](https://badge.fury.io/rb/ehsso)
[![01 - Test](https://github.com/thomis/ehsso/actions/workflows/01_test.yml/badge.svg)](https://github.com/thomis/ehsso/actions/workflows/01_test.yml)
[![02 - Release](https://github.com/thomis/ehsso/actions/workflows/02_release.yml/badge.svg)](https://github.com/thomis/ehsso/actions/workflows/02_release.yml)

# ehsso

A Rails authorization gem that integrates with company-specific Single Sign-On (SSO) infrastructure. It extracts user identity from HTTP request headers and queries a configured authorization service to retrieve user roles for your application.

## How it works

1. **Identity Extraction**: Reads user information from specific HTTP headers injected by your SSO infrastructure
2. **Authorization Query**: Sends the user identity along with your application's module key to a central authorization service
3. **Role Management**: Receives and manages user roles specific to your application/module
4. **Access Control**: Provides simple role-checking methods for implementing authorization logic in your Rails app

This gem handles the authorization aspect of SSO - determining what an already authenticated user is allowed to do in your specific application based on their assigned roles.

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

  # Authorization service endpoint with HTTP Basic Auth
  config.base_url   = 'http://{host}:{port}'
  config.username_and_password = 'username:password'
end
```

## Usage

The authorization service typically returns roles like:
- **ADMINISTRATOR** - Full system access
- **OPERATOR** - Manage and modify resources  
- **USER** - Standard access, read-only
- **GUEST** - Limited access, pending approval

Note: The actual roles returned depend on your authorization service configuration. The gem dynamically handles any role names returned by the service.

### Basic Controller Integration

```ruby
class ApplicationController < ActionController::Base
  before_action :authorize_user

  private

  def authorize_user
    @current_user = Ehsso::Person.parse_from_request_header(request.headers)
    
    if @current_user.valid?
      @current_user.fetch  # Retrieve roles from authorization service
      
      unless @current_user.valid?
        render plain: 'Authorization service unavailable', status: :service_unavailable
      end
    else
      render plain: 'Unauthorized', status: :unauthorized
    end
  end
  
  def current_user
    @current_user
  end
end
```

### Role-Based Access Control

```ruby
class AdminController < ApplicationController
  before_action :require_admin

  def dashboard
    # Administrator-only content
  end

  private

  def require_admin
    unless @current_user.administrator?
      render plain: 'Access denied', status: :forbidden
    end
  end
end

class ResourcesController < ApplicationController
  def index
    # All authenticated users can view (even guests)
    @resources = Resource.all
  end

  def show
    # Users, operators, and administrators can view details
    if @current_user.user? || @current_user.operator? || @current_user.administrator?
      @resource = Resource.find(params[:id])
    else
      render plain: 'Guest access limited', status: :forbidden
    end
  end

  def edit
    # Operators and administrators can edit
    if @current_user.operator? || @current_user.administrator?
      @resource = Resource.find(params[:id])
    else
      render plain: 'Access denied', status: :forbidden
    end
  end

  def destroy
    # Only administrators can delete
    if @current_user.administrator?
      @resource = Resource.find(params[:id])
      @resource.destroy
      redirect_to resources_path
    else
      render plain: 'Access denied - Administrator only', status: :forbidden
    end
  end
end
```

### Auto-Registration for New Users

```ruby
class ApplicationController < ActionController::Base
  before_action :authorize_or_register_user

  private

  def authorize_or_register_user
    @current_user = Ehsso::Person.parse_from_request_header(request.headers)
    
    if @current_user.valid?
      # This will create user with 'GUEST' role if they don't exist yet
      @current_user.fetch_or_create
      
      if @current_user.guest?
        redirect_to pending_approval_path
      elsif @current_user.user? || @current_user.operator? || @current_user.administrator?
        # User has been granted proper access
        return true
      end
    else
      render plain: 'Missing SSO headers', status: :unauthorized
    end
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/thomis/ehsso.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
