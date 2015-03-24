class CreateObjectives < ActiveRecord::Migration
  def change
    create_table :objectives do |t|
      t.string :name
      t.text :description
      t.integer :targetgoal

      t.timestamps
    end
  end
end
