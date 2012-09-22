class AddFeatureFlagsToPlan < ActiveRecord::Migration
  def change
    change_table :plans do |t|
      t.boolean :featured
      t.boolean :can_share
      t.boolean :can_export
    end
  end
end
