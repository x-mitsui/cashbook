require 'rails_helper'

RSpec.describe "Api::V1::Items", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/api/v1/items/create"
      expect(response).to have_http_status(:success)
    end
  end

end
