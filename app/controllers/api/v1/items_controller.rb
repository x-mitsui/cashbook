class Api::V1::ItemsController < ApplicationController
  def index
    # 获取第一页，要提前安装kaminari
    item = Item.page(params[:page]).per(33)
    render json: {
      resource: item,
      pager: {
        page: params[:page],
        per_page: 222,
        count: Item.count,
      },
    }
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
