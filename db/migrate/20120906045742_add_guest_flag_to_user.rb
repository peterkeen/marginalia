class AddGuestFlagToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :is_guest, :default => false
    end
  end
end
