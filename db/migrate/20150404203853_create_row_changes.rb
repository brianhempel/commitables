class CreateRowChanges < ActiveRecord::Migration
  def change
    create_table :row_changes, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.binary :commit_id, null: false
      t.uuid   :row_id,    null: false
      t.string :type,      null: false
    end
  end
end
