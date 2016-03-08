class Player < ActiveRecord::Base
  belongs_to :elo, autosave: true
  validates :name, length: { minimum: 1 }, uniqueness: { case_sensitive: false }

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
      Frame.where(winner: player).update_all(winner_id: self.id)
      Elo.where(player: player).update_all(player_id: self.id)
    end
  end

  private

  def frames_against_with(player)
     Frame
      .joins(player1_elo: :player, player2_elo: :player)
      .where('(players.id = ? OR players.id = ?) AND (players_elos.id = ? OR players_elos.id = ?)', id, player.id, id, player.id)
  end
end
