class EloSerializer < ActiveModel::Serializer
  attributes :id, :rating
  belongs_to :player
  belongs_to :frame
end
