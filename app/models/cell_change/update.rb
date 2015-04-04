class CellChange::Update < CellChange
  def self.from_row_and_cell(row, cell)
    new(
      row_id:     row.id,
      column_id:  cell.column.id,
      cell_value: cell.value
    )
  end

  def secure_hash
    Digest::SHA256.digest(secure_hash_parts.join)
  end

  def secure_hash_parts
    [
      Digest::SHA256.digest(row_id),
      Digest::SHA256.digest(column_id),
      Digest::SHA256.digest(type),
      Digest::SHA256.digest(cell_value.to_json),
    ]
  end
end
