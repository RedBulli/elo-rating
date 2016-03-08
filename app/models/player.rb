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
end
