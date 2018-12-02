class DummyController < ApplicationController

  def get_test
    render json: params
  end
end
