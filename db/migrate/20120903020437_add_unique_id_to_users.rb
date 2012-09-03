class AddUniqueIdToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :unique_id
    end
  end
end
