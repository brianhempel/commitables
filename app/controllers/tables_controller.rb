class TablesController < ApplicationController
  def index
    @tables = Table.all
  end

  def show
    @table = find_table
  end

  def new
    @table = Table.new
  end

  def create
    @table = Table.new(table_params)

    @table.head = if params[:head_id].present?
      Commit.find(params[:head_id].hex_to_bin)
    else
      Commit.root
    end

    if @table.save
      redirect_to @table
    else
      render :new
    end
  end

  private

  def find_table
    if commit = Commit.find_by(id: params[:id].hex_to_bin)
      Table.new(head: commit, name: params[:id])
    else
      Table.find(params[:id])
    end
  end

  def table_params
    params.require(:table).permit(:id, :name)
  end
end
