class AddStripeColumnsToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string   :stripe_id
      t.datetime :purchased_at
    end
  end
end
