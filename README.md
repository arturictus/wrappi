[![Build Status](https://travis-ci.org/arturictus/wrappi.svg?branch=master)](https://travis-ci.org/arturictus/wrappi)
[![Maintainability](https://api.codeclimate.com/v1/badges/8751a0b6523a52b5e23e/maintainability)](https://codeclimate.com/github/arturictus/wrappi/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/8751a0b6523a52b5e23e/test_coverage)](https://codeclimate.com/github/arturictus/wrappi/test_coverage)

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
user.success? # => true
user.error? # => false
user.status_code # => 200
user.body # => {"login"=>"arturictus", "id"=>1930175, ...}
```

### Configurations

#### Client

| Name            | Type                     | Default                                                                  | Required |
|-----------------|--------------------------|--------------------------------------------------------------------------|----------|
| domain          | String                   |                                                                          | *        |
| params          | Hash                     |                                                                          |          |
| logger          | Logger                   | Logger.new(STDOUT)                                                       |          |
| headers         | Hash                     | { 'Content-Type' => 'application/json', 'Accept' => 'application/json' } |          |
| ssl_context     | OpenSSL::SSL::SSLContext |                                                                          |          |
| use_ssl_context | Boolean                  | false                                                                    |          |

#### Endpoint

| Name             | Type                              | Default                 | Required |
|------------------|-----------------------------------|-------------------------|----------|
| client           | Wrappi::Client                    |                         | *        |
| path             | String                            |                         | *        |
| verb             | Symbol                            | :get                    | *        |
| default_params   | Hash                              | {}                      |          |
| headers          | block                             | proc { client.headers } |          |
| basic_auth       | Hash, keys: user, pass            |                         |          |
| follow_redirects | Boolean                           | true                    |          |
| body_type        | Symbol, one of: :json,:form,:body | :json                   |          |
| cache            | Boolean                           | false                   |          |
| retry_if         | block                             |                         |          |
| retry_options    | block                             |                         |          |
| around_request   | block                             |                         |          |

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

  - __ssl_context:__ If you need to set an ssl_context.

     default: `nil`
     ```ruby
     config.ssl_context = OpenSSL::SSL::SSLContext.new.tap do |ctx|
                            ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
                          end
     ```

  - __use_ssl_context:__ It has to be set to `true` for using the `ssl_context`

     default: `false`

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

  - __follow_redirects:__ If first request responds a redirect it will follow them.

    default: `true`

  - __body_type:__ Body type.

    default: `:json`

    - :json
    - :form
    - :body (Binary data)

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

    default: `false`
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
