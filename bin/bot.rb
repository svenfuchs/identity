$: << File.expand_path('../../lib', __FILE__)
require 'identity'

Identity::Listener::Twitter.new(bot)
