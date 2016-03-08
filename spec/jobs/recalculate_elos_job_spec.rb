require 'rails_helper'

RSpec.describe RecalculateElosJob, type: :job do
  it 'should recalculate elos' do
    players = %w(Sampo Oskari Antti).map do |name|
      Player.create!(name: name)
    end
    frames = [[0,1], [0,2], [1,2]].map do |players_indexes|
      Frame.create!(
        player1_elo: players[players_indexes[0]].elo,
        player2_elo: players[players_indexes[1]].elo,
        winner: players[players_indexes[0]]
      )
    end
    expect(players.sort_by { |p| -p.elo.rating }).to eql([players[0], players[1], players[2]])
    frames[0].winner = players[1]
    frames[0].save
    RecalculateElosJob.perform_now
    reloaded_players = players.map do |player|
      player.reload
      player
    end
    expect(reloaded_players.sort_by { |p| -p.elo.rating }).to eql([players[1], players[0], players[2]])
  end
end
