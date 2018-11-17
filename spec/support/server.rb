require 'json'
require "sinatra/base"

class Server < Sinatra::Base
  set :bind, '0.0.0.0'

  class << self
    def start
      set :port, 9873
      Thread.start { run! }
    end

    def quit!
      super
      exit
    end
  end

  get '/' do
    { hello: 'hello' }.to_json
  end
  get '/users/:id' do
    {id: params[:id]}.to_json
  end
end
