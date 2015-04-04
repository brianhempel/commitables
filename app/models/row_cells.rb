class RowCells
  attr_reader :row, :hash

  include Enumerable

  def initialize(row, hash={})
    @row, @hash = row, hash
  end

  def [](col_id)
    if value = hash[col_id]
      col = row.columns.find { |col| col.id == col_id }
      Cell.new(col, value)
    end
  end

  def []=(col_id, value)
    col = row.columns.find { |col| col.id == col_id }
    hash[col_id] = Cell.new(col, value)
  end

  def each
    row.columns.each do |col|
      yield Cell.new(col, hash[col.id])
    end
  end
end
