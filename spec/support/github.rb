class Github < Wrappi::Client
  setup do |config|
    config.domain = 'https://api.github.com'
    config.headers = {
      'Content-Type' => 'application/json',
      'Accept' => 'application/vnd.github.v3+json',
    }
  end
end
