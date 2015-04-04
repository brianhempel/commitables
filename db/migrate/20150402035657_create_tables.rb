class CreateTables < ActiveRecord::Migration
  def change
    create_table :tables, id: :uuid, defualt: "uuid_generate_v4()" do |t|
      t.string :name,    null: false
      t.binary :head_id, null: false

      t.timestamps null: false
    end
  end
end
