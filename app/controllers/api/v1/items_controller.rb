class Api::V1::ItemsController < ApplicationController
  def index
    # 获取第一页，要提前安装kaminari
    # 测试：curl -X GET http://127.0.0.1:3000/api/v1/items -v
    # item = Item.page(1)

    # 获取任意页
    # 测试：curl -X GET http://127.0.0.1:3000/api/v1/items\?page\=2 -v
    # item = Item.page params[:page]

    # 自定义每页item数量为33个
    # 测试：curl -X GET http://127.0.0.1:3000/api/v1/items -v
    item = Item.page(params[:page]).per(33)
    render json: {
      resource: item,
    }

    # Item.count//总条数
  end

  def create
    item = Item.new amount: 1
    if item.save
      render json: { resource: item }
    else
      render json: { errors: item.errors }
    end
  end
end
