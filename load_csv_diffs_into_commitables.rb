require "csv"

CSV_PATHS = Dir.glob("michigan_csv_diff/*.csv").sort
# CSV_PATHS = ["michigan_csv_diff/michigan-150404.osm-to-michigan-150404.updated.osm.csv"]

COMMIT_SIZE = 1..3

ENV['RAILS_ENV'] ||= "development"
require File.expand_path("../config/environment", __FILE__)

table_name = ["All Over The Hand(s)", ARGV[0]].compact.join(" ")

table = Table.find_by(name: table_name) || Table.new(head: Commit.root, name: table_name)

if table.new_record?
  _, *headers = CSV.parse(File.read(CSV_PATHS.first)).first

  headers.each do |header|
    column = Column.new(name: header)
    table.create_column!(column)
  end
end

columns = table.columns

osm_id_to_row_id = {}

id_col = columns.find { |col| col.name =~ /\Aid\z/i }
table.rows.each do |row|
  osm_id = row[id_col].to_s
  osm_id_to_row_id[osm_id] = row.id
end

CSV_PATHS.each do |csv_path|
  csv = CSV.parse(File.read(csv_path))
  csv.shift # headers

  while csv.any?
    table.create_commit! do |commit|
      rows = csv.shift(rand(COMMIT_SIZE))
      rows.each do |row|
        print row.to_csv

        change_type, *cells = row

        row_id = osm_id_to_row_id[cells[0]] || SecureRandom.uuid
        osm_id_to_row_id[cells[0]] = row_id

        case change_type
        when "create", "update"
          cells_hash = columns.map(&:id).zip(cells).to_h
          table_row = Row.new(id: row_id, columns: columns, cells: cells_hash)
          if change_type == "create"
            commit.create_row(table_row)
          else
            commit.update_row(table_row)
          end
        when "delete"
          table_row = Row.new(id: row_id)
          commit.delete_row(table_row)
        end
      end
    end
    puts table.head_id.bin_to_hex
  end
end
