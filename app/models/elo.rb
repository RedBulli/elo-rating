require 'elo_calculator'

class Elo < ActiveRecord::Base
  belongs_to :player
  belongs_to :frame, optional: true
  validates :rating, presence: true
  validates :player, uniqueness: {scope: :frame}
  validates :provisional, inclusion: { in: [true, false] }

  with_options if: :frame do |elo|
    elo.validates :winner, uniqueness: {scope: :frame}
    elo.validates :breaker, uniqueness: {scope: :frame}
  end

  def create_next_elo
    if frame
      player.elo = Elo.create!(
        player: player,
        rating: rating + calculator.elo_change(winner ? 1 : 0),
        provisional: provisional == false ? false : past_elos_count < 14
      )
      player.save!
      player.elo
    end
  end

  def opponent_elo
    frame_elos = frame.elos.to_a
    if frame_elos.length != 2
      raise 'Frame has to have 2 elos'
    else
      frame_elos.find { |elo| elo != self }
    end
  end

  def name
    "#{player.name} (#{rating.to_i})"
  end

  def past_elos_count
    if frame
      Elo
        .joins(:frame)
        .where('elos.player_id = ? AND frames.created_at < ?', player.id, frame.created_at)
        .count
    else
      player.elos.count - 1
    end
  end

  def next_elo
    next_frame_elo || player.elo
  end

  def next_frame_elo
    Elo
      .joins(:frame)
      .where('elos.player_id = ? AND frames.created_at > ?', player.id, frame.created_at)
      .order('frames.created_at ASC')
      .first
  end

  def recalculate_elo_change
    elo = next_elo
    elo.rating = rating + calculator.elo_change(winner ? 1 : 0)
    elo.save
  end

  def calculator
    EloCalculator.new(self.to_calculator_hash, opponent_elo.to_calculator_hash)
  end

  def to_calculator_hash
    {
      rating: rating,
      provisional: provisional
    }
  end
end
