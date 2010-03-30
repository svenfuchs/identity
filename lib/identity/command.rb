class Identity::Command < Command
  def initialize(command, args, message)
    super
    @command = :create if command = :update && sender.created_at.nil?
  end
  
  desc 'create [sources]', 'create your identity'
  def create
    args << "#{message.source}:#{message.sender}" # i.e. on create we always pull the source's profile (e.g. twitter)
    args.uniq!
    update
  end

  desc 'update [sources]', 'update from all or given sources'
  def update
    Identity::Sources.update_all(sender, args)
    sender.claim
    sender.save
  end
  
  desc 'join', 'join this group'
  def join
    sender.groups ||= []
    sender.groups << message.receiver
    sender.save
  end

  protected
    
    def sender
      @sender ||= Identity.find_by_handle(message.sender) || Identity.new
    end
end

