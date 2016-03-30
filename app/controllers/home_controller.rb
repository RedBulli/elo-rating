class HomeController < ApplicationController
  GAME_NAME_MAPPINGS = [
    {
      value: 'eight_ball',
      name: '8 ball'
    },
    {
      value: 'nine_ball',
      name: '9 ball'
    },
    {
      value: 'one_pocket',
      name: 'One pocket'
    }
  ]

  def index
    @players = Player.includes(:elo).order('elos.rating DESC').to_a
    frames = Frame.eager_load(:elos).eager_load(:players).order(created_at: :desc).limit(20).to_a
    last_frame = frames.first
    @frames = frames.map do |frame|
      {
        breaker_is_winner: frame.player1 == frame.winner,
        player1: frame.player1,
        player2: frame.player2,
        created_at: frame.created_at,
        deletable: frame == last_frame,
        model: frame
      }
    end
    @game_types = GAME_NAME_MAPPINGS
    @ratings = @players.reduce({established: [], provisional: []}) do |memo, player|
      if player.elo.provisional
        memo[:provisional] << player
      else
        memo[:established] << player
      end
      memo
    end
  end
end
