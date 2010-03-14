require 'httparty'
require 'pp'

# You can also use post, put, delete in the same fashion
response = HTTParty.get('http://twitter.com/statuses/public_timeline.json')
puts response.body, response.code, response.message, response.headers.inspect

response.each do |item|
  puts item['user']['screen_name']
end
