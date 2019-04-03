[![Build Status](https://travis-ci.org/arturictus/wrappi.svg?branch=master)](https://travis-ci.org/arturictus/wrappi)
[![Maintainability](https://api.codeclimate.com/v1/badges/8751a0b6523a52b5e23e/maintainability)](https://codeclimate.com/github/arturictus/wrappi/maintainability)
[![Coverage Status](https://coveralls.io/repos/github/arturictus/wrappi/badge.svg?branch=master)](https://coveralls.io/github/arturictus/wrappi?branch=master)

# Wrappi
Making APIs fun again!

Wrappi is a Framework to create API clients. The intention is to bring the best practices and standardize how API clients behave.
It allows to create API clients in a declarative way improving readability and unifying the behavior. It abstracts complex operations like caching, retries background requests and error handling.

Enjoy!

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
module GithubAPI
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
user = GithubAPI::User.new(username: 'arturictus')
user.success? # => true
user.error? # => false
user.status_code # => 200
user.body # => {"login"=>"arturictus", "id"=>1930175, ...}
```

#### Async
Wrappi comes with a background Job out of the box. If you are in a Rails app the `#async`
method will queue a new job (`< ActiveJob::Base`) that will make the request and trigger the async callback
after the request is made.

example:

```ruby
class User < Wrappi::Endpoint
  client Client
  verb :get
  path "users/:username"
  async_callback do |opts|
    # this will be called in background after the request is made
    if success?
      if opts[:create]
        CreateUserService.call(body)
      elsif opts[:update]
        UpdateUserService.call(body)
      end
    end
  end
end
# This will execute the request in a background job
Github::User.new(username: 'arturictus').async(create: true)
```

If you need to send options to your Job (the `::set` method) you can pass the key `set`
to the options.

```ruby
Github::User.new(username: 'arturictus').async(create: true, set: { wait: 10.minutes })
```

#### Cache
You can enable cache per endpoint.

Set the cache Handler in your client.
It must behave like `Rails.cache` and respond to:
  - `read([key])`
  - `write([key, value, options])`

```ruby
class Client < Wrappi::Client
  setup do |config|
    config.domain = 'https://api.github.com'
    config.cache = Rails.cache
  end
end
```

Enable cache in your endpoint.
```ruby
class User < Wrappi::Endpoint
  cache true # enable for endpoint
  client Client
  verb :get
  path "users/:username"
end

user = User.new(username: 'arturictus')
user.response.class # => Wrappi::Response
user.flush
user.response.class # => Wrappi::CachedResponse
user.success? # => true
user.body # => {"login"=>"arturictus", "id"=>1930175, ...}
```

When cached the response will be a `Wrappi::CachedResponse`. `Wrappi::CachedResponse` behaves
like `Wrappi::Response` that means you can use the endpoint in the same way as it was a non cached.
See `cache_options` to fine tune your cache with expiration and other cache options.

You can use options to cache a single request.

```ruby
class User < Wrappi::Endpoint
  client Client
  verb :get
  path "users/:username"
end
User.new({username: 'arturictus'}, cache: true)
user.response.class # => Wrappi::Response
user.flush
user.response.class # => Wrappi::CachedResponse
user.success? # => true
user.body # => {"login"=>"arturictus", "id"=>1930175, ...}
```

#### Retry
Sometimes you want to retry if certain conditions affected your request.

This will retry if status code is not `200`

```ruby
  class User < Wrappi::Endpoint
    client Client
    verb :get
    path "users/:username"
    retry_if do |response, endpoint|
      endpoint.status_code != 200
    end
  end
```

Check more configuration options and examples for `retry_if` and `retry_options` below.

#### Flexibility

__options:__

Pass a second argument with options.
```ruby
params = { username: 'arturictus' }
options = { options_in_my_instance: "yeah!" }

User.new(params, options)
```

__Dynamic configurations:__

All the configs in `Endpoint` are evaluated at instance level except: `around_request` and `retry_if` because of their nature.
That allows you to fine tune the configuration at a instance level.

example:

Right now the default for `cache` config is: `proc { options[:cache] }`.

```ruby
  class User < Wrappi::Endpoint
    client Client
    verb :get
    path "users/:username"
    cache do
      if input_params[:username] == 'arturictus'
        false
      else
        options[:cache]          
      end
    end
  end
```



__endpoint is a ruby class:__ :open_mouth:

```ruby
  class User < Wrappi::Endpoint
    client Client
    verb :get
    path "users/:username"
    cache do
      cache?
    end

    def cache?
      if input_params[:username] == 'arturictus'
        false
      else
        options[:cache]          
      end
    end

    def parsed_response
      @parsed_response ||= MyParser.new(body)
    end
  end
```

__inheritance:__
All the configs will be inherited

```ruby
class UserDetail < User
  path "users/:username/detail"
end
```

### Configurations

#### Client

| Name            | Type                     | Default                                                                  | Required |
|-----------------|--------------------------|--------------------------------------------------------------------------|----------|
| domain          | String                   |                                                                          | *        |
| params          | Hash                     |                                                                          |          |
| headers         | Hash                     | { 'Content-Type' => 'application/json', 'Accept' => 'application/json' } |          |
| async_handler   | const                    | Wrappi::AsyncHandler                                                     |          |
| cache           | const                    |                                                                          |          |
| logger          | Logger                   | Logger.new(STDOUT)                                                       |          |
| timeout         | Hash                     | { write: 9, connect: 9, read: 9 }                                        |          |
| use_ssl_context | Boolean                  | false                                                                    |          |
| ssl_context     | OpenSSL::SSL::SSLContext |                                                                          |          |
| basic_auth      | Hash (keys: user, pass) `or` block -> Hash |                                                        |          |

#### Endpoint

| Name             | Type                                       | Default                 | Required |
|------------------|--------------------------------------------|-------------------------|----------|
| client           | Wrappi::Client                             |                         | *        |
| path             | String                                     |                         | *        |
| verb             | Symbol                                     | :get                    | *        |
| default_params   | Hash `or` block -> Hash                    | {}                      |          |
| headers          | Hash `or` block -> Hash                    | proc { client.headers } |          |
| basic_auth       | Hash (keys: user, pass) `or` block -> Hash | proc { client.basic_auth } |          |
| follow_redirects | Boolean `or` block -> Boolean              | true                    |          |
| body_type        | Symbol, one of: :json,:form,:body          | :json                   |          |
| cache            | Boolean `or` block -> Boolean              | proc { options[:cache] }|          |
| cache_options    | Hash `or` block -> Hash                    |                         |          |
| retry_if         | block                                      |                         |          |
| retry_options    | Hash `or` block -> Hash                    |                         |          |
| around_request   | block                                      |                         |          |
| async_callback   | block                                      |                         |          |

### Client

Is the main configuration for your service.

It holds the common configuration for all the endpoints (`Wrappi::Endpoint`).

#### Required:

  - __domain:__ Yep, you know.
    ```ruby
    config.domain = 'https://api.github.com'
    ```

#### Optionals:

  - __params:__ Set global params for all the `Endpoints`.
    This is a great place to put the `api_key`.
    ```ruby
    config.params = { "api_key" => "asdfasdfoerkwlejrwer" }
    ```
    default: `{}`

  - __logger:__ Set your logger.

    default: `Logger.new(STDOUT)`
    ```ruby
    config.logger = Rails.logger
    ```

  - __headers:__ Headers for all the endpoints. Format, Authentication.

    default:
    ```ruby
    { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    ```
    ```ruby
    config.headers = {
      "Content-Type" => "application/json",
      "Accept' => 'application/json",
      "Auth-Token" => "verysecret"
    }
    ```
  - __async_handler:__ If you are not in Rails app or you have another background mechanism in place
    you can configure here how the requests will be send to the background.
    When `#async` is called on an Endpoint instance the `async_handler` const will be called with:
    current endpoint instance (`self`) and the options passed to the async method.
    ```ruby
    class MyAsyncHandler
      def self.call(endpoint, opts)
        # send to background
      end
    end
    class Client < Wrappi::Client
      setup do |config|
        config.domain = 'https://api.github.com'
        config.async_handler = MyAsyncHandler
      end
    end
    endpoint_inst.async(this_opts_are_for_the_handler: true)
    ```

  - __timeout:__ Set your specific timout. When you set timeout it will be merged with defaults.

    default: `{ write: 9, connect: 9, read: 9 }`

    ```ruby
      class Client < Wrappi::Client
        setup do |config|
          config.domain = 'https://api.github.com'
          config.timeout = { read: 3 }
        end
      end
      Client.timeout # => { write: 9, connect: 9, read: 3 }
    ```

  - __use_ssl_context:__ It has to be set to `true` for using the `ssl_context`

     default: `false`

  - __ssl_context:__ If you need to set an ssl_context.

     default: `nil`
     ```ruby
     config.ssl_context = OpenSSL::SSL::SSLContext.new.tap do |ctx|
                            ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
                          end
     ```

### Endpoint

#### Required:
  - __client:__ `Wrappi::Client` `class`
    ```ruby
      client MyClient
    ```

  - __path:__ The path to the resource.
    You can use doted notation and they will be interpolated with the params

    ```ruby
      class MyEndpoint < Wrappi::Endpoint
        client MyClient
        verb :get
        path "/users/:id"
      end
      endpoint = MyEndpoint.new(id: "the_id", other: "foo")
      endpoint.url_with_params #=> "http://domain.com/users/the_id?other=foo"
      endpoint.url #=> "http://domain.com/users/the_id"
      endpoint.consummated_params #=> {"other"=>"foo"}
    ```
    Notice how interpolated params are removed from the query or the body

  - __verb:__

    default: `:get`
    - `:get`
    - `:post`
    - `:delete`
    - `:put`


#### Optional:

  - __default_params:__ Default params for the request. This params will be added
    to all the instances unless you override them.

    default: `{}`

    ```ruby
    class MyEndpoint < Wrappi::Endpoint
      client MyClient
      verb :get
      path "/users/:id"
      default_params do
        { other: "bar", foo: "foo" }
      end
    end
    endpoint = MyEndpoint.new(id: "the_id", other: "foo")
    endpoint.consummated_params #=> {"other"=>"foo","foo" => "foo" }
    ```

  - __headers:__ You can modify the client headers here. Notice that if you want
    to use the client headers as well you will have to merge them.

    default: `proc { client.headers }`
    ```ruby
    class MyEndpoint < Wrappi::Endpoint
      client MyClient
      verb :get
      path "/users"
      headers do
        client.headers #=> { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
        client.headers.merge('Agent' => 'wrappi')
      end
    end
    endpoint = MyEndpoint.new()
    endpoint.headers #=> { 'Agent' => 'wrappi', 'Content-Type' => 'application/json', 'Accept' => 'application/json'}
    ```

  - __basic_auth:__ If your endpoint requires basic_auth here is the place. keys
    have to be: `user` and `pass`.

    default: `nil`
    ```ruby
      basic_auth do
        { user: 'wrappi', pass: 'secret'}
      end
    ```

  - __follow_redirects:__ If the request responds with a redirection it will follow them.

    default: `true`

  - __body_type:__ Body type.

    default: `:json`

    - :json
    - :form
    - :body (Binary data)

  - __async_callback:__ When request is executed in the background with `#async(opts = {})` this
    callback will be called with this opts as and argument in the block.
    The block is executed in the endpoint instance. You can access to all the methods in Endpoint.

    default: `proc {}`

    ```ruby
    async_callback do |opts|
      if success?
        MyCreationService.call(body) if opts[:create]
      end
    end
    MyEndpoint.new().async(create: true)
    ```

#### Flow Control:

  This configs allows you fine tune your request adding middleware, retries and cache.
  The are executed in this nested stack:
  ```
    cache
      |- retry
        |- around_request
  ```
  Check [specs](/blob/master/spec/wrappi/executer_spec.rb) for more examples.

  - __cache:__ Cache the request if successful.

    default: `proc { options[:cache] }`
  - __cache_options:__ Options for the `cache` to receive on `write`
   ```ruby
     cache_options expires_in: 12, another_opt: true
   ```

   default: `{}`
  - __retry_if:__ Block to evaluate if request has to be retried. In the block are
    yielded `Response` and `Endpoint` instances. If the block returns `true` the request will be retried.
    ```ruby
      retry_if do |response, endpoint|
        endpoint.class #=> MyEndpoint
        response.error? # => true or false
      end
    ```

    Use case:

    We have a service that returns an aggregation of hotels available to book for a city. The service will start the aggregation in the background and will return `200` if the aggregation is completed if the aggregation is not completed will return `201` making us know that we should call again to retrieve all the data. This behavior only occurs if we pass the param: `onlyIfComplete`.

    ```ruby
      retry_if do |response, endpoint|
        endpoint.consummated_params["onlyIfComplete"] &&
          response.status_code == 201
      end
    ```
    Notice that this block will never be executed if an error occur (like timeouts). For retrying on errors use the `retry_options`

  - __retry_options:__ We are using the great gem [retryable](https://github.com/nfedyashev/retryable) to accomplish this behavior.
  Check the documentation for fine tuning. I just paste some examples for convenience.

  ```ruby
    retry_options do
      { tries: 5, on: [ArgumentError, Wrappi::TimeoutError] } # or
      { tries: :infinite, sleep: 0 }
    end
  ```
  - __around_request:__ This block is executed surrounding the request. The request
  will only get executed if you call `request.call`.
  ```ruby
    around_request do |request, endpoint|
      endpoint.logger.info("making a request to #{endpoint.url} with params: #{endpoint.consummated_params}")
      request.call # IMPORTANT
      endpoint.logger.info("response status is: #{request.status_code}")
    end
  ```

## Code Organization
### Build a gem

Wrappi is designed to be able to build HTTP client gems with it.

```ruby
module GithubCLI
  class Client < Wrappi::Client
    setup do |config|
      config.domain = 'https://api.github.com'
      config.headers = {
        'Content-Type' => 'application/json',
        'Accept' => 'application/vnd.github.v3+json',
      }
    end

    class << self
      attr_accessor :my_custom_config
    end
  end

  def self.setup
    yield(Client)
  end

  class Endpoint < Wrappi::Endpoint
    client Client
  end

  class User < Endpoint
    verb :get
    path "users/:username"
  end

  def self.user(params, opts = {})
    User.new(params, opts)
  end
end

user = GithubCLI.user(username: 'arturictus')
user.success?
```

### In your project

## The HTTP clients war

In ruby there are many ruby clients an everyone has an opinion of which one is the
best.
Every new API client that you install in your project will install a different HTTP client
adding redundant and unnecessary dependencies in your project.
That's why __Wrappi is designed to be HTTP client agnostic__.
Right now is implemented with [HTTP gem](https://github.com/http/http) (my favorite) but all the logic is decoupled from
the HTTP client.

All the configuration, metadata and logic to build the request is hold by an instance of Endpoint. Allowing to create adapters that translates this processed metadata to the target HTTP client.

__Tests are HTTP client agnostic__. To help the development of these adapters and probe the reliability of the gem most of the test are run against a Rails application. __All the tests that probe an HTTP call are running this HTTP call against a local server__ making all test End To End and again, HTTP client agnostic.

Right now is not designed the system to change HTTP clients via configuration but if you are interested to implement one let me know
and we will figure out the way.

## Development

After checking out the repo, run `bin/setup` to install dependencies.

```
bin/dev_server
```
This will run a rails server. The test are running against it.

```
bundle exec rspec
```

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

#### Docker

Run dummy server with docker:
```
docker build -t wrappi/dummy -f spec/dummy/Dockerfile .
docker run -d -p 127.0.0.1:9873:9873 wrappy/dummy /bin/sh -c "bin/rails server -b 0.0.0.0 -p 9873"
```
Try:
```
curl 127.0.0.1:9873 #=> {"controller":"pages","action":"show_body"}
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/arturictus/wrappi. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
