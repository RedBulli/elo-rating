class ElosController < ApplicationController
  def ev
    player1_ev = player1.elo.ev(player2.elo)
    player2_ev = 1.0 - player1_ev
    render json: {
      player1: {
        ev: player1_ev.to_f,
        elo_change_win: ((1-player1_ev) * player1.elo.k_factor(player2.elo)).to_f,
        elo_change_lose: (-player1_ev * player1.elo.k_factor(player2.elo)).to_f
      },
      player2: {
        ev: player2_ev.to_f,
        elo_change_win: ((1-player2_ev) * player2.elo.k_factor(player1.elo)).to_f,
        elo_change_lose: (-player2_ev * player2.elo.k_factor(player1.elo)).to_f
      },
      should_change_breaker: should_change_breaker?
    }
  end

  private

  def player1
    Player.find(params[:player1])
  end

  def player2
    Player.find(params[:player2])
  end

  def should_change_breaker?
    !!(last_frame_against && last_frame_against.player1_elo.player == player1)
  end

  def last_frame_against
    player1.frames_against_with(player2).order(created_at: :desc).first
  end
end
