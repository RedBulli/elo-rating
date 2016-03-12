require 'rails_helper'

RSpec.describe Frame, type: :model do
  let(:player1) { Player.create! name: 'Sampo' }
  let(:player2) { Player.create! name: 'Oskari' }
  let(:player3) { Player.create! name: 'Antti' }

  def create_frame
    Frame.create! player1_elo: player1.elo, player2_elo: player2.elo, winner: player1, game_type: :eight_ball
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

  describe 'game_type' do
    it 'defaults to eight_ball' do
      frame = Frame.new(player1_elo: player1.elo, player2_elo: player2.elo, winner: player2)
      expect(frame.game_type).to eql('eight_ball')
    end

    it 'does not allow incorrect game types' do
      expect {
        Frame.create!(player1_elo: player1.elo, player2_elo: player2.elo, winner: player2, game_type: 'shiet')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
