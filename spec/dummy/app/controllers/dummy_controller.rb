class DummyController < ApplicationController

  def get_test
    render json: debug_request
  end
  def post_test
    render json: debug_request
  end

  private

  def debug_request
    {
      request: {
        method: request.method,
        url: request.url,
        path: request.path,
        content_type: headers["Content-Type"],
        accept: headers['Accept'],
        env: request.env.select {|k,v| k.match("^HTTP.*|^CONTENT.*|^REMOTE.*|^REQUEST.*|^AUTHORIZATION.*|^SCRIPT.*|^SERVER.*") }
      },
      params: params.reject{ |k, v| ['controller', 'action'].include?(k) }
    }
  end
end
