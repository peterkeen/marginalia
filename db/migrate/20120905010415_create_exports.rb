class CreateExports < ActiveRecord::Migration
  def change
    create_table :exports do |t|
      t.integer :user_id
      t.string :filename

      t.timestamps
    end
  end
end
