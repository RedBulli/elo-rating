class Elo < ActiveRecord::Base
  belongs_to :player
  validates :player, presence: true

  BASE_K_FACTOR = 10

  def name
    "#{player.name} (#{rating.to_i})"
  end

  def provisional?
    past_elos_count < 15
  end

  def frame
    Frame.where('player1_elo_id = ? OR player2_elo_id = ?', id, id)
  end

  def next_elo
    Elo.where('player_id = ? AND id > ?', player.id, id).order('id ASC').first
  end

  def past_elos_count
    Elo.where('player_id = ? AND id < ?', player.id, id).count
  end

  def player_has_newer_frames?
    Elo.where('player_id = ? AND id > ? AND id < ?', player.id, id, player.elo).exists?
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
