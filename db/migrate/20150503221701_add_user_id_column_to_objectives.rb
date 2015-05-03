class AddUserIdColumnToObjectives < ActiveRecord::Migration
  def change
    add_column :objectives, :user_id, :integer
  end
end
