class Frame < ActiveRecord::Base
  belongs_to :player1_elo, class_name: 'Elo'
  belongs_to :player2_elo, class_name: 'Elo'
  belongs_to :winner, class_name: 'Player'
  validates :player1_elo, :player2_elo, :winner, presence: true
  after_create :create_new_elos
  validate :elos_unique
  validates :game_type, inclusion: { in: %w(eight_ball nine_ball one_pocket) }
  validate :validate_winner_is_either_player
  validate :validate_different_players

  scope :created_this_week, -> { where('frames.created_at >= ?', Time.now.at_beginning_of_week) }
  scope :for_player, -> (player) do
    joins(player1_elo: :player, player2_elo: :player)
      .where('players.id = ? OR players_elos.id = ?', player.id, player.id)
  end

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

  def next_frame_for_player(player)
    Frame.for_player(player).where('frames.created_at > ?', created_at).order('frames.created_at ASC').first
  end

  def next_elo_for_player_elo(player_elo)
    next_frame = next_frame_for_player(player_elo.player)
    if next_frame
      if next_frame.player1_elo.player == player_elo.player
        next_frame.player1_elo
      elsif next_frame.player2_elo.player == player_elo.player
        next_frame.player2_elo
      else
        raise 'Player was not in the frame even though he should have been. This means queries went badly wrong. Shit'
      end
    else
      player_elo.player.elo
    end
  end

  def create_new_elos
    player1_elo.player.elo = Elo.create!(player: player1_elo.player, rating: player1_elo.rating + elo_change(player1_elo))
    player2_elo.player.elo = Elo.create!(player: player2_elo.player, rating: player2_elo.rating + elo_change(player2_elo))
    player1_elo.player.save
    player2_elo.player.save
  end

  def deletable?
    ![player1_elo.player, player2_elo.player].any? do |player|
      next_frame_for_player(player)
    end
  end

  def recalculate_elos
    next_elo_for_player_elo(player1_elo).update_attributes!(rating: player1_elo.rating + elo_change(player1_elo))
    next_elo_for_player_elo(player2_elo).update_attributes!(rating: player2_elo.rating + elo_change(player2_elo))
  end

  def opponent_elo_of_player(player)
    if player1_elo.player == player
      player2_elo
    else
      player1_elo
    end
  end

  def result(player_elo)
    if winner == player_elo.player
      1
    else
      0
    end
  end

  def opponent_elo(player_elo)
    if player_elo == player1_elo
      player2_elo
    else
      player1_elo
    end
  end

  private

  def validate_winner_is_either_player
    unless [player1_elo.player, player2_elo.player].include? winner
      errors.add(:winner, 'Winner has to be either player')
    end
  end

  def validate_different_players
    if player1_elo.player == player2_elo.player
      errors.add(:player2_elo, 'Player 2 is the same as player 1')
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

  def elo_change(player_elo)
    (result(player_elo) - player_elo.ev(opponent_elo(player_elo))) * player_elo.k_factor(opponent_elo(player_elo))
  end
end
