module Command::Base
  attr_reader :command, :message, :arguments
  delegate :receiver, :source, :to => :message

  def initialize(command, message)
    @command   = command
    @message   = message
    @arguments = message.arguments
  end

  def dispatch
    send(command)
  end
end