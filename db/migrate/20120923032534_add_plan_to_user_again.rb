class AddPlanToUserAgain < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.integer :plan_id
    end
  end
end
