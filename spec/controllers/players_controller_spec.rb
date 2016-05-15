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
end
