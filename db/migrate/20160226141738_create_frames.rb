class CreateFrames < ActiveRecord::Migration[5.0]
  def change
    create_table :frames do |t|
      t.integer :player1_elo_id, null: false
      t.integer :player2_elo_id, null: false
      t.integer :winner_id, null: false
      t.timestamps
    end
  end
end
