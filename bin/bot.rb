$: << File.expand_path('../../lib', __FILE__)
require 'identity'

bot.add_handler(:reply, Identity::Sources::Twitter.handler(/#update/, :update))
