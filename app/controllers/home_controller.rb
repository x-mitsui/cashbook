class HomeController < ApplicationController
  def index
    render json: {
      message: "current env is " + ENV["RAILS_ENV"],
    }
  end
end
