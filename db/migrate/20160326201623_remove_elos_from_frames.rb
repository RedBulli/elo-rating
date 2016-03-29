class RemoveElosFromFrames < ActiveRecord::Migration[5.0]
  def change
    remove_column :frames, :player1_elo_id
    remove_column :frames, :player2_elo_id
    remove_column :frames, :winner_id
  end
end
