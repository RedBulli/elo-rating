class FramesController < ApplicationController
  def create
    frame = Frame.create!(
      player1_elo: player1.elo,
      player2_elo: player2.elo,
      winner: winner,
      game_type: permitted_params[:game_type]
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
    params.require(:player1)
    params.require(:player2)
    params.require(:winner)
    params.require(:game_type)
    params.permit(:winner, :player1, :player2, :game_type)
  end

  def player1
    @player1 ||= Player.find(permitted_params[:player1])
  end

  def player2
    @player2 ||= Player.find(permitted_params[:player2])
  end

  def winner
    if permitted_params[:winner] == 'player1'
      player1
    else
      player2
    end
  end
end
