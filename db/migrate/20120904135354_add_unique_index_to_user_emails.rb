class AddUniqueIndexToUserEmails < ActiveRecord::Migration
  def change
    add_index :user_emails, :email, :unique => true
  end
end
