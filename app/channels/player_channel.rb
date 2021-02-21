class PlayerChannel < ApplicationCable::Channel
  def subscribed
    stream_from "player"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    p data
    ActionCable.server.broadcast("player", data)
  end
end
