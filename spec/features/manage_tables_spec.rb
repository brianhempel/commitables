require 'rails_helper'

RSpec.describe "Managing Commitables" do
  describe "listing tables" do
    let!(:table_1) { create(:table, name: "Table 1") }
    let!(:table_2) { create(:table, name: "Table 2") }

    before { visit tables_path }

    it "navigating to the page" do
      visit root_path
      expect(page.current_path).to eq(tables_path)
    end

    it "shows all the tables" do
      expect(page).to have_content("Table 1")
      expect(page).to have_content("Table 2")
    end

    it "links to the tables" do
      click_on "Table 1"
      expect(page.current_path).to eq(table_path(table_1))
    end
  end
end
