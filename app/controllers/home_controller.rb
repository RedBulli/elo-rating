class HomeController < ApplicationController
  GAME_NAME_MAPPINGS = {
    'eight_ball' => '8 ball',
    'nine_ball' => '9 ball',
    'one_pocket' => 'One pocket'
  }

  def index
    @players = Player.includes(:elo).all.order('elos.rating DESC')
    last_frame = Frame.order('id DESC').first
    @frames = Frame.includes(:player1_elo, :player2_elo).all.order(created_at: :desc).map do |frame|
      {
        breaker_is_winner: frame.player1 == frame.winner,
        player1: frame.player1,
        player2: frame.player2,
        created_at: frame.created_at,
        deletable: frame == last_frame,
        model: frame
      }
    end
    @game_types = game_types
  end

  private

  def game_types
    Frame.game_type.values.map do |game_type|
      {
        value: game_type,
        name: GAME_NAME_MAPPINGS[game_type]
      }
    end
  end
end
