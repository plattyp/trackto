class AddArchivedColumnToObjective < ActiveRecord::Migration
  def change
    add_column :objectives, :archived, :boolean
  end
end
