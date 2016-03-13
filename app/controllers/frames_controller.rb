class FramesController < ApplicationController
  def create
    permitted_params
    frame = Frame.create!(
      player1_elo: player1_elo,
      player2_elo: player2_elo,
      winner: winner,
      game_type: params[:game_type]
    )
    PostResultToFlowdock.perform_async(frame.id)
    redirect_to root_url
  end

  def destroy
    frame = Frame.find(params[:id])
    if frame.deletable?
      restore_player_elos(frame)
      frame.destroy!
      redirect_to root_url
    else
      render body: nil, status: 400
    end
  end

  private

  def restore_player_elos(frame)
    [frame.player1_elo, frame.player2_elo].each do |previous_elo|
      player = previous_elo.player
      changed_elo = player.elo
      player.elo = previous_elo
      changed_elo.destroy!
      player.save!
    end
  end

  def permitted_params
    params.require(:winner)
    params.require(:loser)
    params.require(:breaker)
    params.require(:game_type)
    params.permit(:winner, :loser, :breaker, :game_type)
  end

  def player1_elo
    if permitted_params[:breaker] == 'winner'
      get_or_create_player_elo(permitted_params[:winner])
    else
      get_or_create_player_elo(permitted_params[:loser])
    end
  end

  def player2_elo
    if permitted_params[:breaker] == 'winner'
      get_or_create_player_elo(permitted_params[:loser])
    else
      get_or_create_player_elo(permitted_params[:winner])
    end
  end

  def winner
    get_or_create_player(permitted_params[:winner])
  end

  def get_or_create_player_elo(name)
    get_or_create_player(name).elo
  end

  def get_or_create_player(name)
    Player::find_or_create_by_name(name)
  end
end
