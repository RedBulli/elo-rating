class PlayersController < ApplicationController
  def index
    @players = find_players_sorted_by_elo
  end

  private

  def find_players_sorted_by_elo
    Player.includes(:elo).all.sort_by { |player| -player.elo.rating }
  end
end
