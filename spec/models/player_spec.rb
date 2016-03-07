require 'rails_helper'

RSpec.describe Player, type: :model do
  it 'works' do
    Player.create(name: 'Sampo')
  end
end
