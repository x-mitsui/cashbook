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
      user1 = User.create email: "1@qq.com"
      user2 = User.create email: "2@qq.com"
      11.times { Item.create amount: 100, user_id: user1.id }
      11.times { Item.create amount: 100, user_id: user2.id }

      # post "/api/v1/session", params: { email: user1.email, code: "123456" }
      # json = JSON.parse response.body
      # jwt = json["jwt"]
      p "11111111111"
      p user1.generate_auth_header
      get "/api/v1/items", headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 10
      get "/api/v1/items?page=2", headers: user1.generate_auth_header
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
        headers: user1.generate_auth_header
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
          headers: user1.generate_auth_header
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
          headers: user1.generate_auth_header
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
          headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      p json["resources"]
      expect(json["resources"].size).to eq 1
      expect(json["resources"][0]["id"]).to eq item1.id
    end
  end
  describe "create" do
    it "can create an item" do
      expect {
        post "/api/v1/items", params: { amount: 99 }
      }.to change { Item.count }.by 1
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json["resource"]["id"]).to be_an(Numeric)
      expect(json["resource"]["amount"]).to eq 1
    end
  end
end
