require 'rails_helper'

RSpec.describe Frame, type: :model do
  it 'creates new elos for players after creation' do
    p1 = Player.create!(name: 'Sampo')
    p2 = Player.create!(name: 'Oskari')
    frame = Frame.create!(player1_elo: p1.elo, player2_elo: p2.elo, winner: p2)
    expect(p1.elo.rating).to eql(1495)
    expect(p2.elo.rating).to eql(1505)
  end

  it 'is deletable only if either of the player has not played frames after this' do
    p1 = Player.create!(name: 'Sampo')
    p2 = Player.create!(name: 'Oskari')
    frame = Frame.create!(player1_elo: p1.elo, player2_elo: p2.elo, winner: p2)
    expect(frame.deletable?).to eql(true)
    p3 = Player.create!(name: 'Antti')
    frame2 = Frame.create!(player1_elo: p3.elo, player2_elo: p2.elo, winner: p2)
    expect(frame.deletable?).to eql(false)
    expect(frame2.deletable?).to eql(true)
  end
end
