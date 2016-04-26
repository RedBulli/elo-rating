class PlayerSerializer < ActiveModel::Serializer
  attributes :id, :name, :elos_count
  belongs_to :elo
end
