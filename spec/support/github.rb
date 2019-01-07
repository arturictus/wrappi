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
