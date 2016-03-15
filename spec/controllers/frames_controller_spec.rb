require 'rails_helper'
require 'support/auth_helper'

RSpec.describe FramesController, type: :controller do
  include AuthHelper
  before :each do
    http_login
  end

  let(:player_sampo) { Player.create!(name: 'Sampo') }
  let(:player_oskari) { Player.create!(name: 'Oskari') }

  describe '#create' do
    it 'redirects to index' do
      process :create, method: :post, params: { winner: 'player1', player1: player_oskari.id, player2: player_sampo.id, game_type: 'eight_ball' }
      expect(response).to redirect_to('/')
    end

    it 'creates frame' do
      expect {
        process :create, method: :post, params: { winner: 'player1', player1: player_oskari.id, player2: player_sampo.id, game_type: 'eight_ball' }
      }.to change{Frame.count}.from(0).to(1)
    end

    it 'uses params correctly' do
      process :create, method: :post, params: { winner: 'player2', player1: player_oskari.id, player2: player_sampo.id, game_type: 'nine_ball' }
      frame = Frame.first
      expect(frame.player1).to eql(player_oskari)
      expect(frame.player2).to eql(player_sampo)
      expect(frame.winner).to eql(player_sampo)
      expect(frame.game_type).to eql('nine_ball')
    end

    it 'posts the result to Flowdock' do
      stub = stub_request(:post, 'https://api.flowdock.com/v1/messages').to_return(status: 200, body: '')
      Sidekiq::Testing.inline! do
        process :create, method: :post, params: { winner: 'player1', player1: player_oskari.id, player2: player_sampo.id, game_type: 'nine_ball' }
        expect(stub).to have_been_requested
      end
    end
  end

  describe '#destroy' do
    it 'redirects to index' do
      p1 = Player.create!(name: 'Sampo')
      frame = Frame.create!(player1_elo: p1.elo, player2_elo: Player.create!(name: 'Oskari').elo, winner: p1, game_type: 'nine_ball')
      process :destroy, method: :delete, params: { id: frame.id }
      expect(response).to redirect_to('/')
    end

    it 'does not allow undeletable frames to be deleted' do
      p1 = Player.create!(name: 'Sampo')
      p2 = Player.create!(name: 'Oskari')
      first_frame = Frame.create!(player1_elo: p1.elo, player2_elo: p2.elo, winner: p1, game_type: 'nine_ball')
      Frame.create!(player1_elo: p1.elo, player2_elo: p2.elo, winner: p2, game_type: 'one_pocket')
      expect{
        process :destroy, method: :delete, params: { id: first_frame.id }
      }.to change{Frame.count}.by(0)
    end
  end
end
