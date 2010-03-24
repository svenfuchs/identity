module Sinatra
  module Authorization
    def protected!
      return if authorized?
      unauthorized! unless auth.provided?
      bad_request!  unless auth.basic?
      unauthorized! unless authorize(*auth.credentials)
      request.env['REMOTE_USER'] = auth.username
    end
    
    def auth
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
    end

    def unauthorized!(realm = "identity.heroku.com")
      headers 'WWW-Authenticate' => %(Basic realm="#{realm}")
      throw :halt, [ 401, 'Authorization Required' ]
    end

    def bad_request!
      throw :halt, [ 400, 'Bad Request' ]
    end

    def authorized?
      request.env['REMOTE_USER']
    end

    def authorize(username, password)
      username == ENV['twitter_login'] && password == ENV['twitter_password']
    end

    def admin?
      authorized?
    end
  end
end