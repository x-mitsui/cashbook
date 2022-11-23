require "rails_helper"
require "rspec_api_documentation/dsl"

resource "标签" do
  get "/api/v1/tags" do
    # 这是鉴权
    authentication :basic, :auth # :basic代表基础验证，:auth代表值，具体多少呢，看下面第四个的let
    # 这是参数
    parameter :page, "页码"
    # parameter :created_after, "创建时间起点（筛选条件）"
    # parameter :created_before, "创建时间终点（筛选条件）"
    # 响应值的字段名称
    with_options :scope => :resources do
      response_field :id, "ID"
      response_field :name, "名称"
      response_field :sign, "符号"
      response_field :user_id, "用户ID"
      response_field :delete_at, "删除时间"
    end
    # 样例的值
    let(:current_user) { User.create email: "1@qq.com" }
    let(:auth) { "Bearer #{current_user.generate_jwt}" }
    example "获取标签" do
      11.times do Tag.create name: "x", sign: "x", user_id: current_user.id end

      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resources"].size).to eq 10
    end
  end
end
