class DummyController < ApplicationController

  def test_request
    render json: debug_request
  end

  def test_redirect
    redirect_to :test_request
  end

  private

  def debug_request
    {
      request: {
        method: request.method,
        url: request.url,
        path: request.path,
        content_type: request.env["CONTENT_TYPE"],
        accept: request.env['HTTP_ACCEPT'],
        env: request.env.select {|k,v| k.match("^HTTP.*|^CONTENT.*|^REMOTE.*|^REQUEST.*|^AUTHORIZATION.*|^SCRIPT.*|^SERVER.*") }
      },
      params: params.reject{ |k, v| ['controller', 'action'].include?(k) }
    }
  end
end
