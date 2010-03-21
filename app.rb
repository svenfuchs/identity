require 'rubygems'
require 'sinatra'

configure :production do
  # Configure stuff here you'll want to only be run at Heroku at boot
end

get '/' do
  "Congradulations!
   You're running a Sinatra application on Heroku!"
end

get '/env' do
  ENV.inspect
end

get '/ping' do # TODO should be post, should require some secret
  
  ENV.inspect
end