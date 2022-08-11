class Api::V1::UsersController < ApplicationController
  def create
    user = User.new email: "x_mitsui@163.com"
    if user.save
      render json: { resource: user }
    else
      render json: { errors: user.errors }
    end
  end
end
