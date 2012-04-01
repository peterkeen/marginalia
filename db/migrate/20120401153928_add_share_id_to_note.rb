class AddShareIdToNote < ActiveRecord::Migration
  def change
    add_column :notes, :share_id, :string
  end
end
