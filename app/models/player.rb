class Player < ActiveRecord::Base
  belongs_to :elo, autosave: true
  validates :name, length: { minimum: 1 }, uniqueness: { case_sensitive: false }
  has_many :elos

  def initialize(attributes={})
    super
    self.elo = Elo.new(player: self, rating: 1500)
  end

  def self.find_or_create_by_name(name)
    where('lower(name) = ?', name.downcase).first || create(name: name)
  end

  def merge_player(player)
    if frames_against_with(player).count > 0
      raise 'Merging players who have played against each other is not allowed'
    end
    ActiveRecord::Base.transaction do
      player.elo.destroy
      Frame.where(winner: player).update_all(winner_id: self.id)
      Elo.where(player: player).update_all(player_id: self.id)
      Player.destroy(player.id)
    end
  end

  def performance
    frames = frames_for_this_week
    if frames.count > 0
      result = frames.reduce({total_opponents_ratings: 0.0, result: 0}) do |memo, frame|
        memo[:result] +=
          if frame.winner == self
            1
          else
            -1
          end
        memo[:total_opponents_ratings] += frame.opponent_elo_of_player(self).rating
        memo
      end
      {
        performance: (result[:total_opponents_ratings] + 400 * result[:result]) / frames.count,
        frames: frames.count
      }
    end
  end

  def frames_count
    elos.count - 1
  end

  def win_count
    Frame.where(winner: self).count
  end

  def loss_count
    frames_count - win_count
  end

  private

  def frames_for_this_week
    Frame
      .created_this_week
      .joins(player1_elo: :player, player2_elo: :player)
      .where('players.id = ? OR players_elos.id = ?', id, id)
  end

  def frames_against_with(player)
    Frame
      .joins(player1_elo: :player, player2_elo: :player)
      .where('(players.id = ? OR players.id = ?) AND (players_elos.id = ? OR players_elos.id = ?)', id, player.id, id, player.id)
  end
end
