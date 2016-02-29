class Frame < ActiveRecord::Base
  belongs_to :player1_elo, class_name: 'Elo'
  belongs_to :player2_elo, class_name: 'Elo'
  belongs_to :winner, class_name: 'Player'
  validates :player1_elo, :player2_elo, :winner, presence: true
  after_create :create_new_elos
  validate :elos_unique

  def name
    "#{player1_elo.player.name} - #{player2_elo.player.name}"
  end

  def create_new_elos
    player1_elo.player.elo = Elo.create!(player: player1_elo.player, rating: player1_elo.rating + elo_change)
    player2_elo.player.elo = Elo.create!(player: player2_elo.player, rating: player2_elo.rating - elo_change)
    player1_elo.player.save
    player2_elo.player.save
  end

  private

  def elos_unique
    if Frame.where('player1_elo_id IN (?, ?)', player1_elo.id, player2_elo.id).exists?
      errors.add(:player1_elo, 'Player 1 elo is already used in another frame')
    end
    if Frame.where('player2_elo_id IN (?, ?)', player1_elo.id, player2_elo.id).exists?
      errors.add(:player2_elo, 'Player 2 elo is already used in another frame')
    end
  end

  def elo_change
    (result - ev) * k_factor
  end

  def result
    if winner == player1_elo.player
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
