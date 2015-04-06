class MoarIndexes < ActiveRecord::Migration
  def change
    add_index :cell_changes, [:row_id]
  end
end
