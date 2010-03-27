class Identity::Command
  attr_reader :identity, :command, :sender, :receiver, :args

  def initialize(command, receiver, sender, args)
    @receiver = receiver
    @sender   = Identity.find_by_handle(sender) || Identity.new
    @command  = command
    @args     = parse_args(args)
  end
  
  def join
    update unless sender.created_at
    sender.groups ||= []
    sender.groups << receiver
    sender.save
  end
  
  def update
    Identity::Sources.update_all(sender, args)
    sender.claim
    sender.save
  end

  def queue
    dispatch # we don't have a queue yet, so just call
  end

  def dispatch
    send(command)
    sender.save
  end

  # def parse_args(string)
  #   string.scan(/[^\s]+:[^\s]*/).inject({}) do |args, token|
  #     ix = token.index(':')
  #     args[token[0, ix]] = token[ix + 1..-1] if ix
  #     args
  #   end
  # end

  def parse_args(string)
    string.scan(/[^\s]+:[^\s]*/)
  end
end
