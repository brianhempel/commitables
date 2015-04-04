class Cell
  attr_reader :column, :value

  def initialize(column, value)
    @column, @value = column, value
  end

  def to_s
    value.to_s
  end
end
