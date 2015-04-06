require "set"

class Table < ActiveRecord::Base
  belongs_to :head, class_name: "Commit"

  validates :name, presence: :true

  def to_param
    id || head_id.bin_to_hex
  end

  def head_id_hex
    head_id.bin_to_hex
  end

  def parent_id_hex
    head.parent_id.bin_to_hex
  end

  def columns
    ids_to_cols = {}

    column_changes.each do |change|
      case change
      when ColumnChange::Create, ColumnChange::Update
        ids_to_cols[change.column_id] = change.column
      when ColumnChange::Delete
        ids_to_cols.delete(change.column_id)
      end
    end

    ids_to_cols.values
  end

  def row_count
    CellChange.from(
      "(#{cell_changes.reorder(nil).select("DISTINCT row_id").to_sql}) cell_changes"
    ).where.not(
      row_id: row_changes.where(type: "RowChange::Delete").select(:row_id)
    ).count
  end

  def rows(sort_direction: "ascending", sort_column: nil, limit: 0)
    columns = self.columns
    sort_column ||= columns.first

    direction = (sort_direction == "ascending" ? :asc : :desc)

    # Start a stream of all the row ids in order
    candidate_row_ids_with_commit_id =
      CellChange.
        where(column_id: sort_column.try(:id)).
        order(cell_value: direction, commit_id: direction, row_id: direction).
        select(:row_id, :commit_id).
        each_hash.
        lazy.
        map(&:values).
        map do |row_id, commit_id|
          [row_id, commit_id[2..-1].hex_to_bin] # PostgreSQL Cursor returns "\\xb0067cc14db2c1ec56465ece0f92fb45bf6e0fe31e048960c66d38c5c77ded80" but we want binary strings.
        end

    # Filter so we only see rows that belong to this table
    commit_ids_to_n = commits.pluck(:id, :n).to_h

    my_row_ids_with_commit_id =
      candidate_row_ids_with_commit_id.
        select { |_, commit_id| true if commit_ids_to_n[commit_id] }

    # Discard row ids not from the most recent commit for the cell
    most_recent_cell_commit_id_for_row_ids = ->(row_ids) do
      cell_changes.
        where(column_id: sort_column.id).
        where(row_id: row_ids).
        reorder("row_id ASC, commits.n DESC").
        pluck("DISTINCT ON (row_id) row_id, commit_id").
        to_h
    end

    my_most_recent_row_ids =
      my_row_ids_with_commit_id.
        each_slice(1000).
        flat_map do |chunk|
          row_ids = chunk.map(&:first).uniq
          row_id_to_most_recent_commit_id = most_recent_cell_commit_id_for_row_ids.call(row_ids)

          chunk.select do |row_id, commit_id|
            row_id_to_most_recent_commit_id[row_id] == commit_id
          end.map(&:first) # Don't need commit id anymore.
        end

    # Remove deleted row ids
    my_most_recent_existing_row_ids =
      my_most_recent_row_ids.
        each_slice(1000).
        flat_map do |row_ids_chunk|
          deleted_row_ids = row_changes.
                              reorder(nil).
                              where(type: "RowChange::Delete", row_id: row_ids_chunk).
                              pluck(:row_id).
                              to_set
          row_ids_chunk.select do |row_id|
            !deleted_row_ids.include?(row_id)
          end
        end

    # Map row ids to full rows
    chunk_size = if limit > 0 && limit < 1000
      limit
    else
      1000
    end

    rows =
      my_most_recent_existing_row_ids.
        each_slice(chunk_size).
        flat_map do |row_ids_chunk|
          ids_to_rows = row_ids_chunk.zip([false]*row_ids_chunk.size).to_h

          cell_changes.
            where(row_id: row_ids_chunk).
            select(:type, :row_id, :column_id, :cell_value).
            each_hash do |stuff|
              change_type, row_id, column_id, cell_value = stuff.values

              case change_type
              when "CellChange::Create", "CellChange::Update"
                row = (
                  ids_to_rows[row_id] ||= Row.new(id: row_id, columns: columns, cells: {})
                )
                row.cells[column_id] = cell_value
              end
            end

          ids_to_rows.values
        end

    if limit > 0
      rows.take(limit)
    else
      rows
    end
  end

  def new_row(attrs = {})
    defaults = { id: SecureRandom.uuid, columns: columns, cells: {} }
    Row.new(defaults.merge(attrs))
  end

  def column_changes
    ColumnChange.joins("INNER JOIN (#{commits.to_sql}) commits ON column_changes.commit_id = commits.id").order("commits.n ASC")
  end

  def row_changes
    RowChange.joins("INNER JOIN (#{commits.to_sql}) commits ON row_changes.commit_id = commits.id").order("commits.n ASC")
  end

  def cell_changes
    CellChange.joins("INNER JOIN (#{commits.to_sql}) commits ON cell_changes.commit_id = commits.id").order("commits.n ASC")
  end

  # Root commit appears first
  def commits
    head.and_ancestors.order(n: :asc)
  end

  concerning :DSL do
    def create_column!(column)
      create_commit! do |commit|
        commit.create_column(column)
      end
    end

    def update_column!(column)
      create_commit! do |commit|
        commit.update_table_column(column)
      end
    end

    def delete_column!(column)
      create_commit! do |commit|
        commit.delete_column(column)
      end
    end

    def create_row!(row)
      create_commit! do |commit|
        commit.create_row(row)
      end
    end

    def update_row!(row)
      create_commit! do |commit|
        commit.update_row(row)
      end
    end

    def delete_row!(row)
      create_commit! do |commit|
        commit.delete_row(row)
      end
    end
  end

  def create_commit!
    self.head = Commit.create_off_parent_id!(head_id) do |commit|
      yield commit
    end
    save!
  end
end
