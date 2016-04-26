class PlayersController < ApplicationController
  def index
    render json: Player.includes(:elo).all
  end

  def show
    @player = Player.includes(:elo).find(params[:id])
    respond_to do |format|
      format.html do
        @elos = elos
      end
      format.json do
        render json: {
          player: PlayerSerializer.new(@player).as_json,
          elos: @player.elos.map do |elo|
            EloSerializer.new(elo).as_json
          end
        }
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
