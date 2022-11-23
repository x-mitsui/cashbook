class Api::V1::TagsController < ApplicationController
  def index
    current_user = User.find request.env["current_user_id"]
    return render status: 401 if current_user.nil?
    tags = Tag.where(user_id: current_user.id).page(params[:page])
    render json: { resources: tags, pager: {
      page: params[:page] || 1, # 设置保底返回值为1
      per_page: Item.default_per_page, # 默认每页多少条数据
      count: Item.count,
    } }
  end

  def create
    current_user = User.find request.env["current_user_id"]
    return render status: 401 if current_user.nil?

    # tag = Tag.create name: params[:name], sign: params[:sign], user_id: current_user.id
    tag = Tag.new name: params[:name], sign: params[:sign], user_id: current_user.id
    if tag.save
      render json: { resource: tag }, status: :ok
    else
      render json: { errors: tag.errors }, status: :unprocessable_entity
    end
  end

  def update
    tag = Tag.find params[:id]
    # 此写法问题：如果某一个参数为空，数据库就会存一个空的字段
    # tag.update name: params[:name], sign: params[:sign]
    # permit：参数只允许接受name和sign，其它一律不接受，
    ## 另外用户传其中1个参数就改1个参数，对应更新的最后一个测试用例；
    ## 用户传满2个，就改两个；
    ## 用户没传就不改。
    tag.update params.permit(:name, :sign)
    # nil?只判断是否为空，empty?还会判断数组长度是否为0
    if tag.errors.empty?
      # 更新成功
      render json: { resource: tag }
    else
      render json: { errors: tag.errors }, status: :unprocessable_entity
    end
  end
end
