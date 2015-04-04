class CreateColumnChanges < ActiveRecord::Migration
  def change
    create_table :column_changes, id: :uuid, defualt: "uuid_generate_v4()" do |t|
      t.binary :commit_id,   null: false
      t.uuid   :column_id,   null: false
      t.string :type,        null: false
      t.string :column_name
    end
  end
end
