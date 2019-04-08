# Wrappi an HTTP framework

I would like to introduce you the gem I recently created to build HTTP clients.

My motivations:

- I've been using a lot of API clients in my projects an every time I have to use
one I have to memorize the behavior. Or some of them where not easy to use or with
estrange interface.

- When building myself API clients I find myself repeating the same process of finding how to
implement the best practices and flexibility enough for use cases, same abstractions to handle request errors, codes, etc.
Basically redoing something that I think could be abstracted in a framework.

That's why I builded Wrappi.

Let me convince you that your life will be much easier if you use Wrappi.

Let's do a Github Client together:

__The client:__

Client is where the shared configurations for you calls are stored. Domain, api keys, headers.

Here it is an example:

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
  end
end
```
How you see we created a namespace `GithubCLI`.
I like my clients to be appended with `CLI` or `API` because when you use the gem in you project you will need
to create a wrapper around it and if the gem is called like the service I makes you have to be creative about the name and
your application code is less descriptive.

see by yourself:

```ruby
module Github
  def self.update_repos(user)
    g = GithubCLI.users(username: user.github_username)
    if g.success?
      g.body['repos'].each do |r|
        # what ever
      end
    else
      false
    end
  end
end

Github.update_repos(user)
```
In this case the service is integrated to our application. We just call `Github` in
our application.

Next we created a Client holding all the global settings to make a call to any API. That means the domain, headers and params that will be shared
between all the endpoints in which we use this client.

Now let's create our first endpoint:

```ruby
module GithubCLI
  class client < Wrappi:Client
    # ...
  end


  class User < Wrappi::Endpoint
    client Client
    verb :get
    path "users/:username"
  end
end
```

Here we just defined a class iheriting from `Wrappi::Endpoint`. In this class we just set few configs:
client, verb and path. This is all we need to make our first request.

```ruby
req = GithubCLI::User.new(username: 'arturictus')
user.error? # => false
user.status_code # => 200
user.body # => {"login"=>"arturictus", "id"=>1930175, ...}
```

Yep!, done.

Right now is when you say: "I can do the same in a single line of code" and you are right. But now is when things get interesting.

Imagine that you have have an API key. It's not a hard thing to fix right?, maybe we create a class that all our endpoints inherit from?..

In wrappi you can just do it with a line of code:

```ruby
module GithubCLI
  class Client < Wrappi::Client
    setup do |config|
      config.domain = 'https://api.github.com'
      config.headers = {
        'Content-Type' => 'application/json',
        'Accept' => 'application/vnd.github.v3+json',
      }
      config.params = { api_token: 'very_secret' } # Look here
    end
  end
end
```

Now all the endpoints using this client will send with the request the `api_token` param.

```ruby
req = GithubCLI::User.new(username: 'arturictus')
req.conssumated_params # => { api_token: ...}
```

Ok, not impressive but we are starting to safe lines of code.


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

```
