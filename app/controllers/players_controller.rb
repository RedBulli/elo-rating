class PlayersController < ApplicationController
  def index
    @players = find_players_sorted_by_elo
    @frames = Frame.all.order(created_at: :desc).map do |frame|
      {
        breaker_is_winner: frame.player1_elo.player == frame.winner,
        player1: frame.player1_elo.player,
        player2: frame.player2_elo.player,
        created_at: frame.created_at,
        deletable: frame.deletable?,
        model: frame
      }
    end
  end

  private

  def find_players_sorted_by_elo
    Player.includes(:elo).all.sort_by { |player| -player.elo.rating }
  end
end
