class Commit < ActiveRecord::Base
  ROOT_ID = 0.chr * 32

  belongs_to :parent, class_name: "Commit"
  has_many :column_changes, dependent: :destroy
  has_many :row_changes,    dependent: :destroy
  has_many :cell_changes,   dependent: :destroy

  def self.root
    @root ||= Commit.find_or_create_by!(id: ROOT_ID, parent_id: ROOT_ID)
  end

  def self.create_off_parent_id!(parent_id)
    Commit.new(parent_id: parent_id).create! do |commit|
      yield commit
    end
  end

  # Includes the commit with the given ID
  def self.ancestors_of_id(id)
    all.from(<<-SQL)
      (
        WITH RECURSIVE ancestors_commits(id, parent_id, n) AS (
            SELECT commits.id, commits.parent_id, 0::bigint
              FROM commits
              WHERE commits.id = E'\\\\x#{id.bin_to_hex}'
          UNION ALL
            SELECT commits.id, commits.parent_id, n-1
              FROM ancestors_commits, commits
              WHERE commits.id = ancestors_commits.parent_id
              AND ancestors_commits.id != E'\\\\x0000000000000000000000000000000000000000000000000000000000000000'
        )
        SELECT id, parent_id, n
        FROM ancestors_commits
      ) commits
    SQL
  end

  def and_ancestors
    Commit.ancestors_of_id(self.id)
  end

  concerning :DSL do
    def create!
      yield self
      changes_to_commit.each(&:validate!)
      generate_id
      changes_to_commit.each { |change| change.commit = self }
      changes_to_commit.each(&:save!)
      save!
      self
    rescue ActiveRecord::RecordInvalid => e
      raise Commit::CommitFailed.new(e.message)
    end

    def create_column(column)
      changes_to_commit << ColumnChange::Create.from_column(column)
    end

    # `update_column` is a Rails method :(
    def update_table_column(column)
      changes_to_commit << ColumnChange::Update.from_column(column)
    end

    def delete_column(column)
      changes_to_commit << ColumnChange::Delete.from_column(column)
    end

    def create_row(row)
      row.cells.each do |cell|
        changes_to_commit << CellChange::Create.from_row_and_cell(row, cell)
      end
    end

    def update_row(row)
      row.cells.each do |cell|
        changes_to_commit << CellChange::Update.from_row_and_cell(row, cell)
      end
    end

    def delete_row(row)
      changes_to_commit << RowChange::Delete.from_row(row)
    end
  end

  def generate_id
    raise "Already committed!" unless new_record?
    self.id = secure_hash
  end

  def changes_to_commit
    raise "Already committed!" unless new_record?
    @changes_to_commit ||= []
  end

  def secure_hash
    Digest::SHA256.digest(secure_hash_parts.join)
  end

  def secure_hash_parts
    [parent_id] + changes_to_commit.map(&:secure_hash).sort
  end
end
