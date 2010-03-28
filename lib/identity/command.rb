module Identity::Command
  def initialize(command, message)
    super
    @command = :create if command = :update && sender.created_at.nil?
  end
  
  def create
    arguments << "#{message.source}:#{message.sender}" # i.e. on create we always pull the source's profile (e.g. twitter)
    arguments.uniq!
    update
  end

  def join
    sender.groups ||= []
    sender.groups << receiver
    sender.save
  end

  def update
    Identity::Sources.update_all(sender, arguments)
    sender.claim
    sender.save
  end
  
  protected
    
    def sender
      @sender ||= Identity.find_by_handle(message.sender) || Identity.new
    end
end

