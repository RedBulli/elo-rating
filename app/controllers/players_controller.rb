class PlayersController < ApplicationController
  def index
    render json: Player.all
  end

  def show
    @player = Player.find(params[:id])
    @elos = elos
    respond_to do |format|
      format.html
      format.json do
        render json: { player: @player, elos: @elos }.to_json
      end
    end
  end

  def create
    Player.create!(name: params[:name])
    redirect_to root_url
  end

  private

  def elos
    @player.elos.eager_load(:frame).map do |elo|
      next unless elo.frame
      {
        elo: elo,
        won: elo.winner,
        opponent: elo.frame.opponent_elo_of_player(@player)
      }
    end.compact.sort_by { |elo| elo[:elo].frame.created_at }.reverse
  end
end
