require 'rails_helper'

RSpec.describe Frame, type: :model do
  let(:player1) { create(:player) }
  let(:player2) { create(:player) }
  let(:player3) { create(:player) }

  def create_frame
    Frame::create_frame(
      winner: player1,
      breaker: player1,
      loser: player2,
      game_type: 'eight_ball'
    )
  end

  it 'is deletable only if either of the player has not played frames after this' do
    frame = create_frame
    expect(frame.deletable?).to eql(true)
    frame2 = Frame::create_frame(
      winner: player2,
      breaker: player2,
      loser: player3,
      game_type: 'eight_ball'
    )
    expect(frame.deletable?).to eql(false)
    expect(frame2.deletable?).to eql(true)
  end

  describe '#create_frame' do
    it 'creates new elos for players' do
      create_frame
      expect(player1.elo.rating > player2.elo.rating).to eql(true)
    end

    it 'does not allow same player for both elos' do
      expect {
        Frame::create_frame(
          winner: player2,
          breaker: player3,
          loser: player1,
          game_type: 'eight_ball'
        )
      }.to raise_error
    end

    describe 'game_type' do
      it 'does not allow incorrect game types' do
        expect {
          Frame::create_frame(
            winner: player1,
            breaker: player1,
            loser: player2,
            game_type: 'shiet'
          )
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
