class Identity::Command
  class Update < Base
    def dispatch
      Identity::Sources.update_all(sender, arguments)
      sender.claim
      sender.save
    end
  end
end