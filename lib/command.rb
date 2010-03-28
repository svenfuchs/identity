require 'active_support/inflector'
require 'active_support/core_ext/module/delegation'

class Command
  autoload :Base,    'command/base'
  autoload :Message, 'command/message'
  autoload :Poller,  'command/poller'
  
  class << self
    def queue(receiver, message)
      Message.if_unprocessed(message) do |message|
        message.commands.each { |type| new(type, message).dispatch } # we don't have a queue yet, so just dispatch
      end
    end
  end
  
  include Base
end