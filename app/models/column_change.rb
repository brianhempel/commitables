class ColumnChange < ActiveRecord::Base
  validates! :column_id, presence: true

  belongs_to :commit
end
