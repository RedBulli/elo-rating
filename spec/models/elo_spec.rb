require 'rails_helper'

RSpec.describe Elo, type: :model do
  let(:player) { Player.create! name: 'Sampo' }
  let(:player2) { Player.create! name: 'Oskari' }

  def create_frame
    Frame.create! player1_elo: player.elo, player2_elo: player2.elo, winner: player
  end

  it 'provisional? should return true when less than and false when more than 15 previous elos' do
    14.times { create_frame }
    expect(player.elo.provisional?).to eql(true)
    create_frame
    expect(player.elo.provisional?).to eql(false)
  end
end
