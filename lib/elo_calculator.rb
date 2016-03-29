class EloCalculator
  BASE_K_FACTOR = 10

  def initialize(elo, opponent_elo)
    @elo = elo
    @opponent_elo = opponent_elo
  end

  def elo_change(result)
    (result - ev) * k_factor
  end

  def ev
    (1.0/(1.0+10.0**(rating_diff/400.0))).to_d
  end

  def k_factor
    if @elo[:provisional]
      BASE_K_FACTOR * 3
    elsif @opponent_elo[:provisional]
      BASE_K_FACTOR / 2
    else
      BASE_K_FACTOR
    end
  end

  def rating_diff
    (@opponent_elo[:rating]-@elo[:rating]).to_d
  end
end
