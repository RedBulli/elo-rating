class Player < ActiveRecord::Base
  belongs_to :elo, autosave: true
  validates :name, length: { minimum: 1 }, uniqueness: { case_sensitive: false }

  def initialize(attributes={})
    super
    self.elo = Elo.new(player: self, rating: 1500)
  end
end
