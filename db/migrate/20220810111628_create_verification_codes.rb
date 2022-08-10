class CreateVerificationCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :verification_codes do |t|
      t.string :email
      t.string :kind
      t.datetime :used_at
      t.string :code, limit: 100
      t.timestamps
    end
  end
end
