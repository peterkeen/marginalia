class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.string :slug
      t.integer :amount
      t.string :interval
      t.boolean :active
      t.integer :sort_order

      t.timestamps
    end
  end
end
