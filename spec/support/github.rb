class Github < Wrappi::Client
  domain 'https://api.github.com'
  headers({
    'Content-Type' => 'application/json',
    'Accept' => 'application/vnd.github.v3+json',
  })
end
