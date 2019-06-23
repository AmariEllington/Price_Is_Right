class CreateAnswer < ActiveRecord::Migration[5.2]
  def change
    create_table :answers do |t|
      t.integer :game_id
      t.string :item
      t.float :price
      t.float :guess
      t.timestamps
    end
  end
end
