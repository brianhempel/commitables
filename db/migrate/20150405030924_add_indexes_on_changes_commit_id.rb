class AddIndexesOnChangesCommitId < ActiveRecord::Migration
  def change
    add_index :column_changes, [:commit_id]
    add_index :cell_changes,   [:commit_id]
    add_index :row_changes,    [:commit_id]
  end
end
