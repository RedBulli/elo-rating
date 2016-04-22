class PlayerSerializer < ActiveModel::Serializer
  attributes :id, :name
  has_one :elo
end
