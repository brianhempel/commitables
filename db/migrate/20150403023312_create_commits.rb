class CreateCommits < ActiveRecord::Migration
  def change
    create_table :commits, id: :binary do |t|
      t.binary :parent_id, null: false
    end
  end
end
