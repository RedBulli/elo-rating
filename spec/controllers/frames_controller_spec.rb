require 'rails_helper'
require 'support/auth_helper'

RSpec.describe FramesController, type: :controller do
  include AuthHelper
  before :each do
    http_login
  end

  describe '#create' do
    it 'redirects to index' do
      process :create, method: :post, params: { winner: 'Sampo', loser: 'Oskari', breaker: 'winner' }
      expect(response).to redirect_to('/')
    end

    it 'creates frame' do
      expect {
        process :create, method: :post, params: { winner: 'Sampo', loser: 'Oskari', breaker: 'loser' }
      }.to change{Frame.count}.from(0).to(1)
    end

    it 'creates the players if they are not found' do
      expect {
        process :create, method: :post, params: { winner: 'Sampo', loser: 'Oskari', breaker: 'winner' }
      }.to change{Player.count}.from(0).to(2)
    end

    it 'uses the breaker as the player 1' do
      process :create, method: :post, params: { winner: 'Sampo', loser: 'Oskari', breaker: 'loser' }
      expect(Frame.first.player1.name).to eql('Oskari')
    end

    it 'uses the breaker as the player 1' do
      process :create, method: :post, params: { winner: 'Sampo', loser: 'Oskari', breaker: 'winner' }
      expect(Frame.first.player1.name).to eql('Sampo')
    end

    it "matches players even if capitalization is not same" do
      Player.create!(name: 'Sampo')
      expect {
        process :create, method: :post, params: { winner: 'sampo', loser: 'Oskari', breaker: 'winner' }
      }.to change{Player.count}.from(1).to(2)
      expect(Frame.first.player1.name).to eql('Sampo')
    end

    it 'posts the result to Flowdock' do
      stub = stub_request(:post, "https://api.flowdock.com/v1/messages").to_return(status: 200, body: '')
      Sidekiq::Testing.inline! do
        process :create, method: :post, params: { winner: 'Sampo', loser: 'Oskari', breaker: 'winner' }
        expect(stub).to have_been_requested
      end
    end
  end

  describe '#destroy' do
    it 'redirects to index' do
      p1 = Player.create!(name: 'Sampo')
      frame = Frame.create!(player1_elo: p1.elo, player2_elo: Player.create!(name: 'Oskari').elo, winner: p1)
      process :destroy, method: :delete, params: { id: frame.id }
      expect(response).to redirect_to('/')
    end

    it 'does not allow undeletable frames to be deleted' do
      p1 = Player.create!(name: 'Sampo')
      p2 = Player.create!(name: 'Oskari')
      first_frame = Frame.create!(player1_elo: p1.elo, player2_elo: p2.elo, winner: p1)
      Frame.create!(player1_elo: p1.elo, player2_elo: p2.elo, winner: p2)
      expect{
        process :destroy, method: :delete, params: { id: first_frame.id }
      }.to change{Frame.count}.by(0)
    end
  end
end
