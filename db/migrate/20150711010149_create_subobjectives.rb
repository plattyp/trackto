class CreateSubobjectives < ActiveRecord::Migration
  def change
    create_table :subobjectives do |t|
      t.string :name
      t.text :description

      t.timestamps null: false
    end
  end
end
