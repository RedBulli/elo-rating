class CreateElos < ActiveRecord::Migration[5.0]
  def change
    create_table :elos do |t|
      t.integer :player_id
      t.decimal :rating, precision: 6, scale: 2
    end
  end
end
