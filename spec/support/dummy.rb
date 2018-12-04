class Dummy < Wrappi::Client
  domain 'http://0.0.0.0:9873'
  headers({
    'Content-Type' => 'application/json',
    'Accept' => 'application/json',
  })
end
