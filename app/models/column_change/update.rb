class ColumnChange::Update < ColumnChange
  validates :column_name, presence: true

  def self.from_column(column)
    new(
      column_id:   column.id,
      column_name: column.name
    )
  end

  def column
    Column.new(
      id:   column_id,
      name: column_name
    )
  end

  def secure_hash
    Digest::SHA256.digest(secure_hash_parts.join)
  end

  def secure_hash_parts
    [
      Digest::SHA256.digest(column_id),
      Digest::SHA256.digest(type),
      Digest::SHA256.digest(column_name),
    ]
  end
end
