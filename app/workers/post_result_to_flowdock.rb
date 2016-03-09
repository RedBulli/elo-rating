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
        title: "Pool results for #{date_str}"
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
