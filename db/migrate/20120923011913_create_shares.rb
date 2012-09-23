class CreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
      t.integer :note_id
      t.string :email
      t.string :unique_id

      t.timestamps
    end
  end
end
