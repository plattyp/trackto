class AddTargetDateColumnToObjectives < ActiveRecord::Migration
  def change
    add_column :objectives, :targetdate, :date
  end
end
