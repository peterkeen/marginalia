class AddIndexesToNotes < ActiveRecord::Migration
  def up
    execute "
      create index idx_notes_title_fts on notes using gin(to_tsvector('english', title));
      create index idx_notes_body_fts on notes using gin(to_tsvector('english', body));"
  end

  def down
    execute "drop index idx_notes_title_fts; drop index idx_notes_body_fts;"
  end
end
