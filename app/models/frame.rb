class Frame < ActiveRecord::Base
  belongs_to :player1_elo, class_name: 'Elo'
  belongs_to :player2_elo, class_name: 'Elo'
  belongs_to :winner, class_name: 'Player'
  validates :player1_elo, :player2_elo, :winner, presence: true
  after_create :create_new_elos
  validate :elos_unique
  validates :game_type, inclusion: { in: %w(eight_ball nine_ball one_pocket) }
  validate :validate_winner_is_either_player

  def name
    "#{player1.name} - #{player2.name}"
  end

  def player1
    player1_elo.player
  end

  def player2
    player2_elo.player
  end

  def loser
    if player1 == winner
      player2
    else
      player1
    end
  end

  def create_new_elos
    player1_elo.player.elo = Elo.create!(player: player1_elo.player, rating: player1_elo.rating + elo_change(player1_elo))
    player2_elo.player.elo = Elo.create!(player: player2_elo.player, rating: player2_elo.rating + elo_change(player2_elo))
    player1_elo.player.save
    player2_elo.player.save
  end

  def deletable?
    ![player1_elo, player2_elo].any? do |player_elo|
      player_elo.player_has_newer_frames?
    end
  end

  def recalculate_elos
    player1_elo.next_elo.update_attributes!(rating: player1_elo.rating + elo_change(player1_elo))
    player2_elo.next_elo.update_attributes!(rating: player2_elo.rating + elo_change(player2_elo))
  end

  private

  def validate_winner_is_either_player
    unless [player1_elo.player, player2_elo.player].include? winner
      errors.add(:winner, 'Winner has to be either player')
    end
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

  def opponent_elo(player_elo)
    if player_elo == player1_elo
      player2_elo
    else
      player1_elo
    end
  end

  def elo_change(player_elo)
    (result(player_elo) - player_elo.ev(opponent_elo(player_elo))) * player_elo.k_factor(opponent_elo(player_elo))
  end

  def result(player_elo)
    if winner == player_elo.player
      1
    else
      0
    end
  end
end
