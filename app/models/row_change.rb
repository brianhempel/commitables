class RowChange < ActiveRecord::Base
  validates! :row_id, presence: true

  belongs_to :commit
end
