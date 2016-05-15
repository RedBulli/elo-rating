class PlayerSerializerWithFrames < ActiveModel::Serializer
  attributes :id, :name, :elos_count
  belongs_to :elo
  has_many :frames
end
