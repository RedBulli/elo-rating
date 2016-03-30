class AddIndicesPlusConstraints < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :elos, :frames
    add_foreign_key :elos, :players
    add_foreign_key :players, :elos
    add_index :frames, :created_at
    change_column_null :elos, :player_id, false
    change_column_null :elos, :provisional, false
    change_column_null :elos, :rating, false
  end
end
