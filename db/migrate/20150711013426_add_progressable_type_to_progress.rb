class AddProgressableTypeToProgress < ActiveRecord::Migration
  def change
    add_column :progresses, :progressable_type, :string
    add_column :progresses, :progressable_id, :int
    remove_column :progresses, :objective_id
  end
end
