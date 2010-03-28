require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/string/inflections'

class Identity::Command
  autoload :Base,   'identity/command/base'
  autoload :Create, 'identity/command/create'
  autoload :Update, 'identity/command/update'
  autoload :Join,   'identity/command/join'
  
  class << self
    def queue(receiver, message)
      Identity::Message.if_unprocessed(message) do |message|
        commands(message).each { |cmd| Identity::Command.build(cmd, message).dispatch } # we don't have a queue yet, so just dispatch
      end
    end
    
    def build(type, message)
      const_get(type.to_s.camelize).new(message)
    end
    
    def commands(message)
      commands = message.commands
      commands.unshift('create').delete('update') unless sender = Identity.find_by_handle(message.sender)
      commands.uniq
    end
  end
end