require "rails_helper"
require "rspec_api_documentation/dsl"

resource "验证码" do
  post "/api/v1/validation_codes" do
    # 参数说明
    parameter :email, type: :string

    # 填入参数
    let(:email) { "1@qq.com" }

    example "请求发送验证码" do
      # 发送请求
      do_request

      # 对结果的期望
      expect(status).to eq 200
    end
  end
end
