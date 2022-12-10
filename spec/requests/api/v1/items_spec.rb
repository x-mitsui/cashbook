require "rails_helper"

RSpec.describe "Items", type: :request do
  describe "获取账目" do
    it "分页，未登录" do
      user1 = User.create email: "1@qq.com"
      user2 = User.create email: "2@qq.com"
      11.times { Item.create amount: 100, user_id: user1.id }
      11.times { Item.create amount: 100, user_id: user2.id }
      get "/api/v1/items"
      # 401未授权，无访问权限
      expect(response).to have_http_status 401
    end
    it "分页" do
      user1 = User.create! email: "1@qq.com"
      user2 = User.create! email: "2@qq.com"
      # 11.times { Item.create! amount: 100, created_at: "2018-01-02", user_id: user1.id }
      # 11.times { Item.create! amount: 100, created_at: "2018-01-02", user_id: user2.id }
      create_list :item, 11, amount: 100, user: user1, tag_ids: [create(:tag, user: user1).id]
      create_list :item, 11, amount: 100, user: user2, tag_ids: [create(:tag, user: user2).id]
      # post "/api/v1/session", params: { email: user1.email, code: "123456" }
      # json = JSON.parse response.body
      # jwt = json["jwt"]

      get "/api/v1/items", headers: user1.get_auth_header

      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 10
      get "/api/v1/items?page=2", headers: user1.get_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 1
    end
    it "按时间筛选" do
      user1 = User.create email: "1@qq.com"
      item1 = Item.create amount: 100, created_at: "2018-01-02", user_id: user1.id
      item2 = Item.create amount: 100, created_at: "2018-01-02", user_id: user1.id
      item3 = Item.create amount: 100, created_at: "2019-01-01", user_id: user1.id
      get "/api/v1/items?created_after=2018-01-01&created_before=2018-01-03",
        headers: user1.get_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      p json["resources"]
      expect(json["resources"].size).to eq 2
      expect(json["resources"][0]["id"]).to eq item1.id
      expect(json["resources"][1]["id"]).to eq item2.id
    end
    it "按时间筛选(时间边界测试)" do
      user1 = User.create email: "1@qq.com"
      item1 = Item.create amount: 100, created_at: "2018-01-01", user_id: user1.id
      get "/api/v1/items?created_after=2018-01-01&created_before=2018-01-03",
          headers: user1.get_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      p json["resources"]
      expect(json["resources"].size).to eq 1
      expect(json["resources"][0]["id"]).to eq item1.id
    end
    it "按时间筛选(时间边界测试1)" do
      user1 = User.create email: "1@qq.com"
      item1 = Item.create amount: 100, created_at: "2018-01-01", user_id: user1.id
      item2 = Item.create amount: 100, created_at: "2017-01-01", user_id: user1.id
      get "/api/v1/items?created_after=2018-01-01",
          headers: user1.get_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      p json["resources"]
      expect(json["resources"].size).to eq 1
      expect(json["resources"][0]["id"]).to eq item1.id
    end
    it "按时间筛选(时间边界测试2)" do
      user1 = User.create email: "1@qq.com"
      item1 = Item.create amount: 100, created_at: "2017-01-01", user_id: user1.id
      item2 = Item.create amount: 100, created_at: "2019-01-01", user_id: user1.id
      get "/api/v1/items?created_before=2018-01-01",
          headers: user1.get_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      p json["resources"]
      expect(json["resources"].size).to eq 1
      expect(json["resources"][0]["id"]).to eq item1.id
    end
  end
  describe "创建账目" do
    it "未登录创建" do
      post "/api/v1/items", params: { amount: 100 }
      expect(response).to have_http_status 401
    end
    it "登录后创建" do
      user = User.create email: "1@qq.com"
      tag1 = Tag.create name: "tag1", sign: "x", user_id: user.id
      tag2 = Tag.create name: "tag2", sign: "x", user_id: user.id
      expect {
        post "/api/v1/items", params: { amount: 99 }, headers: user.get_auth_header
        post "/api/v1/items", params: { amount: 99, tag_ids: [tag1.id, tag2.id],
                                        happened_at: "2018-01-01T00:00:00+08:00" },
                              headers: user.get_auth_header
      }.to change { Item.count }.by 1
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json["resource"]["id"]).to be_an(Numeric)
      expect(json["resource"]["amount"]).to eq 99
      expect(json["resource"]["user_id"]).to eq user.id
      expect(json["resource"]["happened_at"]).to eq "2017-12-31T16:00:00.000Z"
    end
    it "创建时 amount、tag_ids、happened_at 必填" do
      user = User.create email: "1@qq.com"
      post "/api/v1/items", params: {}, headers: user.get_auth_header
      expect(response).to have_http_status 422
      json = JSON.parse response.body
      expect(json["errors"]["amount"][0]).to eq "can't be blank"
      expect(json["errors"]["tag_ids"][0]).to eq "can't be blank"
      expect(json["errors"]["happened_at"][0]).to eq "can't be blank"
    end
  end
  describe "统计数据" do
    it "按天分组" do
      user = User.create! email: "1@qq.com"
      tag = Tag.create! name: "tag1", sign: "x", user_id: user.id
      # 注意金额单位为"分"
      # 数据的创建时间故意混乱，以便测试排序
      Item.create! amount: 100, kind: "expenses", tag_ids: [tag.id], happened_at: "2018-06-18T00:00:00+08:00", user_id: user.id
      Item.create! amount: 200, kind: "expenses", tag_ids: [tag.id], happened_at: "2018-06-18T00:00:00+08:00", user_id: user.id
      Item.create! amount: 100, kind: "expenses", tag_ids: [tag.id], happened_at: "2018-06-20T00:00:00+08:00", user_id: user.id
      Item.create! amount: 200, kind: "expenses", tag_ids: [tag.id], happened_at: "2018-06-20T00:00:00+08:00", user_id: user.id
      Item.create! amount: 100, kind: "expenses", tag_ids: [tag.id], happened_at: "2018-06-19T00:00:00+08:00", user_id: user.id
      Item.create! amount: 200, kind: "expenses", tag_ids: [tag.id], happened_at: "2018-06-19T00:00:00+08:00", user_id: user.id
      get "/api/v1/items/summary", params: {
                                     happened_after: "2018-01-01",
                                     happened_before: "2019-01-01", # 包含以上mock数据的时间
                                     kind: "expenses", # 对应以上mock数据的类型
                                     group_by: "happened_at",
                                   }, headers: user.get_auth_header

      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json["groups"].size).to eq 3
      expect(json["groups"][0]["happened_at"]).to eq "2018-06-18"
      expect(json["groups"][0]["amount"]).to eq 300
      expect(json["groups"][1]["happened_at"]).to eq "2018-06-19"
      expect(json["groups"][1]["amount"]).to eq 300
      expect(json["groups"][2]["happened_at"]).to eq "2018-06-20"
      expect(json["groups"][2]["amount"]).to eq 300
      expect(json["total"]).to eq 900
    end
    it "按标签ID分组" do
      user = User.create! email: "1@qq.com"
      tag1 = Tag.create! name: "tag1", sign: "x", user_id: user.id
      tag2 = Tag.create! name: "tag2", sign: "x", user_id: user.id
      tag3 = Tag.create! name: "tag3", sign: "x", user_id: user.id
      Item.create! amount: 100, kind: "expenses", tag_ids: [tag1.id, tag2.id], happen_at: "2018-06-18T00:00:00+08:00", user_id: user.id
      Item.create! amount: 200, kind: "expenses", tag_ids: [tag2.id, tag3.id], happen_at: "2018-06-18T00:00:00+08:00", user_id: user.id
      Item.create! amount: 300, kind: "expenses", tag_ids: [tag3.id, tag1.id], happen_at: "2018-06-18T00:00:00+08:00", user_id: user.id
      get "/api/v1/items/summary", params: {
                                     happened_after: "2018-01-01",
                                     happened_before: "2019-01-01",
                                     kind: "expenses",
                                     group_by: "tag_id",
                                   }, headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json["groups"].size).to eq 3
      expect(json["groups"][0]["tag_id"]).to eq tag3.id
      expect(json["groups"][0]["amount"]).to eq 500
      expect(json["groups"][1]["tag_id"]).to eq tag1.id
      expect(json["groups"][1]["amount"]).to eq 400
      expect(json["groups"][2]["tag_id"]).to eq tag2.id
      expect(json["groups"][2]["amount"]).to eq 300
      expect(json["total"]).to eq 600
    end
  end
end
