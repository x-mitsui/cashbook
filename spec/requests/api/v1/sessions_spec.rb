require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "会话" do
    it "登录（创建会话）" do
      # User.create email: "x_mitsui@163.com"
      post "/api/v1/session", params: { email: "x_mitsui@163.com", code: "123456" }
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json["jwt"]).to be_a(String)
    end
  end
end