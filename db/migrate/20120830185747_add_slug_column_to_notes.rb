class AddSlugColumnToNotes < ActiveRecord::Migration
  def change
    change_table :notes do |t|
      t.string :slug
      t.index :slug
    end
  end
end
