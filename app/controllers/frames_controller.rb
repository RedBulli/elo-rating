class FramesController < ApplicationController
  def create
    frame = Frame::create_frame(
      winner: winner,
      loser: loser,
      breaker: player1,
      game_type: permitted_params[:game_type]
    )
    PostResultToFlowdock.perform_async(frame.id)
    redirect_to root_url
  end

  def destroy
    frame = Frame.find(params[:id])
    if frame.deletable?
      frame.elos.each(&:remove_frame)
      frame.destroy!
      redirect_to root_url
    else
      render body: nil, status: 400
    end
  end

  def count
    render body: Frame.count
  end

  private

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

  def loser
    if permitted_params[:winner] == 'player1'
      player2
    else
      player1
    end
  end
end
