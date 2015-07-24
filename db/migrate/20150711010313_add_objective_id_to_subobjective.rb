class AddObjectiveIdToSubobjective < ActiveRecord::Migration
  def change
    add_column :subobjectives, :objective_id, :integer
  end
end
