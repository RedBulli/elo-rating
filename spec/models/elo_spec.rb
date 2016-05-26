require 'rails_helper'

RSpec.describe Elo, type: :model do
  let(:player1) { create(:player) }
  let(:player2) { create(:player) }

  def create_frame
    Frame::create_frame(
      winner: player1,
      breaker: player1,
      loser: player2,
      game_type: 'eight_ball'
    )
  end

  it 'provisional should return true when less than and false when more than 15 previous elos' do
    14.times { create_frame }
    expect(player1.elo.provisional).to eql(true)
    create_frame
    expect(player1.elo.provisional).to eql(false)
  end

  describe '#create_next_elo' do
    it 'doesn\'t create if elo doesn\'t have a frame' do
      expect(player1.elo.create_next_elo).to eql(nil)
    end

    it 'player cannot have more than one elo without frame' do
      frame = create_frame
      expect {
        frame.elos.first.create_next_elo
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'creates a new elo for the player' do
      frame = create(:frame)
      [player1, player2].each do |player|
        player.elo.frame = frame
        player.elo.breaker = player == player1
        player.elo.winner = player == player1
        player.elo.save!
      end
      elo_before = player1.elo
      expect{
        player1.elo.create_next_elo
      }.to change{Elo.count}.by(1)
      expect(elo_before).not_to eql(player1.elo)
      expect(elo_before.rating).to be < player1.elo.rating
    end

    it 'sets provisional to false if previos elo was not provisional' do
      player1.elo.update_attributes!(provisional: false)
      create_frame
      expect(player1.elo.provisional).to eql(false)
    end
  end

  describe '#opponent_elo' do
    it 'returns the opponent elo' do
      frame = create_frame
      expect(frame.elos[0].opponent_elo).to eql(frame.elos[1])
    end

    it 'raises if frame has only one player' do
      frame = create(:frame)
      player1.elo.frame = frame
      player1.elo.breaker = true
      player1.elo.winner = true
      player1.elo.save!
      expect{
        player1.elo.opponent_elo
      }.to raise_error(RuntimeError)
    end
  end

  describe 'validation with frame' do
    it 'only one elo can be winner' do
      frame = create_frame
      loser_elo = frame.loser_elo
      loser_elo.winner = true
      expect(loser_elo.validate).to eql(false)
    end

    it 'only one elo can be breaker' do
      frame = create_frame
      player2_elo = frame.player2_elo
      player2_elo.breaker = true
      expect(player2_elo.validate).to eql(false)
    end

    it 'elos cannot belong to the same player' do
      frame = create_frame
      player2_elo = frame.player2_elo
      player2_elo.player = frame.player1
      expect(player2_elo.validate).to eql(false)
    end
  end
end
