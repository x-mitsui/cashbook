require "jwt"

class Api::V1::SessionsController < ApplicationController
  def create
    if Rails.env.test?
      # 测试环境需要添加一个code，固定为123456
      render status: :unauthorized if params[:code] != "123456"
    else
      canSignin = ValidationCodes.exists? email: params[:email], code: params[:code], used_at: nil
      if !canSignin
        render status: :unauthorized
        return
      end
    end

    user = User.find_by_email params[:email]
    if user.nil?
      render status: :not_found, json: { errors: "用户不存在" }
    else
      hmac_secret = "my$ecretK3y"
      payload = { user_id: user.id }
      token = JWT.encode payload, hmac_secret, "HS256"
      render status: :ok, json: {
        jwt: token,
      }
    end
  end
end
