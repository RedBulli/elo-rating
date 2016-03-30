class ChangeEloToFramePlayer < ActiveRecord::Migration[5.0]
  class Frame < ActiveRecord::Base
    belongs_to :winner, class_name: 'Player'
    belongs_to :player1_elo, class_name: 'Elo'
    belongs_to :player2_elo, class_name: 'Elo'
    scope :for_player, -> (player) do
      joins(player1_elo: :player, player2_elo: :player)
        .where('players.id = ? OR players_elos.id = ?', player.id, player.id)
    end
  end

  class Player < ActiveRecord::Base
    belongs_to :elo
  end

  class Elo < ActiveRecord::Base
    belongs_to :player
    scope :with_frames, -> { joins('LEFT OUTER JOIN frames ON (frames.player1_elo_id = elos.id OR frames.player2_elo_id = elos.id)') }
  end

  def change
    add_column :elos, :frame_id, :integer
    add_column :elos, :winner, :boolean
    add_column :elos, :breaker, :boolean
    add_column :elos, :provisional, :boolean

    reversible do |dir|
      dir.up do
        up_migrate
      end
    end
  end

  def up_migrate
    Elo.all.each do |elo|
      frame = Frame.where('player1_elo_id = ? OR player2_elo_id = ?', elo.id, elo.id).first
      if frame
        elo.frame_id = frame.id
        elo.winner = frame.winner_id == elo.player_id
        elo.breaker = frame.player1_elo == elo
        elo.provisional = provisional?(elo, frame)
      else
        elo.provisional = provisional?(elo, nil)
      end
      elo.save
    end
  end

  def provisional?(elo, frame)
    frame_count =
      if frame
        Elo
          .with_frames
          .where('elos.player_id = ? AND frames.created_at < ?', elo.player_id, frame.created_at)
          .count
      else
        Elo.where('player_id = ?', elo.player_id).count - 1
      end
    frame_count < 15
  end
end
