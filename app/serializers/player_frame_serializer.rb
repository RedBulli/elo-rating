class PlayerFrameSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :elo, :opponent_elo

  def opponent_elo
    object.opponent_elo_of_player(player)
  end

  def elo
    object.elo_of_player(player)
  end
end
