class RowsController < ApplicationController
  def new
    @table = Table.find(params[:table_id])
    @row   = @table.new_row
  end

  def create
    @table  = Table.find(params[:table_id])
    @row    = @table.new_row(cells: row_params[:cells])

    @table.create_row!(@row)
    redirect_to @table

  rescue Commit::CommitFailed => e
    @error = e
    render :new
  end

  def edit
    @table = Table.find(params[:table_id])
    @row   = @table.rows.find { |row| row.id == params[:id] }
  end

  def update
    @table = Table.find(params[:table_id])
    @row   = @table.rows.find { |row| row.id == params[:id] }
    @row.cells = row_params[:cells]

    @table.update_row!(@row)
    redirect_to @table

  rescue Commit::CommitFailed => e
    @error = e
    render :new
  end

  def destroy
    @table = Table.find(params[:table_id])
    @row   = Row.new(id: params[:id])

    @table.delete_row!(@row)
    redirect_to @table

  rescue Commit::CommitFailed => e
    @error = e
    render "tables/show"
  end

  private

  def row_params
    params.require(:row)
  end
end
