class CreateWires < ActiveRecord::Migration
  def change
    create_table :wires do |t|
      t.float :x1
      t.float :y1
      t.float :x2
      t.float :y2
      t.float :width
      t.references :layer
      t.references :board

      t.timestamps
    end
    add_index :wires, :board_id
  end
end
