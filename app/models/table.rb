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
    cell_changes.
      where.not(
        row_id: row_changes.where(type: "RowChange::Delete").select(:row_id)
      ).
      count("DISTINCT (row_id)")
  end

  def rows(sort_direction: "ascending", sort_column: nil)
    ids_to_rows = {}

    columns = self.columns

    cell_changes.each do |change|
      case change
      when CellChange::Create, CellChange::Update
        row = (ids_to_rows[change.row_id] ||= Row.new(id: change.row_id, columns: columns, cells: {}))
        row.cells[change.column_id] = change.cell_value
      end
    end

    row_changes.each do |change|
      case change
      when RowChange::Delete
        ids_to_rows.delete(change.row_id)
      end
    end

    sort_column ||= columns.first
    rows = ids_to_rows.values.sort_by { |row| [row[sort_column].to_s, row.id] }
    if sort_direction == "ascending" || sort_direction.blank?
      rows
    else
      rows.reverse
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
