class Elo < ActiveRecord::Base
  belongs_to :player
  validates :player, presence: true

  def name
    "#{player.name} (#{rating})"
  end
end
