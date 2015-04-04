class Column
  include ActiveModel::Model

  validates :name, presence: true

  attr_accessor :id, :name
end
