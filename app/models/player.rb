class Player < ActiveRecord::Base
  belongs_to :elo, autosave: true
  validates :name, length: { minimum: 1 }, uniqueness: { case_sensitive: false }
  has_many :elos
  has_many :frames, through: :elos

  def initialize(attributes = {})
    super
    self.elo = Elo.new(player: self, rating: 1500, provisional: true)
  end

  def self.find_or_create_by_name(name)
    where('lower(name) = ?', name.downcase).first || create(name: name)
  end

  def merge_player(player)
    if frames_against_with(player).length > 0
      fail 'Merging players who have played against each other is not allowed'
    end
    ActiveRecord::Base.transaction do
      Elo.where(player: player).update_all(player_id: id)
      newest_elo = player.elo
      player.update_attribute('elo_id', nil)
      newest_elo.destroy!
      player.destroy!
    end
  end

  def performance
    this_week_elos = Player.first.elos.joins(:frame).merge(Frame.created_this_week)
    if this_week_elos.count > 0
      result = this_week_elos.reduce({total_opponents_ratings: 0.0, result: 0}) do |memo, elo|
        memo[:result] += elo.winner ? 1 : -1
        memo[:total_opponents_ratings] += elo.opponent_elo.rating
        memo
      end
      {
        performance: (result[:total_opponents_ratings] + 400 * result[:result]) / this_week_elos.count,
        frames: this_week_elos.count
      }
    end
  end

  def frames_count
    elos.size - 1
  end

  def win_count
    Elo.where(player_id: id, winner: true).count
  end

  def loss_count
    frames_count - win_count
  end

  def frames_against_with(player)
    Frame
      .joins(:elos)
      .where('elos.player_id = ? OR elos.player_id = ?', id, player.id)
      .group('frames.id')
      .having('count(frames.id) = 2')
  end
end
