class PostResultToFlowdock
  include Sidekiq::Worker

  def perform(frame_id)
    @frame = Frame.find(frame_id)
    date_str = DateTime.now.to_date
    post(
      event: 'activity',
      title: "#{player_repr(@frame.winner)} won #{player_repr(@frame.loser)}",
      author: {
        name: 'Elo'
      },
      external_thread_id: date_str,
      thread: {
        title: "Pool results for #{date_str}",
        body: thread_body
      }
    )
  end

  private

  def player_repr(player)
    if @frame.player1 == player
      "#{player.name} (B)"
    else
      player.name
    end
  end

  def thread_body
    players = weekly_performances.map do |player|
      "<li>#{player[:name]} #{player[:performance].to_i}</li>"
    end
    "<h4>This weeks performance ratings</h4><ul>#{players.join("")}</ul>"
  end

  def weekly_performances
    Player.all.map do |player|
      if performance = player.performance
        {
          name: player.name,
          performance: performance
        }
      end
    end.compact.sort_by do |item|
      -item[:performance]
    end
  end

  def post(body)
    connection.post "/v1/messages", body.merge(flow_token: ENV['FLOW_TOKEN']).to_json
  end

  def connection
    Faraday.new(url: 'https://api.flowdock.com') do |faraday|
      faraday.request :json
      faraday.response :json
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end
end
