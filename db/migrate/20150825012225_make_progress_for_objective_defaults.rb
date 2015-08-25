class MakeProgressForObjectiveDefaults < ActiveRecord::Migration
  def change
    change_column :objectives, :progress, :integer, :default => 0
  end
end
