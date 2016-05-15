class PlayersController < ApplicationController
  serialization_scope :player

  def index
    render json: Player.includes(:elo).all
  end

  def show
    @player = Player.includes(:elo).find(params[:id])
    @elos = elos
  end

  def create
    Player.create!(name: params[:name])
    redirect_to root_url
  end

  private

  def player
    @player
  end

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
