class AddElosCounter < ActiveRecord::Migration[5.0]
  def change
    add_column :players, :elos_count, :integer
    reversible do |dir|
      dir.up do
        Player.all.each { |p| Player.reset_counters(p.id, :elos) }
      end
    end
  end
end
