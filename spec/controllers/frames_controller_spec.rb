require 'rails_helper'
require 'support/auth_helper'

RSpec.describe FramesController, type: :controller do
  include AuthHelper
  before :each do
    http_login
  end

  describe '#create' do
    it 'redirects to index' do
      post :create, winner: 'Sampo', loser: 'Oskari', breaker: 'winner'
      expect(response).to redirect_to('/')
    end

    it 'creates frame' do
      expect {
        post :create, winner: 'Sampo', loser: 'Oskari', breaker: 'loser'
      }.to change{Frame.count}.from(0).to(1)
    end

    it 'creates the players if they are not found' do
      expect {
        post :create, winner: 'Sampo', loser: 'Oskari', breaker: 'winner'
      }.to change{Player.count}.from(0).to(2)
    end

    it 'uses the breaker as the player 1' do
      post :create, winner: 'Sampo', loser: 'Oskari', breaker: 'loser'
      expect(Frame.first.player1.name).to eql('Oskari')
    end

    it 'uses the breaker as the player 1' do
      post :create, winner: 'Sampo', loser: 'Oskari', breaker: 'winner'
      expect(Frame.first.player1.name).to eql('Sampo')
    end
  end
end
