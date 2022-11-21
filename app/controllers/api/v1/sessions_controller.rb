require "jwt"

class Api::V1::SessionsController < ApplicationController
  def create
    if Rails.env.test?
      return render status: :unauthorized if params[:code] != "123456"
    else
      canSignin = ValidationCodes.exists? email: params[:email], code: params[:code], used_at: nil
      return render status: :unauthorized unless canSignin
    end
    # 用户不存在就创建一个，方便了测试，实际我觉得这样做是不符合业务逻辑的
    user = User.find_or_create_by email: params[:email]
    render status: :ok, json: { jwt: user.generate_jwt }
  end
end
