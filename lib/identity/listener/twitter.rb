# Twitter interface. Uses a Twibot to listen to Twitter replies.

class Identity::Listener::Twitter
  def initialize(bot = nil)
    bot.add_handler(:reply, handler(/#update/, :update)) if bot
  end

  def handler(pattern, callback)
    Twibot::Handler.new(pattern) do |message, args|
      handle = message.user.screen_name
      text   = "twitter:#{handle} #{message.text}"
      Identity::Command.new(callback, handle, text).queue
    end
  end
end
