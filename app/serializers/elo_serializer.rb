class EloSerializer < ActiveModel::Serializer
  attributes :id, :rating, :winner, :breaker, :provisional
  belongs_to :player
  belongs_to :frame
end
