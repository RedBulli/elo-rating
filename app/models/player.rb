class Player < ActiveRecord::Base
  belongs_to :elo
  after_create :create_elo
  validates :name, length: { minimum: 1 }, uniqueness: { case_sensitive: false }
end
