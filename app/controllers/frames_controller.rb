class FramesController < ApplicationController
  def create
    frame = Frame::create_frame(
      winner: winner,
      loser: loser,
      breaker: player1,
      game_type: permitted_params[:game_type]
    )
    PostResultToFlowdock.perform_async(frame.id)
    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { render json: frame }
    end
  end

  def destroy
    frame = Frame.find(params[:id])
    if frame.deletable?
      frame.elos.each(&:remove_frame)
      frame.destroy!
      respond_to do |format|
        format.html { redirect_to root_url }
        format.json { render body: nil, status: 204 }
      end
    else
      render json: { error: 'Cannot delete frame' }.to_json, status: 400
    end
  end

  def index
    frames = Frame.where(nil).includes(:elos)
    frames = frames.for_player(params[:player]) if params[:player]
    frames = frames.limit(params[:limit]) if params[:limit]
    render json: frames.order('created_at DESC')
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
