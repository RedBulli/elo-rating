class Frame < ActiveRecord::Base
  has_many :elos
  validates :game_type, inclusion: { in: %w(eight_ball nine_ball one_pocket) }
  scope :created_this_week, -> { where('frames.created_at >= ?', Time.now.at_beginning_of_week) }
  has_many :players, through: :elos
  scope :for_player, -> (player_id) { joins(:players).where(players: {id: player_id}) }

  def self.create_frame(options)
    Frame.transaction do
      frame = Frame.create!(game_type: options[:game_type])
      [options[:winner], options[:loser]].each do |player|
        player.elo.frame = frame
        player.elo.breaker = options[:breaker] == player
        player.elo.winner = options[:winner] == player
        player.elo.save!
      end
      [options[:winner], options[:loser]].each do |player|
        player.elo.create_next_elo
      end
      frame
    end
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

  def player1_elo
    elos.find_by(breaker: true)
  end

  def player2_elo
    elos.find_by(breaker: false)
  end

  def winner
    winner_elo.player
  end

  def loser
    loser_elo.player
  end

  def winner_elo
    elos.find_by(winner: true)
  end

  def loser_elo
    elos.find_by(winner: false)
  end

  def next_frame_for_player(player)
    player.frames.where('frames.created_at > ?', created_at).order('frames.created_at ASC').first
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
    !players.any? do |player|
      next_frame_for_player(player)
    end
  end

  def recalculate_elos
    elos.each(&:recalculate_elo_change)
  end

  def elo_of_player(player)
    if player1_elo.player == player
      player1_elo
    else
      player2_elo
    end
  end

  def opponent_elo_of_player(player)
    if player1_elo.player == player
      player2_elo
    else
      player1_elo
    end
  end

  def result(player)
    if winner == player
      1
    else
      0
    end
  end

  def opponent(player)
    if player == player1_elo
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
end
