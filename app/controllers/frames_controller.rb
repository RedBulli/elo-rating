class FramesController < ApplicationController
  def create
    permitted_params
    Frame.create!(
      player1_elo: player_elos[0],
      player2_elo: player_elos[1],
      winner: winner
    )
    redirect_to root_url
  end

  private

  def permitted_params
    params.require(:player_1)
    params.require(:player_2)
    params.require(:winner)
    params.require(:breaker)
    params.permit(:player_1, :player_2, :winner, :breaker)
  end

  def player_elos
    @player_elos ||= player_params.map { |player_param| get_or_create_player_elo(player_param) }
  end

  def winner
    if permitted_params[:winner].to_i == 1
      get_or_create_player(permitted_params[:player_1])
    else
      get_or_create_player(permitted_params[:player_2])
    end
  end

  def player_params
    if permitted_params[:breaker].to_i == 1
      [permitted_params[:player_1], permitted_params[:player_2]]
    else
      [permitted_params[:player_2], permitted_params[:player_1]]
    end
  end

  def get_or_create_player_elo(name)
    get_or_create_player(name).elo
  end

  def get_or_create_player(name)
    player = Player::find_or_create_by(name: name)
    unless player.elo
      elo = Elo.new(player: player)
      elo.rating = 1500
      player.elo = elo
      player.save!
      elo.save!
    end
    player
  end
end
