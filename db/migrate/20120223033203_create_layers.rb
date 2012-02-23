class CreateLayers < ActiveRecord::Migration
  def change
    create_table :layers do |t|
      t.integer :number
      t.string :name
      t.integer :color

      t.timestamps
    end
  end
end
