class AddWordCountToNote < ActiveRecord::Migration
  def change
    change_table :notes do |t|
      t.integer :word_count
    end
  end
end
