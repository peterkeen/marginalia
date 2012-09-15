class AddPositionAndProjectToNote < ActiveRecord::Migration
  def change
    change_table :notes do |t|
      t.integer :project_id
      t.integer :position
    end
  end
end
