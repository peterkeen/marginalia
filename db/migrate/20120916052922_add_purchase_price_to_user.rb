class AddPurchasePriceToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.decimal :purchase_price
    end
  end
end
