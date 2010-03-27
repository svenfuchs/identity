# Twitter interface. Uses a Twibot to listen to Twitter replies.
require 'twibot'

class Identity::Bot::Twitter < Twibot::Handler
  def initialize(receiver, pattern, callback)
    super(pattern) do |message, args|
      Identity::Message.if_unprocessed(receiver, message) do
        sender = message.user.screen_name
        text   = "twitter:#{sender} #{message.text}"
        Identity::Command.new(callback, receiver, sender, text).queue
      end
    end
  end
end
