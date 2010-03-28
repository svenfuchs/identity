class Identity::Command
  class Create < Update
    def dispatch
      # i.e. on create make sure we pull the source's profile (e.g. twitter)
      arguments << "#{message.source}:#{message.sender}"
      arguments.uniq!
      super
    end
  end
end