require "rails_helper"

RSpec.describe "ValidationCodes", type: :request do
  describe "验证码" do
    it "发送太频繁就会返回 429" do
      post "/api/v1/validation_codes", params: { email: "x_mitsui@163.com" }
      expect(response).to have_http_status(200)
      post "/api/v1/validation_codes", params: { email: "x_mitsui@163.com" }
      expect(response).to have_http_status(429)
    end
    it "邮箱格式错误就返回 422" do
      post "/api/v1/validation_codes", params: { email: "x_mitsui" }
      expect(response).to have_http_status(422)
      json = JSON.parse response.body
      expect(json["errors"]["email"][0]).to eq "邮件地址格式不正确"
    end
  end
end
