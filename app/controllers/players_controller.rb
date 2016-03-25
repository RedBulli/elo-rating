class PlayersController < ApplicationController
  def index
    render json: Player.all
  end

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
    end.compact.sort_by { |elo| elo[:elo].frame.created_at }.reverse
    respond_to do |format|
      format.html
      format.json do
        render json: {player: @player, elos: @elos}.to_json
      end
    end
  end

  def create
    Player.create!(name: params[:name])
    redirect_to root_url
  end
end
