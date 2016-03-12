require 'rails_helper'

RSpec.describe Elo, type: :model do
  let(:player1) { Player.create! name: 'Sampo' }
  let(:player2) { Player.create! name: 'Oskari' }
  let(:player3) { Player.create! name: 'Antti' }

  def create_frame
    Frame.create! player1_elo: player1.elo, player2_elo: player2.elo, winner: player1
  end

  it 'provisional? should return true when less than and false when more than 15 previous elos' do
    14.times { create_frame }
    expect(player1.elo.provisional?).to eql(true)
    create_frame
    expect(player1.elo.provisional?).to eql(false)
  end

  describe 'K-factor' do
    it 'is larger when players have provisional elos' do
      frame = Frame.create!(player1_elo: player1.elo, player2_elo: player2.elo, winner: player2)
      expect(player1.elo.rating).to eql(1485)
      expect(player2.elo.rating).to eql(1515)
    end

    it 'uses base when players do not have provisional elos' do
      15.times { create_frame }
      player1.elo.rating = 1500
      player2.elo.rating = 1500
      frame = Frame.create!(player1_elo: player1.elo, player2_elo: player2.elo, winner: player2)
      expect(player1.elo.rating).to eql(1495)
      expect(player2.elo.rating).to eql(1505)
    end

    it 'uses different factors if one has provisional elo' do
      15.times do
        create_frame
      end
      player1.elo.rating = 1500
      expect(player1.elo.k_factor(player3.elo)).to eql(5)
      expect(player3.elo.k_factor(player1.elo)).to eql(30)
    end
  end

  describe 'ev' do
    it 'is equal when both players have same rating' do
      expect(player1.elo.ev(player2.elo)).to eql(0.5)
      expect(player2.elo.ev(player1.elo)).to eql(0.5)
    end

    it '0.7 - 0.3 when 149 points difference' do
      player1.elo.rating = 1649
      expect(player1.elo.ev(player2.elo).round(2)).to eql(0.7)
      expect(player2.elo.ev(player1.elo).round(2)).to eql(0.3)
    end
  end
end
