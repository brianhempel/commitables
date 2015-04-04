class Table < ActiveRecord::Base
  belongs_to :head, class_name: "Commit"

  validates :name, presence: :true

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

  def rows
    ids_to_rows = {}

    cell_changes.each do |change|
      case change
      when CellChange::Create, CellChange::Update
        row = (ids_to_rows[change.row_id] ||= new_row(id: change.row_id))
        row.cells[change.column_id] = change.cell_value
      end
    end

    row_changes.each do |change|
      case change
      when RowChange::Delete
        ids_to_rows.delete(change.row_id)
      end
    end

    ids_to_rows.values
  end

  def new_row(attrs = {})
    defaults = { id: SecureRandom.uuid, columns: columns, cells: {} }
    Row.new(defaults.merge(attrs))
  end

  def column_changes
    commits.flat_map(&:column_changes)
  end

  def row_changes
    commits.flat_map(&:row_changes)
  end

  def cell_changes
    commits.flat_map(&:cell_changes)
  end

  def commits
    [head].tap do |commits|
      until commits.last == Commit.root
        commits.push(commits.last.parent)
      end
    end.reverse
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
