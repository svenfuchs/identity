class Identity::Command::Base
  attr_reader :sender, :message, :arguments
  delegate :receiver, :source, :to => :message

  def initialize(message)
    @sender    = Identity.find_by_handle(message.sender) || Identity.new
    @message   = message
    @arguments = message.arguments
  end
end