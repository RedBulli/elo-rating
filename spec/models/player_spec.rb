require 'rails_helper'

RSpec.describe Player, type: :model do
  it 'new player is created with an Elo' do
    player = Player.create!(name: 'Sampo')
    expect(player.elo.player).to eql(player)
  end

  describe '#merge_player' do
    it 'merges the player with all the elos and frames' do
      player = Player.create!(name: 'Sampo')
      alter_ego = Player.create!(name: 'Bad Sampo')
      opponent = Player.create!(name: 'Oskari')
      Frame.create!(player1_elo: player.elo, player2_elo: opponent.elo, winner: player, game_type: 'eight_ball')
      Frame.create!(player1_elo: alter_ego.elo, player2_elo: opponent.elo, winner: opponent, game_type: 'eight_ball')
      Frame.create!(player1_elo: alter_ego.elo, player2_elo: opponent.elo, winner: alter_ego, game_type: 'eight_ball')
      Frame.create!(player1_elo: player.elo, player2_elo: opponent.elo, winner: player, game_type: 'eight_ball')
      player.merge_player(alter_ego)
      expect(Frame.where(winner: player).count).to eql(3)
    end

    it "doesn't allow merge if the players have played against each other" do
      player = Player.create!(name: 'Sampo')
      alter_ego = Player.create!(name: 'Bad Sampo')
      Frame.create!(player1_elo: player.elo, player2_elo: alter_ego.elo, winner: player, game_type: 'eight_ball')
      expect {
        player.merge_player(alter_ego)
      }.to raise_error(RuntimeError)
    end

    it 'destroys the other player' do
      player = Player.create!(name: 'Sampo')
      alter_ego = Player.create!(name: 'Bad Sampo')
      player.merge_player(alter_ego)
      expect(Player.find_by(id: alter_ego.id)).to eql(nil)
    end
  end
end
