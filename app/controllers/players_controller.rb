class PlayersController < ApplicationController
  def show
    @player = Player.find(params[:id])
    @elos = @player.elos.map do |elo|
      if elo.frame
        {
          elo: elo,
          won: elo.frame.result(elo) == 1,
          opponent: elo.frame.opponent_elo(elo)
        }
      end
    end.compact.sort { |elo| elo[:elo].frame.created_at.nsec }
  end
end
