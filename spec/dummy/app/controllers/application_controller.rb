class ApplicationController < ActionController::API

  private

  def debug_request
    {
      request: {
        method: request.method,
        url: request.url,
        path: request.path,
        content_type: request.env["CONTENT_TYPE"],
        accept: request.env['HTTP_ACCEPT'],
        env: request.env.select {|k,v| k.match("^HTTP.*|^CONTENT.*|^REMOTE.*|^REQUEST.*|^AUTHORIZATION.*|^SCRIPT.*|^SERVER.*") },
        basic_auth: request.env['HTTP_AUTHORIZATION']
      },
      params: params.reject{ |k, v| ['controller', 'action'].include?(k) }
    }
  end
end
