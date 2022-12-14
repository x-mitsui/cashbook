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
      .where({ happened_at: params[:happened_after]..params[:happened_before] })
    items = items.where(kind: params[:kind]) unless params[:kind].blank?
    items = items.page(params[:page])

    render json: { resources: items, pager: {
      page: params[:page] || 1, # 设置保底返回值为1
      per_page: Item.default_per_page, # 默认每页多少条数据
      count: Item.count,
    } }, methods: :tags
  end

  def create
    item = Item.new params.permit(:amount, :happened_at, :kind, tag_ids: [])
    item.user_id = request.env["current_user_id"] # 逻辑上保证了Item中的self.user_id必存在
    # 应该是在save的时候触发了Item自身的validate
    if item.save
      render json: { resource: item }
    else
      render json: { errors: item.errors }, status: :unprocessable_entity
    end
  end

  def balance
    current_user_id = request.env["current_user_id"]
    return head :unauthorized if current_user_id.nil?
    items = Item.where({ user_id: current_user_id })
      .where({ happened_at: params[:happened_after]..params[:happened_before] })
    income_items = []
    expenses_items = []
    items.each { |item|
      if item.kind === "income"
        income_items << item
      else
        expenses_items << item
      end
    }
    income = income_items.sum(&:amount)
    expenses = expenses_items.sum(&:amount)
    render json: { income: income, expenses: expenses, balance: income - expenses }
  end

  def summary
    hash = Hash.new
    # 最终创建一个hash表{ '2018-06-18':300,'2018-06-19': 200, '2018-06-20': 0 }
    items = Item
      .where(user_id: request.env["current_user_id"])
      .where(kind: params[:kind])
      .where(happened_at: params[:happened_after]..params[:happened_before])
    tags = []
    items.each do |item|
      tags += item.tags
      if params[:group_by] == "happened_at"
        key = item.happened_at.in_time_zone("Beijing").strftime("%F")
        hash[key] ||= 0
        hash[key] += item.amount
      else
        item.tag_ids.each do |tag_id|
          key = tag_id
          hash[key] ||= 0
          hash[key] += item.amount
        end
      end
    end
    groups = hash
      .map { |key, value|
      {
        "#{params[:group_by]}": key,
        tag: tags.find { |tag| tag.id == key },
        amount: value,
      }
    }
    if params[:group_by] == "happened_at"
      groups.sort! { |a, b| a[:happened_at] <=> b[:happened_at] }
    elsif params[:group_by] == "tag_id"
      groups.sort! { |a, b| b[:amount] <=> a[:amount] }
    end # sort后加'!'--sort!就是改变自身, 即“A=A.sort”==“A.sort!”
    render json: {
      groups: groups,
      total: items.sum(:amount),
    }
  end
end
