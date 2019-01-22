class DummyController < ApplicationController

  def test_request
    render json: debug_request
  end

  def test_redirect
    redirect_to :test_request
  end
end
