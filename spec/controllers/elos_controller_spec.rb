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
      process :ev, method: :get, params: { player1_elo: player_sampo.elo.id, player2_elo: player_oskari.elo.id, game_type: 'eight_ball' }
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
        }
      }.to_json)
    end
  end
end
