class AddProgressColumnToObjectives < ActiveRecord::Migration
  def change
    add_column :objectives, :progress, :integer
  end
end
