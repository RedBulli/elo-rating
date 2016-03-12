class AddGameTypeToFrame < ActiveRecord::Migration[5.0]
  def change
    add_column :frames, :game_type, :string, default: 'eight_ball', null: false
  end
end
