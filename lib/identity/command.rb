class Identity::Command
  attr_reader :identity, :command, :args

  def initialize(command, handle, args)
    @identity = Identity.find_by_handle(handle) || Identity.new
    @command  = normalize_command(command)
    @args     = parse_args(args)
  end
  
  def join
    update
  end
  
  def update
    Identity::Sources.update_all(identity, args)
    identity.claim
  end

  def queue
    dispatch # we don't have a queue yet, so just call
  end

  def dispatch
    send(command)
    identity.save
  end
  
  def normalize_command(command)
    command == 'update' && !identity.created_at ? 'join' : command
  end

  def parse_args(string)
    string.scan(/[^\s]+:[^\s]*/).inject({}) do |args, token|
      ix = token.index(':')
      args[token[0, ix]] = token[ix + 1..-1] if ix
      args
    end
  end
end
