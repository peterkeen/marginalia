class CreateUserEmails < ActiveRecord::Migration
  def change
    create_table :user_emails do |t|
      t.string :email, :unique => true
      t.integer :user_id
      t.timestamps
    end
  end
end
