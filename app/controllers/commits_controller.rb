class CommitsController < ApplicationController
  def index
    @table = find_table
    @commits = @table.commits
  end

  private

  def find_table
    if commit = Commit.find_by(id: params[:table_id].hex_to_bin)
      Table.new(head: commit, name: params[:table_id])
    else
      Table.find(params[:table_id])
    end
  end
end
