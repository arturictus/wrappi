class Dummy < Wrappi::Client
  setup do |config|
    config.domain = 'http://0.0.0.0:9873'
    config.headers = {
      'Content-Type' => 'application/json',
      'Accept' => 'application/vnd.github.v3+json',
    }
  end
end
