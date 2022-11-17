class Api::V1::UsersController < ApplicationController
  def create
    user = User.new email: "x_mitsui@163.com", name: "x_mitsui"
    if user.save
      p "save成功"
      render json: user
    else
      p "save失败"
      render json: user.errors
    end
  end

  def show
    # 尽量不直接用User.find，它找不到目标会直接返回预设的信息
    # 如果想指定返回信息用find_by_id
    usr = User.find_by_id params[:id]
    if usr
      render json: usr
    else
      head 404
    end
  end
end
