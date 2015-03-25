class AddObjectiveIdColumnToProgress < ActiveRecord::Migration
  def change
    add_column :progresses, :objective_id, :integer
  end
end
