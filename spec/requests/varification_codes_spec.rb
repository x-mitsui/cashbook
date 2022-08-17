require "rails_helper"

RSpec.describe "VarificationCodes", type: :request do
  describe "验证码" do
    it "可以被发送" do
      post "/api/v1/verification_codes", params: { email: "x_mitsui@163.com" }
      expect(response).to have_http_status(200)
    end
  end
end
