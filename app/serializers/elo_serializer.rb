class EloSerializer < ActiveModel::Serializer
  attributes :id, :rating, :winner, :breaker, :provisional
  belongs_to :player, serializer: PlayerSerializer
  belongs_to :frame
end
