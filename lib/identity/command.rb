class Identity::Command
  attr_reader :command, :handle, :args

  def initialize(command, handle, args)
    @command = command
    @handle  = handle
    @args    = parse_args(args)
  end

  def queue
    # would queue this somewhere
    dispatch
  end

  def dispatch
    identity = Identity.find_by_handle(handle) || Identity.new
    identity.send(command, args)
    identity.save
  end

  def parse_args(string)
    string.scan(/[^\s]+:[^\s]*/).inject({}) do |args, token|
      ix = token.index(':')
      args[token[0, ix]] = token[ix + 1..-1] if ix
      args
    end
  end
end
