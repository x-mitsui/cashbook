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

    # 通过时间范围筛选
    # 测试：rspec spec/requests/api/v1/items_spec.rb:17
    current_user_id = request.env["current_user_id"]
    return head :unauthorized if current_user_id.nil?
    items = Item.where({ user_id: current_user_id })
      .where({ created_at: params[:created_after]..params[:created_before] })
      .page(params[:page])
    render json: { resources: items, pager: {
      page: params[:page] || 1, # 设置保底返回值为1
      per_page: Item.default_per_page, # 默认每页多少条数据
      count: Item.count,
    } }
  end

  def create
    # item = Item.new amount: params[:amount], tags_id: params[:tags_id], happened_at: params[:happened_at]
    item = Item.new params.permit(:amount, :happened_at, tags_id: [])
    item.user_id = request.env["current_user_id"]
    if item.save
      render json: { resource: item }
    else
      render json: { errors: item.errors }, status: :unprocessable_entity
    end
  end
end
