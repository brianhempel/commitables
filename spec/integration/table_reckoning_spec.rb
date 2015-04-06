require "rails_helper"

RSpec.describe "Reckoning up a table by its commits" do
  let(:table)       { create(:table) }
  let(:decoy_table) { create(:table) }

  describe "modifying rows" do
    it "starts out with none" do
      expect(table.columns).to be_empty
    end

    context "with added columns" do
      before do
        table.create_column!(Column.new(name: "Column 1"))
        table.create_column!(Column.new(name: "Column 2"))

        decoy_table.create_column!(Column.new(name: "Decoy Column"))
      end

      it "works" do
        expect(table.reload.columns.map(&:name)).to contain_exactly("Column 1", "Column 2")
      end

      it "allows renaming columns" do
        col_1 = table.columns.find { |col| col.name == "Column 1"}
        col_1.name = "Column The First"
        table.update_column!(col_1)

        expect(table.reload.columns.map(&:name)).to contain_exactly("Column The First", "Column 2")
      end

      it "allows deleting columns" do
        col_1 = table.columns.find { |col| col.name == "Column 1"}
        table.delete_column!(col_1)
        decoy_table.delete_column!(decoy_table.columns.first)

        expect(table.reload.columns.map(&:name)).to contain_exactly("Column 2")
      end
    end
  end

  describe "modifying rows" do
    let(:columns)       { table.columns }
    let(:decoy_columns) { decoy_table.columns }

    before do
      table.create_column!(Column.new(name: "Column 1"))
      table.create_column!(Column.new(name: "Column 2"))

      decoy_table.create_column!(Column.new(name: "Decoy Column"))
    end

    def row_values(*args)
      table.reload.rows(*args).map { |row| columns.map{|col| row[col].to_s} }
    end

    it "starts out with none" do
      expect(table.reload.rows.to_a).to be_empty
      expect(table.row_count).to eq(0)
    end

    context "with added rows" do
      before do
        row_1_cells = columns.map(&:id).zip(["Value 1,1", "Value 1,2"]).to_h
        row_2_cells = columns.map(&:id).zip(["Value 2,1", "Value 2,2"]).to_h
        row_1 = table.new_row(cells: row_1_cells)
        row_2 = table.new_row(cells: row_2_cells)

        table.create_row!(row_1)
        table.create_row!(row_2)

        decoy_row_cells = decoy_columns.map(&:id).zip(["Decoy Value"]).to_h
        decoy_row = decoy_table.new_row(cells: decoy_row_cells)

        decoy_table.create_row!(decoy_row)
      end

      it "works" do
        expect(table.row_count).to eq(2)
        expect(table.rows.count).to eq(2)
        expect(row_values.sort.first).to contain_exactly("Value 1,1", "Value 1,2")
        expect(row_values.sort.last).to  contain_exactly("Value 2,1", "Value 2,2")
      end

      describe "sorting" do
        before do
          row_3_cells = columns.map(&:id).zip(["Aaaaa", "Zzzzz"]).to_h
          row_3 = table.new_row(cells: row_3_cells)

          table.create_row!(row_3)
        end

        it "defaults to sorting by the first column, asc" do
          sorted_rows = row_values
          expect(sorted_rows.to_a).to eq([
            ["Aaaaa", "Zzzzz"],
            ["Value 1,1", "Value 1,2"],
            ["Value 2,1", "Value 2,2"],
          ])
        end

        it "can sort by a specified column, asc" do
          col_2 = columns.last
          sorted_rows = row_values(sort_column: col_2, sort_direction: "ascending")
          expect(sorted_rows.to_a).to eq([
            ["Value 1,1", "Value 1,2"],
            ["Value 2,1", "Value 2,2"],
            ["Aaaaa", "Zzzzz"],
          ])
        end

        it "can sort by a specified column, desc" do
          col_2 = columns.last
          sorted_rows = row_values(sort_column: col_2, sort_direction: "descending")
          expect(sorted_rows.to_a).to eq([
            ["Aaaaa", "Zzzzz"],
            ["Value 2,1", "Value 2,2"],
            ["Value 1,1", "Value 1,2"],
          ])
        end
      end

      it "allows modifying rows" do
        sort_column = columns.first
        row = table.rows(sort_column: sort_column).first
        row_cells = columns.map(&:id).zip(["New Value 1,1", "New Value 1,2"]).to_h
        row.cells = row_cells
        table.update_row!(row)

        expect(table.row_count).to eq(2)
        expect(table.rows.count).to eq(2)
        expect(row_values.sort.first).to contain_exactly("New Value 1,1", "New Value 1,2")
        expect(row_values.sort.last).to  contain_exactly("Value 2,1", "Value 2,2")
      end

      it "allows deleting rows...even after modification" do
        sort_column = columns.first
        row = table.rows(sort_column: sort_column).first
        row_cells = columns.map(&:id).zip(["New Value 1,1", "New Value 1,2"]).to_h
        row.cells = row_cells
        table.update_row!(row)
        table.delete_row!(row)

        expect(table.row_count).to eq(1)
        expect(table.rows.count).to eq(1)
        expect(row_values.first).to contain_exactly("Value 2,1", "Value 2,2")
      end
    end
  end
end
