class RowChange::Delete < RowChange

  def self.from_row(row)
    new(row_id: row.id)
  end

  def secure_hash
    Digest::SHA256.digest(secure_hash_parts.join)
  end

  def secure_hash_parts
    [
      Digest::SHA256.digest(row_id),
      Digest::SHA256.digest(type),
    ]
  end
end
