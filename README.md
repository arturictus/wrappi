# Wrappi

Framework to create API clients.
The intention is to bring the best practices and standarize the mess it's currently happening with the API clients.
It allows to create API clients in a declarative way improving readability and unifying the behavior.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wrappi'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wrappi

## Usage

__Github example:__

```ruby
module Github
  class Client < Wrappi::Client
    setup do |config|
      config.domain = 'https://api.github.com'
      config.headers = {
        'Content-Type' => 'application/json',
        'Accept' => 'application/vnd.github.v3+json',
      }
    end
  end

  class User < Wrappi::Endpoint
    client Client
    verb :get
    path "users/:username"
  end
end
```

```ruby
user = Github::User.new(username: 'arturictus')
user.success?
# => true
user.code
# => 200
user.body
# => {"login"=>"arturictus", "id"=>1930175, ...}
```

### Client

Is the main configuration for your service.

It holds the common configuration for all the endpoints (`Wrappi::Endpoint`).

Required:

  - `domain`: Yep, you know.
    ```ruby
    config.domain = 'https://api.github.com'
    ```

Optionals:

  - `params`: Set global params for all the `Endpoints`.
    This is a great place to put the `api_key`.
    ```ruby
    config.params = { "api_key" => "asdfasdfoerkwlejrwer" }
    ```
    default: `{}`

  - `logger`: Set your logger.
    ```ruby
    config.logger = Rails.logger
    ```
    default: `Logger.new(STDOUT)`

  - `headers`: Headers for all the endpoints. Format, Authentication.
    ```ruby
    config.headers = {
      "Content-Type" => "application/json",
      "Accept' => 'application/json",
      "Auth-Token" => "verysecret"
    }
    ```
    default:
    ```ruby
    { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    ```

  - `ssl_context`: If you need to set an ssl_context.
     ```ruby
     config.ssl_context = OpenSSL::SSL::SSLContext.new.tap do |ctx|
                            ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
                          end
     ```
     default: `nil`

  - `use_ssl_context`: It has to be set to `true` for using the `ssl_context`

     default: `false`

### Endpoint

Required:
  - `client`: `Wrappi::Client` `class`
  - `path`: The path.

    TODO
  - `verb`:
    - `:get`
    - `:post`
    - `:delete`
    - `:put`

    default: `:get`

Optional:

  - `default_params`:

    default: `{}`
  - `headers`:

    default: `proc { client.headers }`

  - `basic_auth`:

    default: `nil`
  - `follow_redirects`:

    default: `true`
  - `body_type`:

    default: `:json`

## Development

After checking out the repo, run `bin/setup` to install dependencies.

Run test:
```
bin/dev_server
```
This will run a rails server. The test are running agains it.

```
bundle exec rspec
```

You can also run `bin/console` for an interactive prompt that will allow you to experiment.



## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/arturictus/wrappi. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
