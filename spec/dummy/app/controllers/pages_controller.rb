class PagesController < ApplicationController

  def show_body
    render json: params
  end
end
