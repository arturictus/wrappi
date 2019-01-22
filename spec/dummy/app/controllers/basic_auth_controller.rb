class BasicAuthController < ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  http_basic_authenticate_with name: "wrappi", password: "secret"

  def test_request
    render json: debug_request
  end
end
