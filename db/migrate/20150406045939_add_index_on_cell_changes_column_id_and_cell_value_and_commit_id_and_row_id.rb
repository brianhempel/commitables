class AddIndexOnCellChangesColumnIdAndCellValueAndCommitIdAndRowId < ActiveRecord::Migration
  def change
    add_index :cell_changes, [:column_id, :cell_value, :commit_id, :row_id], name: "index_cell_changes_on_lots_of_stuff"
  end
end
