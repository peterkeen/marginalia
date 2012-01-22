class AddUniqueToNote < ActiveRecord::Migration
  def change
    add_column :notes, :unique_id, :string
  end
end
