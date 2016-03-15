class PlayersController < ApplicationController
  def show
    @player = Player.find(params[:id])
    @elos = @player.elos.order('id DESC').map do |elo|
      if elo.frame.first
        {
          elo: elo,
          won: elo.frame.first.result(elo) == 1,
          opponent: elo.frame.first.opponent_elo(elo)
        }
      end
    end.compact
  end
end
