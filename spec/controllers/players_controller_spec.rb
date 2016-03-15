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
      expect {
        process :create, method: :post, params: { name: 'Sampo' }
      }.to change{Player.count}.from(0).to(1)
    end
  end
end
