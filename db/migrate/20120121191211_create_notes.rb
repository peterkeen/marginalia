class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.text :title
      t.text :body
      t.text :from_address

      t.timestamps
    end
  end
end
