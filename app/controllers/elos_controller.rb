require 'elo_calculator'

class ElosController < ApplicationController
  def ev
    render json: {
      player1: {
        ev: elo_calculators[0].ev.to_f,
        elo_change_win: elo_calculators[0].elo_change(1).to_f,
        elo_change_lose: elo_calculators[0].elo_change(0).to_f
      },
      player2: {
        ev: elo_calculators[1].ev.to_f,
        elo_change_win: elo_calculators[1].elo_change(1).to_f,
        elo_change_lose: elo_calculators[1].elo_change(0).to_f
      },
      should_change_breaker: should_change_breaker?
    }
  end

  private

  def elo_calculators
    [
      EloCalculator.new(elos[0].to_calculator_hash, elos[1].to_calculator_hash),
      EloCalculator.new(elos[1].to_calculator_hash, elos[0].to_calculator_hash)
    ]
  end

  def elos
    @elos ||= players.map(&:elo)
  end

  def players
    @players ||= [Player.find(params[:player1]), Player.find(params[:player2])]
  end

  def should_change_breaker?
    frame = last_frame_against
    if frame
      players[0].elos.find_by(frame: frame).breaker
    else
      false
    end
  end

  def last_frame_against
    players[0].frames_against_with(players[1]).order(created_at: :desc).first
  end
end
