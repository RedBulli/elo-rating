require 'rails_helper'
require 'support/auth_helper'

RSpec.describe ElosController, type: :controller do
  include AuthHelper
  before :each do
    http_login
  end

  let(:player_sampo) { Player.create!(name: 'Sampo') }
  let(:player_oskari) { Player.create!(name: 'Oskari') }

  describe '#ev' do
    it 'returns the ev for the players' do
      Frame::create_frame(
        winner: player_sampo,
        breaker: player_sampo,
        loser: player_oskari,
        game_type: 'eight_ball'
      )
      player_sampo.elo.rating = 1500
      player_sampo.elo.save
      player_oskari.elo.rating = 1500
      player_oskari.elo.save
      process :ev, method: :get, params: { player1: player_sampo.id, player2: player_oskari.id, game_type: 'eight_ball' }
      expect(response.body).to eql({
        player1: {
          ev: 0.5,
          elo_change_win: 15.0,
          elo_change_lose: -15.0
        },
        player2: {
          ev: 0.5,
          elo_change_win: 15.0,
          elo_change_lose: -15.0
        },
        should_change_breaker: true
      }.to_json)
    end
  end
end
