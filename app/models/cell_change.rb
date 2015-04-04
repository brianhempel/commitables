class CellChange < ActiveRecord::Base
  validates! :row_id,    presence: true
  validates! :column_id, presence: true

  belongs_to :commit
end
