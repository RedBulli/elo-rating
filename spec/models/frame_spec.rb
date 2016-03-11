require 'rails_helper'

RSpec.describe Frame, type: :model do
  let(:player1) { Player.create! name: 'Sampo' }
  let(:player2) { Player.create! name: 'Oskari' }
  let(:player3) { Player.create! name: 'Antti' }

  def create_frame
    Frame.create! player1_elo: player1.elo, player2_elo: player2.elo, winner: player1
  end

  it 'creates new elos for players after creation' do
    frame = Frame.create!(player1_elo: player1.elo, player2_elo: player2.elo, winner: player2)
    expect(player1.elo.rating < player2.elo.rating).to eql(true)
  end

  it 'is deletable only if either of the player has not played frames after this' do
    frame = Frame.create!(player1_elo: player1.elo, player2_elo: player2.elo, winner: player2)
    expect(frame.deletable?).to eql(true)
    frame2 = Frame.create!(player1_elo: player3.elo, player2_elo: player2.elo, winner: player2)
    expect(frame.deletable?).to eql(false)
    expect(frame2.deletable?).to eql(true)
  end

  it 'create uses larger K-factor when players have provisional elos' do
    frame = Frame.create!(player1_elo: player1.elo, player2_elo: player2.elo, winner: player2)
    expect(player1.elo.rating).to eql(1485)
    expect(player2.elo.rating).to eql(1515)
  end

  it 'creates uses base K-factor when players do not have provisional elos' do
    15.times do
      create_frame
    end
    player1.elo.rating = 1500
    player2.elo.rating = 1500
    frame = Frame.create!(player1_elo: player1.elo, player2_elo: player2.elo, winner: player2)
    expect(player1.elo.rating).to eql(1495)
    expect(player2.elo.rating).to eql(1505)
  end

  it 'creates uses different K-factors if one has provisional elo' do
    15.times do
      create_frame
    end
    player1.elo.rating = 1500
    frame = Frame.create!(player1_elo: player1.elo, player2_elo: player3.elo, winner: player1)
    expect(player1.elo.rating).to eql(1505)
    expect(player3.elo.rating).to eql(1485)
  end
end
