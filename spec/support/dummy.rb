class Dummy < Wrappi::Client
  setup do |config|
    config.domain = 'http://127.0.0.1:9873'
    config.headers = {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
    }
    config.cache = CacheMock.new
  end
end
class DummyBasicAuth < Wrappi::Client
  setup do |config|
    config.domain = 'http://127.0.0.1:9873'
    config.headers = {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
    }
    config.cache = CacheMock.new
    config.basic_auth = { user: 'wrappi', pass: 'secret'}
  end
end
