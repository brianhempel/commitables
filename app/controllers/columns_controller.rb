class ColumnsController < ApplicationController
  def new
    @table  = Table.find(params[:table_id])
    @column = Column.new
  end

  def create
    @table  = Table.find(params[:table_id])
    @column = Column.new(column_params)

    @table.create_column!(@column)
    redirect_to @table

  rescue Commit::CommitFailed => e
    @error = e
    render :new
  end

  def edit
    @table  = Table.find(params[:table_id])
    @column = @table.columns.find { |col| col.id == params[:id] }
  end

  def update
    @table  = Table.find(params[:table_id])
    @column = @table.columns.find { |col| col.id == params[:id] }
    @column.name = column_params[:name]

    @table.update_column!(@column)
    redirect_to @table

  rescue Commit::CommitFailed => e
    @error = e
    render :new
  end

  def destroy
    @table  = Table.find(params[:table_id])
    @column = Column.new(id: params[:id])

    @table.delete_column!(@column)
    redirect_to @table

  rescue Commit::CommitFailed => e
    @error = e
    render "tables/show"
  end

  private

  def column_params
    params.require(:column).permit(:name)
  end
end
