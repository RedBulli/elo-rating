class Elo < ActiveRecord::Base
  belongs_to :player
  validates :player, presence: true
  scope :with_frames, -> { joins('LEFT OUTER JOIN frames ON (frames.player1_elo_id = elos.id OR frames.player2_elo_id = elos.id)') }
  scope :for_player_id, -> (player_id) { where('elos.player_id = ?', player_id) }

  BASE_K_FACTOR = 10

  def name
    "#{player.name} (#{rating.to_i})"
  end

  def provisional?
    past_elos_count < 15
  end

  def frame
    Frame.where('player1_elo_id = ? OR player2_elo_id = ?', id, id).first
  end

  def past_elos_count
    if frame
      Elo
        .with_frames
        .for_player_id(player_id)
        .where('frames.created_at < ?', frame.created_at)
        .count
    else
      player.elos.count - 1
    end
  end

  def k_factor(opponent_elo)
    if provisional?
      BASE_K_FACTOR * 3
    elsif opponent_elo.provisional?
      BASE_K_FACTOR / 2
    else
      BASE_K_FACTOR
    end
  end

  def ev(opponent_elo)
    rating_diff = (opponent_elo.rating-rating).to_d
    (1.0/(1.0+10.0**(rating_diff/400.0))).to_d
  end
end
