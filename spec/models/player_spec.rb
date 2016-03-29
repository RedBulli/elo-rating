require 'rails_helper'

RSpec.describe Player, type: :model do
  let(:player) { Player.create!(name: 'Sampo') }
  let(:alter_ego) { Player.create!(name: 'Bad Sampo') }
  let(:opponent) { Player.create!(name: 'Oskari') }

  it 'new player is created with a default rating' do
    expect(player.elo.rating).to eql(1500)
    expect(player.elo.provisional).to eql(true)
  end

  describe '#merge_player' do
    it 'merges the player with all the elos and frames' do
      Frame::create_frame(
        winner: player,
        breaker: player,
        loser: opponent,
        game_type: 'eight_ball'
      )
      Frame::create_frame(
        winner: opponent,
        breaker: alter_ego,
        loser: alter_ego,
        game_type: 'eight_ball'
      )
      Frame::create_frame(
        winner: alter_ego,
        breaker: alter_ego,
        loser: opponent,
        game_type: 'eight_ball'
      )
      Frame::create_frame(
        winner: player,
        breaker: player,
        loser: opponent,
        game_type: 'eight_ball'
      )
      player.merge_player(alter_ego)
      expect(Elo.where(player: player, winner: true).count).to eql(3)
    end

    it "doesn't allow merge if the players have played against each other" do
      Frame::create_frame(
        winner: player,
        breaker: player,
        loser: alter_ego,
        game_type: 'eight_ball'
      )
      expect {
        player.merge_player(alter_ego)
      }.to raise_error(RuntimeError)
    end

    it 'destroys the other player' do
      player.merge_player(alter_ego)
      expect(Player.find_by(id: alter_ego.id)).to eql(nil)
    end
  end

  describe '#performance' do
    it 'returns nil if no frames have been played' do
      expect(player.performance).to eql(nil)
    end

    it 'calculates the performance rating last week' do
      frame = Frame::create_frame(
        winner: player,
        breaker: player,
        loser: opponent,
        game_type: 'eight_ball'
      )
      frame.created_at = 1.5.week.ago
      frame.save
      frame = Frame::create_frame(
        winner: player,
        breaker: player,
        loser: opponent,
        game_type: 'eight_ball'
      )
      expect(player.performance[:performance]).to eql(1885)
    end
  end
end
