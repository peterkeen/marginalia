class AddSubscribedAtToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.datetime :subscribed_at
    end
  end
end
