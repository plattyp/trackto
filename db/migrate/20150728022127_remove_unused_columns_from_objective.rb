class RemoveUnusedColumnsFromObjective < ActiveRecord::Migration
  def change
    remove_column :objectives, :targetgoal
    remove_column :objectives, :targetdate
  end
end
