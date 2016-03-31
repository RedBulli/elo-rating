require 'rails_helper'
require 'support/auth_helper'

RSpec.describe PlayersController, type: :controller do
  include AuthHelper
  before :each do
    http_login
  end

  describe '#create' do
    it 'redirects to index' do
      process :create, method: :post, params: { name: 'Sampo' }
      expect(response).to redirect_to('/')
    end

    it 'creates frame' do
      expect do
        process :create, method: :post, params: { name: 'Sampo' }
      end.to change { Player.count }.from(0).to(1)
    end
  end

  describe '#index' do
    it 'returns players' do
      Player.create!(name: 'Sampo')
      process :index, method: :get
      expect(JSON.parse(response.body).length).to eql(1)
    end
  end

  describe '#show' do
    it 'returns the player and its elos with json' do
      player = create(:player)
      Frame::create_frame(
        winner: player,
        loser: create(:player),
        breaker: player,
        game_type: 'nine_ball'
      )
      process :show, method: :get, params: { id: player.id }, format: :json
      response_json = JSON.parse(response.body)
      expect(response_json['player']).to include('id' => player.id, 'name' => player.name)
    end
  end
end
