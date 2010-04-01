$: << File.expand_path('../lib', __FILE__)
require 'rubygems'
require 'sinatra'

require 'command'
require 'identity'
require 'identity/command'

# should be set through heroku config:add
ENV['couchdb_url']      ||= 'http://localhost:5984/rugb'
ENV['twitter_login']    ||= 'rugb_test'
ENV['twitter_password'] ||= 'password'

Dir[File.expand_path('../app/**/*', __FILE__)].each { |file| require file }

configure :production do
  # set :public, File.dirname('../static', __FILE__)
end

helpers do
  include Sinatra::Authorization
  include Identity::Helpers
end

get '/' do
  identities = Identity.all
  respond_to do |format|
    format.html { erb :identities, :locals => { :identities => identities } }
    format.json { identities.to_json }
  end
end

get '/ping' do
  protected!
  poller = Command::Poller::Twitter.new(:reply, ENV['twitter_login'], ENV['twitter_password'])
  poller.run!
end