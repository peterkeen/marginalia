class AddAdminColumn < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :is_admin, :default => false
    end
  end
end
