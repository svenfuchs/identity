require 'rack/respond_to'

class Sinatra::Application
  include Rack::RespondTo

  def respond_to
    env['HTTP_ACCEPT'] ||= 'text/html'
    Rack::RespondTo.env = env

    super { |format|
      yield(format).tap do |response|
        type = Rack::RespondTo::Helpers.match(Rack::RespondTo.media_types, format).first
        content_type(type) if type
      end
    }
  end
end