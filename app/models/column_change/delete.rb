class ColumnChange::Delete < ColumnChange

  def self.from_column(column)
    new(column_id: column.id)
  end

  def secure_hash
    Digest::SHA256.digest(secure_hash_parts.join)
  end

  def secure_hash_parts
    [
      Digest::SHA256.digest(column_id),
      Digest::SHA256.digest(type),
    ]
  end
end
