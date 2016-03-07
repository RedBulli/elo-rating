require 'rails_helper'

RSpec.describe Player, type: :model do
  it 'new player is created with an Elo' do
    player = Player.create!(name: 'Sampo')
    expect(player.elo.player).to eql(player)
  end
end
