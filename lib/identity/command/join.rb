class Identity::Command
  class Join < Base
    def dispatch
      sender.groups ||= []
      sender.groups << receiver
      sender.save
    end
  end
end