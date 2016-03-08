class Frame < ActiveRecord::Base
  belongs_to :player1_elo, class_name: 'Elo'
  belongs_to :player2_elo, class_name: 'Elo'
  belongs_to :winner, class_name: 'Player'
  validates :player1_elo, :player2_elo, :winner, presence: true
  after_create :create_new_elos
  validate :elos_unique

  def name
    "#{player1.name} - #{player2.name}"
  end

  def player1
    player1_elo.player
  end

  def player2
    player2_elo.player
  end

  def create_new_elos
    player1_elo.player.elo = Elo.create!(player: player1_elo.player, rating: player1_elo.rating + elo_change)
    player2_elo.player.elo = Elo.create!(player: player2_elo.player, rating: player2_elo.rating - elo_change)
    player1_elo.player.save
    player2_elo.player.save
  end

  def deletable?
    ![player1_elo, player2_elo].any? do |player_elo|
      elo_player_has_newer_frames(player_elo)
    end
  end

  def recalculate_elos
    next_elo(player1_elo).update_attributes!(rating: player1_elo.rating + elo_change)
    next_elo(player2_elo).update_attributes!(rating: player2_elo.rating - elo_change)
  end

  private

  def next_elo(player_elo)
    Elo.where('player_id = ? AND id > ?', player_elo.player.id, player_elo.id).order('id ASC').first
  end

  def elo_player_has_newer_frames(player_elo)
    Elo.where('player_id = ? AND id > ? AND id < ?', player_elo.player.id, player_elo.id, player_elo.player.elo).exists?
  end

  def elos_unique
    frames1 = Frame.where('player1_elo_id IN (?, ?)', player1_elo.id, player2_elo.id).to_a
    unless frames1 == [] || frames1 == [self]
      errors.add(:player1_elo, 'Player 1 elo is already used in another frame')
    end
    frames2 = Frame.where('player2_elo_id IN (?, ?)', player1_elo.id, player2_elo.id).to_a
    unless frames2 == [] || frames2 == [self]
      errors.add(:player2_elo, 'Player 2 elo is already used in another frame')
    end
  end

  def elo_change
    (result - ev) * k_factor
  end

  def result
    if winner == player1
      1
    else
      0
    end
  end

  def ev
    if elo_difference < 0
      1 - favorite_ev
    else
      favorite_ev
    end
  end

  def favorite_ev
    1.0/(1.0+10.0**(elo_difference.to_d.abs/400.0))
  end

  def elo_difference
    player2_elo.rating - player1_elo.rating 
  end

  def k_factor
    10.0
  end
end
