require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe RecalculateElos, type: :worker do
  it 'should recalculate elos' do
    players = %w(Sampo Oskari Antti).map do |name|
      Player.create!(name: name)
    end
    frames = [[0,1], [0,2], [1,2]].map do |players_indexes|
      Frame.create!(
        player1_elo: players[players_indexes[0]].elo,
        player2_elo: players[players_indexes[1]].elo,
        winner: players[players_indexes[0]],
        game_type: 'eight_ball'
      )
    end
    expect(players.sort_by { |p| -p.elo.rating }).to eql([players[0], players[1], players[2]])
    frames[0].winner = players[1]
    frames[0].save
    Sidekiq::Testing.inline! do
      RecalculateElos.perform_async
    end
    reloaded_players = players.map do |player|
      player.reload
      player
    end
    expect(reloaded_players.sort_by { |p| -p.elo.rating }).to eql([players[1], players[0], players[2]])
  end

  it 'should recalculate elos correctly when merging players' do
    players = %w(Sampo Oskari Antti).map do |name|
      Player.create!(name: name)
    end
    frames = [[2,0], [0,1], [2, 0]].map do |players_indexes|
      Frame.create!(
        player1_elo: players[players_indexes[0]].elo,
        player2_elo: players[players_indexes[1]].elo,
        winner: players[players_indexes[0]],
        game_type: 'eight_ball'
      )
    end
    expect(players.sort_by { |p| -p.elo.rating }).to eql([players[2], players[0], players[1]])
    players[1].merge_player(players[2])
    Sidekiq::Testing.inline! do
      RecalculateElos.perform_async
    end
    expect(Player.all.sort_by { |p| -p.elo.rating }).to eql([players[1], players[0]])
  end
end
