class Row
  include ActiveModel::Model

  attr_accessor :id, :columns, :cells

  def [](col)
    cells[col.id]
  end

  def cells=(hash)
    @cells = RowCells.new(self, hash)
  end
end
