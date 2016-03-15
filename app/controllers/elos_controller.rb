class ElosController < ApplicationController
  def ev
    player1_elo = Elo.find(params[:player1_elo])
    player2_elo = Elo.find(params[:player2_elo])
    player1_ev = player1_elo.ev(player2_elo)
    player2_ev = 1.0 - player1_ev
    render json: {
      player1: {
        ev: player1_ev.to_f,
        elo_change_win: ((1-player1_ev) * player1_elo.k_factor(player2_elo)).to_f,
        elo_change_lose: (-player1_ev * player1_elo.k_factor(player2_elo)).to_f
      },
      player2: {
        ev: player2_ev.to_f,
        elo_change_win: ((1-player2_ev) * player2_elo.k_factor(player1_elo)).to_f,
        elo_change_lose: (-player2_ev * player2_elo.k_factor(player1_elo)).to_f
      }
    }
  end
end
