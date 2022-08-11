require "rails_helper"

RSpec.describe User, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  it "User有email" do
    user = User.new email: "x_mitsui@16.com"
    expect(user.email).to be "x_mitsui@163.com"
    # expect(user.email).to eq "x_mitsui@163.com"
  end
end
